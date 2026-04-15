// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';

void main() {
  // Find script directory and repo root
  final scriptPath = Platform.script.toFilePath();
  final scriptDir = Directory(scriptPath).parent.path;
  final repoRoot = Directory(scriptDir).parent.path;

  final adminPkgDir = '$repoRoot/packages/firebase_admin_sdk';
  final firestorePkgDir = '$repoRoot/packages/google_cloud_firestore';

  final adminCoverageFile = File('$adminPkgDir/coverage.lcov');
  final firestoreCoverageFile = File('$firestorePkgDir/coverage.lcov');

  // 1. Save individual package coverage files before merging
  final savedAdminFile = File('$adminPkgDir/coverage_admin.lcov');
  final savedFirestoreFile = File('$adminPkgDir/coverage_firestore.lcov');

  if (adminCoverageFile.existsSync()) {
    adminCoverageFile.copySync(savedAdminFile.path);
  }
  if (firestoreCoverageFile.existsSync()) {
    firestoreCoverageFile.copySync(savedFirestoreFile.path);
  }

  // 2. Merge coverage reports
  final coverageFiles = <File>[];
  if (adminCoverageFile.existsSync()) coverageFiles.add(adminCoverageFile);
  if (firestoreCoverageFile.existsSync()) {
    coverageFiles.add(firestoreCoverageFile);
  }

  if (coverageFiles.isEmpty) {
    print('No coverage files found!');
    exitCode = 1;
    return;
  }

  // Create merged file content
  final mergedContent = StringBuffer();
  for (final file in coverageFiles) {
    mergedContent.write(file.readAsStringSync());
  }

  // Overwrite coverage.lcov in admin package with merged content
  File(
    '$adminPkgDir/coverage.lcov',
  ).writeAsStringSync(mergedContent.toString());

  // 3. Calculate coverage and check threshold
  (double pct, int hit, int total) calculateCoverage(File file) {
    if (!file.existsSync()) return (0.00, 0, 0);
    final lines = file.readAsLinesSync();
    var total = 0;
    var hit = 0;
    for (final line in lines) {
      if (line.startsWith('LF:')) {
        total += int.parse(line.substring(3));
      } else if (line.startsWith('LH:')) {
        hit += int.parse(line.substring(3));
      }
    }
    if (total > 0) {
      final pct = (hit / total) * 100;
      return (pct, hit, total);
    }
    return (0.00, 0, 0);
  }

  final adminCov = calculateCoverage(savedAdminFile);
  final firestoreCov = calculateCoverage(savedFirestoreFile);
  // Storage was referenced in original script but never created.
  final storageCov = calculateCoverage(
    File('$adminPkgDir/coverage_storage.lcov'),
  );

  // Calculate total coverage from merged file
  final totalCov = calculateCoverage(File('$adminPkgDir/coverage.lcov'));

  final coveragePct = totalCov.$1.toStringAsFixed(2);
  final totalLines = totalCov.$3;
  final hitLines = totalCov.$2;

  // Output for GitHub Actions
  void githubOutput(String key, String value) {
    final githubOutput = Platform.environment['GITHUB_OUTPUT'];
    if (githubOutput != null && githubOutput.isNotEmpty) {
      File(
        githubOutput,
      ).writeAsStringSync('$key=$value\n', mode: FileMode.append);
    }
  }

  githubOutput('coverage', coveragePct);
  githubOutput('total_lines', totalLines.toString());
  githubOutput('hit_lines', hitLines.toString());

  githubOutput('admin_coverage', adminCov.$1.toStringAsFixed(2));
  githubOutput('firestore_coverage', firestoreCov.$1.toStringAsFixed(2));
  githubOutput('storage_coverage', storageCov.$1.toStringAsFixed(2));

  // Console output
  print('=== Coverage Report ===');
  print(
    'firebase_admin_sdk: ${adminCov.$1.toStringAsFixed(2)}% (${adminCov.$2}/${adminCov.$3} lines)',
  );
  print(
    'google_cloud_firestore: ${firestoreCov.$1.toStringAsFixed(2)}% (${firestoreCov.$2}/${firestoreCov.$3} lines)',
  );
  print('----------------------');
  print('Total: $coveragePct% ($hitLines/$totalLines lines)');

  // Check threshold
  if (totalCov.$1 < 40) {
    print('Coverage $coveragePct% is below 40% threshold');
    githubOutput('status', '❌ Coverage $coveragePct% is below 40% threshold');
    exitCode = 1;
  } else {
    print('Coverage $coveragePct% meets 40% threshold');
    githubOutput('status', '✅ Coverage $coveragePct% meets 40% threshold');
  }
}
