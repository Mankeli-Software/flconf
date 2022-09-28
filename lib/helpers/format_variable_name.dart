/// Formats given [input] to not include special characters, and makes it camelCase.
String formatVariableName(String input) {
  var output = '';
  input = input.trim().replaceAll(' ', '_').replaceAll('-', '_');

  while (input.contains('__')) {
    input = input.replaceAll('__', '_');
  }

  final words = input.split('_');

  for (var word in words) {
    if (word.isEmpty) continue;
    if (words.indexOf(word) == 0) {
      output += word;
    } else {
      output += word[0].toUpperCase() + word.substring(1).toLowerCase();
    }
  }

  return output.replaceAll(RegExp(r'[^\w\s]+'), '');
}
