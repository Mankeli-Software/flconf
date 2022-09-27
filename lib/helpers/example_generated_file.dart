//  IMPORTANT:  This file is generated using flconf command line tools and the values provided in the configuration files. Do not edit manually.

/// Loads the config file name used to run the app.
const _configFileName = String.fromEnvironment('flconf-config-file-name');

/// This enum is generated from the files in flconf directory, so it represents all the available configurations for this app.
enum Config {
  mapventureB2bDev,
  mapventureB2bProd,
  mapventureDev,
  mapventureProd,
  unknown,
}

/// An extension to parse enum value from string
extension ConfigExtension on Config {
  static Config fromString(String input) {
    switch (input) {
      case 'Config.mapventureB2bDev':
        return Config.mapventureB2bDev;
      case 'Config.mapventureB2bProd':
        return Config.mapventureB2bProd;
      case 'Config.mapventureDev':
        return Config.mapventureDev;
      case 'Config.mapventureProd':
        return Config.mapventureProd;
      default:
        return Config.unknown;
    }
  }
}

/// This class is generated using flconf command line tools. It helps to access the values provided in the configuration files.
class FlConf {
  static final Config config = ConfigExtension.fromString(_configFileName);
  static const String configFileName = String.fromEnvironment('flconf-configFileName');

  static const String version = String.fromEnvironment('flconf-version');
}
