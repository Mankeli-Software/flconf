import 'dart:io';
import 'package:flconf/helpers/logger.dart';

/// Prints the help messages
void help(List<String> args) {
  log('To initialize a single config set, run: flconf init <configname>');
  log('To initialize multiple config sets at once, run: flconf init <configname1> <configname2> <configname3> ...');
  log('To generate boilerplate dart classes, run: flconf generate');
  log('To run/build/drive from config file: flconf <run/build/drive> <configname> <extra flutter parameters>');
  exit(0);
}
