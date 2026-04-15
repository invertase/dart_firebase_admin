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

  final coverageData = <String, ({double pct, int hit, int total})>{};
  final coverageFiles = <File>[];

  for (final pkg in Directory(
    '$repoRoot/packages',
  ).listSync().whereType<Directory>()) {
    final name = pkg.path.split(Platform.pathSeparator).last;
    final covFile = File('${pkg.path}/coverage.lcov');

    if (!covFile.existsSync()) {
      print(
        'Error: Coverage file missing for package $name at ${covFile.path}',
      );
      exitCode = 1;
      return;
    }

    coverageFiles.add(covFile);
    coverageData[name] = _calculateCoverage(covFile);
  }

  if (coverageFiles.isEmpty) {
    print('No coverage files found!');
    exitCode = 1;
    return;
  }

  // Create merged file content
  final mergedContent = StringBuffer();
  for (final file in coverageFiles) {
    final content = file.readAsStringSync();
    mergedContent.write(content);
    if (content.isNotEmpty && !content.endsWith('\n')) {
      mergedContent.write('\n');
    }
  }

  // Write merged coverage file to the repo root
  final mergedCoverageFile = File('$repoRoot/coverage.lcov');
  mergedCoverageFile.writeAsStringSync(mergedContent.toString());

  // Calculate total coverage from merged file
  final totalCov = _calculateCoverage(mergedCoverageFile);

  final coveragePct = totalCov.pct.toStringAsFixed(2);

  if (_isOnGitHub) {
    _githubOutput('coverage', coveragePct);
    _githubOutput('total_lines', totalCov.total.toString());
    _githubOutput('hit_lines', totalCov.hit.toString());

    coverageData.forEach((pkgName, cov) {
      _githubOutput('${pkgName}_coverage', cov.pct.toStringAsFixed(2));
    });
  }

  // Console output
  print('=== Coverage Report ===');
  coverageData.forEach((pkgName, cov) {
    print(
      '$pkgName: ${cov.pct.toStringAsFixed(2)}% (${cov.hit}/${cov.total} lines)',
    );
  });
  print('----------------------');
  print('Total: $coveragePct% (${totalCov.hit}/${totalCov.total} lines)');

  if (totalCov.pct < 40) {
    print('Coverage $coveragePct% is below 40% threshold');
    _githubOutput('status', '❌ Coverage $coveragePct% is below 40% threshold');
    exitCode = 1;
  } else {
    print('Coverage $coveragePct% meets 40% threshold');
    _githubOutput('status', '✅ Coverage $coveragePct% meets 40% threshold');
  }
}

final _isOnGitHub = switch (Platform.environment['GITHUB_OUTPUT']) {
  String path when path.isNotEmpty => true,
  _ => false,
};

// Output for GitHub Actions
void _githubOutput(String key, String value) {
  if (!_isOnGitHub) return;
  File(
    Platform.environment['GITHUB_OUTPUT']!,
  ).writeAsStringSync('$key=$value\n', mode: FileMode.append);
}

({double pct, int hit, int total}) _calculateCoverage(File file) {
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
    return (pct: pct, hit: hit, total: total);
  }
  return (pct: 0.0, hit: 0, total: 0);
}
