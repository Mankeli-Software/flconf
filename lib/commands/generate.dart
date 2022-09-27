import 'dart:convert';
import 'dart:io';
import 'package:flconf/helpers/formatVariableName.dart';
import 'package:path/path.dart' as path;

import '../helpers/logger.dart';

/// Generates boilerplate code that makes it easier to access config variables in dart code.
Future generate(List<String> args) async {
  // Creates the lib directory, if it doesn't exist (at the root of the project)
  final lib = Directory(path.join(Directory.current.path, 'lib'));

  if (!await lib.exists()) {
    await lib.create();
  }

  // Creates the directory for generated files, if it doesn't exist (at lib/)
  final generatedDir = Directory(path.join(lib.path, 'generated'));

  if (!await generatedDir.exists()) {
    await generatedDir.create();
  }

  // Deletes old generated file, if they exist and creates a new empty one
  final flconfFile = File(path.join(generatedDir.path, 'flconf.dart'));
  if (await flconfFile.exists()) {
    await flconfFile.delete();
  }
  await flconfFile.create();

  // Lists the files in the flconf directory
  final confDir = Directory(path.join(Directory.current.path, 'flconf'));
  if (!await confDir.exists()) {
    logError('flconf directory not found. Please run flconf init to create it.');
    exit(1);
  }
  final confFiles = confDir.listSync();

  // These will store the raw AND formatted names of the files/variables.
  // Name formatting removes whitespaces/special characters and makes the names camelCase.
  final confFileNames = <String, String>{};
  final variables = <String, String>{};

  // Iterates over the files in the flconf directory and collects the file names and variables
  await Future.wait(
    confFiles.map(
      (file) async {
        final confFile = File(file.path);

        // Parses the file name and sets the filename variables
        final name = confFile.path.split('/').last.split('.').first;
        confFileNames[formatVariableName(name)] = name;

        // Parses the variables and sets the variables
        final confString = await confFile.readAsString();
        final confMap = json.decode(confString) as Map;
        confMap.forEach((key, value) {
          variables[formatVariableName(key)] = 'flconf-' + key;
        });
      },
    ),
  );

  /// Opens config file for writing
  final sink = flconfFile.openWrite();

  sink.write('''
//  IMPORTANT:  This file is generated using flconf command line tools and the values provided in the configuration files. Do not edit manually.

/// Loads the config file name used to run the app.
const _configFileName = String.fromEnvironment('flconf-config-file-name');

/// This enum is generated from the files in flconf directory, so it represents all the available configurations for this app.
enum Config {
''');

  confFileNames.forEach((formatted, unformatted) {
    sink.writeln('  $formatted,');
  });

  sink.write('''
  unknown,
}

/// An extension to parse enum value from string
extension ConfigExtension on Config {
  Config fromString(String input) {
    switch (input) {
''');

  confFileNames.forEach((formatted, unformatted) {
    sink.write('''
      case '$unformatted':
        return Config.$formatted;
''');
  });
  sink.write('''
      default:
        return Config.unknown;
    }
  }
}

/// This class is generated using flconf command line tools. It helps to access the values provided in the configuration files.
class FlConf {
  static final Config config = ConfigExtension.fromString(_configFileName);
''');

  variables.forEach((formatted, unformatted) {
    sink.write('''
  static const String $formatted = String.fromEnvironment('$unformatted');
''');
  });

  sink.writeln('''
}
''');

  log('Generated boilerplate code at ${flconfFile.path}');
}
