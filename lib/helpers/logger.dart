import 'dart:io';

/// Logs the given [value] to the console
void log(String value) => stdout.writeln(value);

/// Logs the given [value] to the console as error (red color)
void logError(String value) => stdout.writeln('\x1B[31m$value\x1B[0m');
