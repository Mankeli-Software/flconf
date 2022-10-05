/// Validates that the given `fileName` is alphanumeric (with underscores as spaces) and does not start with a number.
bool validateConfigFileName(String fileName) {
  final alphabets = RegExp(r'^[a-zA-Z_]+$');
  final alphaNumeric = RegExp(r'^[a-zA-Z0-9_]+$');
  return alphabets.hasMatch(fileName[0]) &&
      alphaNumeric.hasMatch(fileName.substring(1));
}

/// Validates that the given `fileName` is alphanumeric (with underscores as spaces), uppercase and does not start with a number.
bool validateVariableName(String fileName) {
  final alphabets = RegExp(r'^[A-Z_]+$');
  final alphaNumeric = RegExp(r'^[A-Z0-9_]+$');
  return alphabets.hasMatch(fileName[0]) &&
      alphaNumeric.hasMatch(fileName.substring(1));
}
