//  IMPORTANT:  This file is generated using flconf command line tools and the values provided in the configuration files. Do not edit manually.

/// Loads the config file name used to run the app.
const _configFileName = String.fromEnvironment('flconf-config-file-name');

/// This enum is generated from the files in flconf directory, so it represents all the available configurations for this app.
enum Config {
  dev,
  prod,
  unknown,
}

/// An extension to parse enum value from string
extension ConfigExtension on Config {
  static Config fromString(String input) {
    switch (input) {
      case 'dev':
        return Config.dev;
      case 'prod':
        return Config.prod;
      default:
        return Config.unknown;
    }
  }
}

/// This class is generated using flconf command line tools. It helps to access the values provided in the configuration files.
class FlConf {
  static final Config config = ConfigExtension.fromString(_configFileName);
  static bool get isDev => config == Config.dev;
  static bool get isProd => config == Config.prod;
}
