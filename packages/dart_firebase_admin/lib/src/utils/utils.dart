/// Generates the update mask for the provided object.
/// Note this will ignore the last key with value undefined.
List<String> generateUpdateMask(
  Object? obj, {
  List<String> terminalPaths = const [],
  String root = '',
}) {
  if (obj is! Map) return [];

  final updateMask = <String>[];
  for (final key in obj.keys) {
    final nextPath = root.isEmpty ? '$root.$key' : '$key';
    // We hit maximum path.
    // Consider switching to Set<string> if the list grows too large.
    if (terminalPaths.contains(nextPath)) {
      // Add key and stop traversing this branch.
      updateMask.add('$key');
    } else {
      final maskList = generateUpdateMask(
        obj[key],
        terminalPaths: terminalPaths,
        root: nextPath,
      );
      if (maskList.isNotEmpty) {
        for (final mask in maskList) {
          updateMask.add('$key.$mask');
        }
      } else {
        updateMask.add('$key');
      }
    }
  }
  return updateMask;
}
