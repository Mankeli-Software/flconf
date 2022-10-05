import 'dart:io';
import 'package:flconf/helpers/logger.dart';
import 'package:flconf/helpers/validators.dart';
import 'package:path/path.dart' as path;

/// Creates a config set from the given config files
Future init(List<String> args) async {
  if (args.isEmpty) {
    log('To initialize a single config set, run: flconf init <configname>');
    log('To initialize multiple config sets at once, run: flconf init <configname1> <configname2> <configname3> ...');
    exit(1);
  }

  args.add('defaults');

  /// Validates the given file names
  for (var arg in args) {
    if (!validateConfigFileName(arg)) {
      logError(
          'Config file name "$arg" is not valid. Config file names must be alphanumeric (with underscores as spaces) and it cannot start with a number.');
      exit(1);
    }
  }

  await Future.wait(
    args.map(
      (configname) async {
        if (!configname.endsWith('.json')) configname += '.json';
        final confFile =
            File(path.join(Directory.current.path, 'flconf', '$configname'));
        if (!await confFile.exists()) {
          await confFile.create(recursive: true);
          await confFile.writeAsString('{}');
        }
      },
    ),
  );

  log('Initialized ${args.length} configuration file(s)');

  exit(0);
}
