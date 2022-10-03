/// Formats given [input] to not include special characters, and makes it camelCase.
String formatVariableName(String input) {
  var output = '';

  final words = input.split('_');

  for (var word in words) {
    if (word.isEmpty) continue;
    if (words.indexOf(word) == 0) {
      output += word.toLowerCase();
    } else {
      output += word[0].toUpperCase() + word.substring(1).toLowerCase();
    }
  }

  return output.replaceAll(RegExp(r'[^\w\s]+'), '');
}
