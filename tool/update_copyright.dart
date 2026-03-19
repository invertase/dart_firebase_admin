// Copyright 2024 Google LLC
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

const _header = '''
// Copyright 2024 Google LLC
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
''';

void main(List<String> args) {
  final verify = args.contains('--verify');
  final root = Directory.current;

  print('Scanning ${root.path} for Dart files...');

  final files = <File>[];
  _scan(root, files);

  print('Found ${files.length} Dart files.');

  var updatedCount = 0;
  var missingCount = 0;
  var correctCount = 0;

  for (final file in files) {
    final lines = file.readAsLinesSync();
    if (lines.isEmpty) continue;

    var hasCopyright = false;
    var commentEnd = 0;
    var commentStart = -1;

    // Find contiguous comment block starting at the top (ignoring ignores)
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('// ignore_for_file') || line.startsWith('// ignore:')) {
        break;
      }
      if (line.startsWith('//') && !line.startsWith('///')) {
        if (commentStart == -1) commentStart = i;
        commentEnd = i + 1;
        if (line.contains('Copyright')) {
          hasCopyright = true;
        }
      } else {
        break;
      }
    }

    final currentContent = file.readAsStringSync();
    final isCorrect = currentContent.startsWith(_header.trim());

    if (isCorrect) {
      correctCount++;
      continue;
    }

    if (hasCopyright && commentStart == 0) {
      // Check if it matches exactly (already handled by isCorrect, but good to be explicit)
      if (verify) {
        print('Verify Failed: ${file.path} has incorrect copyright header.');
      } else {
        final rest = lines.skip(commentEnd).join('\n');
        final newContent = _header.trim() + '\n\n' + rest + (rest.endsWith('\n') ? '' : '\n');
        file.writeAsStringSync(newContent);
        updatedCount++;
      }
    } else {
      // Missed or starts with something else
      if (verify) {
        print('Verify Failed: ${file.path} is missing copyright header.');
      } else {
        final newContent = _header.trim() + '\n\n' + currentContent;
        file.writeAsStringSync(newContent);
        missingCount++;
      }
    }
  }

  print('--- Summary ---');
  print('Correct: $correctCount');
  if (verify) {
    if (updatedCount > 0 || missingCount > 0) {
      print('Verification failed. Run without --verify to update.');
      exit(1);
    } else {
      print('Verification passed.');
    }
  } else {
    print('Updated (replaced): $updatedCount');
    print('Added (prepended): $missingCount');
    print('Total modified: ${updatedCount + missingCount}');
  }
}

void _scan(Directory dir, List<File> files) {
  for (final entity in dir.listSync(recursive: false)) {
    if (entity is Directory) {
      final name = entity.path.split(Platform.pathSeparator).last;
      if (name.startsWith('.') || name == 'build' || name == 'doc') {
        continue;
      }
      _scan(entity, files);
    } else if (entity is File) {
      if (entity.path.endsWith('.dart')) {
        final name = entity.path.split(Platform.pathSeparator).last;
        if (name.endsWith('.g.dart') ||
            name.endsWith('.freezed.dart') ||
            name.endsWith('.mocks.dart')) {
          continue;
        }
        files.add(entity);
      }
    }
  }
}
