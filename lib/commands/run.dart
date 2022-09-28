import 'dart:convert';
import 'dart:io';
import 'package:flconf/helpers/get_dart_defines.dart';
import 'package:flconf/helpers/logger.dart';

/// Injects config file variables into the `flutter run` -command using --dart-define
Future run(List<String> args) async {
  /// Checks that has been given at least one argument (config file name)
  if (args.isEmpty) {
    logError('Usage: flconf run <config file name> <extra parameters>');
    exit(1);
  }
  final flutterArgs = ['run'];

  // The name of the config file should be the next part of the command
  final configName = args.removeAt(0);

  /// Loads list of dart defines from the config file
  final defines = await getDartDefines(configName);

  /// combines dart defines and the rest of the arguments
  flutterArgs.addAll([...defines, ...args]);

  /// Starts the flutter run process and listens for output and errors.
  final process = await Process.start('flutter', flutterArgs);

  process.stdout.listen((data) {
    log(utf8.decode(data));
  });

  process.stderr.listen((data) {
    logError(utf8.decode(data));
  });
}
