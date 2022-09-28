import 'dart:io';
import 'package:path/path.dart' as path;
import 'logger.dart';
import 'dart:convert';

/// Parses the config file and returns the config as list of --dart-define variables (flutter CLI arguments)
Future<List<String>> getDartDefines(String configName) async {
  // Adds the file type to the name (if not provided)
  if (!configName.endsWith('.json')) configName += '.json';

  final output = [
    '--dart-define=flconf-config-file-name=${configName.split('.').first}'
  ];

  log('Running with config $configName');

  // Loads the config file
  final confFilePath = path.join(Directory.current.path, 'flconf', configName);
  final confFile = File(confFilePath);

  if (!await confFile.exists()) {
    logError('Configuration file not found at $confFilePath');
    exit(1);
  }

  // Converts the config to easily readable format (Map)
  final confString = await confFile.readAsString();
  final confMap = json.decode(confString) as Map;

  /// Iterates through the config and adds the --dart-define variables to the output list
  confMap.forEach((key, value) {
    // Uses 'flconf-' prefix to avoid conflicts with other variables
    output.add('--dart-define=flconf-$key=$value');
  });

  return output;
}
