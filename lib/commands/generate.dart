import 'dart:convert';
import 'dart:io';
import 'package:flconf/helpers/format_strings.dart';
import 'package:flconf/helpers/validators.dart';
import 'package:path/path.dart' as path;

import '../helpers/logger.dart';

/// Generates boilerplate code that makes it easier to access config variables in dart code.
Future generate(List<String> args) async {
  // Lists the files in the flconf directory
  final confDir = Directory(path.join(Directory.current.path, 'flconf'));
  if (!await confDir.exists()) {
    logError(
        'flconf directory not found. Please run flconf init to create it.');
    exit(1);
  }
  final confFiles = confDir.listSync().map((f) => f.path).toList();

  /// Starts the process to check flutter version
  final result = await Process.run('flutter', ['--version']);
  if ((result.stderr ?? '').isNotEmpty) {
    logError('Error running flutter --version: ${result.stderr}');
    exit(1);
  }

  /// Checks that the version is at least 2.0.0
  final flutterVersion =
      result.stdout.toString().split(' ')[1].split('.').join();
  log('Flutter version: $flutterVersion');
  if (int.parse(flutterVersion) < 220) {
    /// Flutter versions under 2.2.0 are not supported by flconf.
    logError('Flutter version 2.2.0 or higher is required.');
    exit(1);
  }

  // These will store the raw AND formatted names of the files/variables.
  // Name formatting removes whitespaces/special characters and makes the names camelCase.
  final confFileNames = <String, String>{};
  final variables = <String, String>{};
  final defaults = <String, dynamic>{};

  // Iterates over the files in the flconf directory and collects the file names and variables
  await Future.wait(
    confFiles.map(
      (fileName) async {
        final confFile = File(fileName);

        // Parses the file name and sets the filename variables
        final name = confFile.path.split('/').last.split('.').first;
        confFileNames[formatCamelCase(name)] = name;

        // Parses the variables and sets the variables
        final confString = await confFile.readAsString();
        final confMap = json.decode(confString) as Map;
        confMap.forEach((key, value) {
          if (!validateVariableName(key)) {
            logError(
                'Variable name "$key" is not valid. Variable names must be alphanumeric (with underscores as spaces), capslock and it cannot start with a number.');
            exit(1);
          }
          if (name == 'defaults') {
            defaults['FLCONF_' + key] = value;
          }
          variables[formatCamelCase(key)] = 'FLCONF_' + key;
        });
      },
    ),
  );

  confFileNames.remove('defaults');

  await Future.wait(
    [
      _generateDartBoilerplate(
          confFileNames: confFileNames, variables: variables),
      _generateAndroidBoilerplate(variables: variables, defaults: defaults),
      _generateIOSBoilerplate(variables: variables, defaults: defaults),
    ],
  );
}

/// Generates a boilerplate dart class to be used in the projects flutter code.
Future _generateDartBoilerplate({
  required Map<String, String> confFileNames,
  required Map<String, String> variables,
}) async {
  // Deletes old generated file, if they exist and creates a new empty one
  final flconfFile = File(
      path.join(Directory.current.path, 'lib', 'generated', 'flconf.dart'));
  if (await flconfFile.exists()) {
    await flconfFile.delete();
  }
  await flconfFile.create(recursive: true);

  final lines = [
    '//  IMPORTANT:  This file is generated using flconf command line tools and the values provided in the configuration files. Do not edit manually.',
    '',
    '/// Loads the config file name used to run the app.',
    "const _configFileName = String.fromEnvironment('FLCONF_CONFIG_FILE_NAME');",
    '',
    '',
    '/// This enum is generated from the files in flconf directory, so it represents all the available configurations for this app.',
    'enum Config {',
    ...confFileNames.keys.map((formatted) => '  $formatted,').toList(),
    '  unknown,',
    '}',
    '',
    '/// An extension to parse enum value from string',
    'extension ConfigExtension on Config {',
    '  static Config fromString(String input) {',
    '    switch (input) {',
    ...confFileNames.keys
        .map((formatted) =>
            "      case '${confFileNames[formatted]}':\n        return Config.$formatted;")
        .toList(),
    '      default:',
    '        return Config.unknown;',
    '    }',
    '  }',
    '}',
    '',
    '/// This class is generated using flconf command line tools. It helps to access the values provided in the configuration files.',
    'class FlConf {',
    '  static final Config config = ConfigExtension.fromString(_configFileName);',
    ...confFileNames.keys
        .map((formatted) =>
            '  static bool get is${formatted[0].toUpperCase() + formatted.substring(1)} => config == Config.$formatted;')
        .toList(),
    ...variables.keys.map((formatted) =>
        "  static const String $formatted = String.fromEnvironment('${variables[formatted]}');"),
    '}',
  ];

  await flconfFile.writeAsString(lines.join('\n'));

  log('Generated ${lines.length} lines of boilerplate code at ${flconfFile.path}');
}

/// Generates boilerplate code that makes it easier to access config variables in the native android code.
Future _generateAndroidBoilerplate({
  required Map<String, String> variables,
  required Map<String, dynamic> defaults,
}) async {
  final buildGradle =
      File(path.join(Directory.current.path, 'android', 'app', 'build.gradle'));
  if (!await buildGradle.exists()) {
    logError(
        'android/app/build.gradle not found within the project. Will not generate android boilerplate.');
    return;
  }

  /// Reads build.gradle and deletes old code generated by flconf
  var lines = (await buildGradle.readAsString()).split('\n');
  lines =
      lines.where((line) => !line.contains('Generated with flconf')).toList();

  /// Generates new code
  final generatedLines = [
    'def flconfVariables = [ // Generated with flconf, DO NOT EDIT!!',
    ...variables.entries
        .map((key) =>
            '    $key: ${defaults[key]}, // Generated with flconf, DO NOT EDIT!!')
        .toList(),
    ']; // Generated with flconf, DO NOT EDIT!!',
    '',
    "if (project.hasProperty('dart-defines')) { // Generated with flconf, DO NOT EDIT!!",
    "    flconfVariables = flconfVariables + project.property('dart-defines') // Generated with flconf, DO NOT EDIT!!",
    "        .split(',') // Generated with flconf, DO NOT EDIT!!",
    '        .collectEntries { entry -> // Generated with flconf, DO NOT EDIT!!',
    "            def pair = new String(entry.decodeBase64(), 'UTF-8').split('=') // Generated with flconf, DO NOT EDIT!!",
    '            [(pair.first()): pair.last()] // Generated with flconf, DO NOT EDIT!!',
    '        } // Generated with flconf, DO NOT EDIT!!',
    '} // Generated with flconf, DO NOT EDIT!!',
    '',
  ];

  /// Inserts new generations to old build.gradle
  lines.insertAll(0, generatedLines);

  /// Add variables as resValues so they can be used anywhere within the android project
  final androidStartIndex =
      lines.indexWhere((line) => line.startsWith('android {'));
  if (androidStartIndex == -1) {
    logError(
        'Invalid app/build.gradle... android -object not found within the file. Will not generate android boilerplate.');
    return;
  }
  final defaultConfigStartIndex = lines.indexWhere(
      (line) => line.startsWith('    defaultConfig {'), androidStartIndex);
  if (defaultConfigStartIndex == -1) {
    logError(
        'Invalid app/build.gradle... defaultConfig -object not found within the file. Will not generate android boilerplate.');
    return;
  }
  variables.forEach((formatted, unformatted) {
    lines.insert(defaultConfigStartIndex + 1,
        '        resValue "string", "$unformatted", dartEnvironmentVariables.$unformatted // Generated with flconf, DO NOT EDIT!!');
  });

  /// Writes new build.gradle values
  await buildGradle.writeAsString(lines.join('\n'));
  log('Generated ${variables.length + generatedLines.length} lines of boilerplate code at ${buildGradle.path}');
}

/// Generates boilerplate code that makes it easier to access config variables in the native ios code.
Future _generateIOSBoilerplate({
  required Map<String, String> variables,
  required Map<String, dynamic> defaults,
}) async {
  final flconfDefaultConfig = File(path.join(
      Directory.current.path, 'ios', 'Flutter', 'Flconf-defaults.xcconfig'));
  if (await flconfDefaultConfig.exists()) {
    await flconfDefaultConfig.delete();
  }
  await flconfDefaultConfig.create();

  final flconfDefaultConfigLines = <String>[
    '// Generated with flconf, DO NOT EDIT!!',
  ];
  defaults.forEach((key, value) {
    flconfDefaultConfigLines.add('$key=$value');
  });

  await flconfDefaultConfig.writeAsString(flconfDefaultConfigLines.join('\n'));

  final debugConfig = File(
      path.join(Directory.current.path, 'ios', 'Flutter', 'Debug.xcconfig'));
  final releaseConfig = File(
      path.join(Directory.current.path, 'ios', 'Flutter', 'Release.xcconfig'));

  /// Import config files. IMPORTANT: Flconf-defaults must be above Flconf in the imports, so that the
  /// values in Flconf can override the values in Flconf-defaults.
  final debugConfigLines = (await debugConfig.readAsString()).split('\n');
  final releaseConfigLines = (await releaseConfig.readAsString()).split('\n');

  /// Add imports to Release.xcconfig and Debug.xcconfig
  if (!debugConfigLines.contains('#include "Flconf-defaults.xcconfig"'))
    debugConfigLines.add('#include "Flconf-defaults.xcconfig"');
  if (!releaseConfigLines.contains('#include "Flconf-defaults.xcconfig"'))
    releaseConfigLines.add('#include "Flconf-defaults.xcconfig"');
  if (!debugConfigLines.contains('#include "Flconf.xcconfig"'))
    debugConfigLines.add('#include "Flconf.xcconfig"');
  if (!releaseConfigLines.contains('#include "Flconf.xcconfig"'))
    releaseConfigLines.add('#include "Flconf.xcconfig"');

  await debugConfig
      .writeAsString(debugConfigLines.join('\n').replaceAll('\n\n', '\n'));
  await releaseConfig
      .writeAsString(releaseConfigLines.join('\n').replaceAll('\n\n', '\n'));

  log('Generated ${flconfDefaultConfigLines.length} lines of boilerplate code at ${flconfDefaultConfig.path}');
}
