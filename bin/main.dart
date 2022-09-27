import 'dart:developer';
import 'dart:io';

import 'package:flconf/commands/build.dart';
import 'package:flconf/commands/drive.dart';
import 'package:flconf/commands/generate.dart';
import 'package:flconf/commands/help.dart';
import 'package:flconf/commands/init.dart';
import 'package:flconf/commands/run.dart';

void main(List<String> arguments) {
  final args = List<String>.from(arguments);
  final command = args.removeAt(0);

  switch (command) {
    case '-h':
      help(args);
      break;
    case 'init':
      init(args);
      break;
    case 'run':
      run(args);
      break;
    case 'build':
      build(args);
      break;
    case 'drive':
      drive(args);
      break;
    case 'generate':
      generate(args);
      break;
    default:
      log('Run flconf -h for usage instructions');
      exit(1);
  }
}
