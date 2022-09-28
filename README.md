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
Generate boilerplate dart code at `lib/generated/flconf.dart`:
```
flconf generate
```
Run the app using a configuration:
```
flconf run <configname>
```

## Example
The following command will create `dev.json` and `prod.json` inside `flconf` folder at the root of the project:
```
flconf init dev prod
```

You can then run from one of these configs:
```
flconf run dev
```
