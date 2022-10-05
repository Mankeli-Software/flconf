## flconf CLI tool
This dart CLI tool makes it easy to run your flutter apps from different configuration sets. It can be used to differentiate development and production environments, or to build multiple apps with different native configurations (bundle ids, names, application ids) from single codebase. 

## How it works?
flconf reads the configuration from the config files, and passes the variables to the flutter commands using --dart-define. 

## Get started
Install flconf:
```
dart pub global activate flconf
```

Initialize flconf:
```
flconf init <configname1> <configname2>
```
Generate boilerplate code (IMPORTANT: this needs to be run every time you update the configurations):
```
flconf generate
```
Run the app using a configuration:
```
flconf run <configname>
```

## Naming the config variables and files
When naming config variables, please use uppercase characters and underscores for spaces. For example: `ANDROID_APP_ID` would be a good variable name. 

When naming configurations, please use underscores for spaces. For example `dev` or `dev_conf` would both be good configuration names.

## Example
The following command will create `dev.json` and `prod.json` inside `flconf` folder at the root of the project:
```
flconf init dev prod
```

You can then run from one of these configs:
```
flconf run dev
```

## How to read the configurations inside flutter, ios and android?

### Dart
When running `flconf generate`, a boilerplate file will be generated at `lib/generated/flconf.dart`. This file
contains a class that has variables for each variable defined in config files. 

### Android
When running `flconf generate`, all the necessary boilerplate files will be created for you. Now you can access the variables in `app/build.gradle` like so: `flconfVariables.FLCONF_<VARIABLE_NAME>`. For example:
```
    defaultConfig {
        applicationId flconfVariables.FLCONF_ANDROID_APP_ID
        applicationIdSuffix flconfVariables.FLCONF_ANDROID_APP_ID_SUFFIX
        minSdkVersion 23
        compileSdkVersion 31
        targetSdkVersion 31
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
```

In other android files (for example `AndroidManifest.xml` files), you can access the variables like so: `"@string/FLCONF_<VARIABLE_NAME>"`. For example:
```
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="@string/FLCONF_ANDROID_APP_ID">
</manifest>

```

### IOS
When running `flconf generate`, most of the necessary boilerplate files will be generated for you. However, you need to add a pre-action shell script in Xcode to be able to read the configurations inside IOS config. To add the script, follow these steps:
1. Press `Cmd + <` in Xcode
2. Go to `Build > Pre-actions`
3. Add new Run Script Action
4. Paste the following script:
```
# Type a script or drag a script file from your workspace to insert its path.

function entry_decode() { echo "${*}" | base64 --decode; }

IFS=',' read -r -a define_items <<< "$DART_DEFINES"


for index in "${!define_items[@]}"
do
    define_items[$index]=$(entry_decode "${define_items[$index]}");
done

printf "%s\n" "${define_items[@]}"|grep '^FLCONF_' > ${SRCROOT}/Flutter/Flconf.xcconfig
```
5. You are all set!

After following these steps, you can read the configuration anywhere like so: `${FLCONF_<VARIABLE_NAME>}`. For example in `Info.plist`:
```
		<key>CFBundleIdentifier</key>
		<string>$(FLCONF_IOS_BUNDLE_ID)</string>
```
