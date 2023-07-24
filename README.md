
# Playx Localization
[![pub package](https://img.shields.io/pub/v/playx_localization.svg?color=1284C5)](https://pub.dev/packages/playx_localization)

Easily manage and update app localization with a simple implementation and a lot of utilities.

# Features 🔥
- Create and mange app locales with the ability to easily change app locale.
- No need for `BuildContext`  anymore.
- Supports dart isolates and background.
- Load translations as JSON, CSV, Yaml, Xml.
-  React and persist to locale changes
-  Supports plural, gender, nesting, RTL locales and more
-  Fallback locale keys redirection.


## Installation

in `pubspec.yaml` add these lines to `dependencies`

```yaml
 playx_localization: ^0.0.1
```   
Create folder and add translation files like this

```bash
assets
└── translations
    ├── {languageCode}.{ext}                  //only language code
    └── {languageCode}-{countryCode}.{ext}    //or full locale code

```

Example:

```markdown
assets
└── translations
    ├── en.json
    └── en-US.json 

```

Declare your assets localization directory in  `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/translations/

```

### Loading translations from other resources[](https://pub.dev/packages/easy_localization#-loading-translations-from-other-resources)

You can use JSON,CSV,HTTP,XML,Yaml files, etc.

See  [Easy Localization Loader](https://github.com/aissat/easy_localization_loader)  for more info.

### ⚠️ Note on  **iOS**[](https://pub.dev/packages/easy_localization#-note-on-ios)

For translation to work on  **iOS**  you need to add supported locales to  `ios/Runner/Info.plist`  as described  [here](https://flutter.dev/docs/development/accessibility-and-localization/internationalization#specifying-supportedlocales).

Example:

```xml
<key>CFBundleLocalizations</key>
<array>
	<string>en</string>
	<string>ar</string>
</array>

```


## Usage

###  🔥  Create Locale configuration.
create your own locale configuration with settings like supported locales, start locale, path to translations and more.

```dart
class AppLocaleConfig extends XLocaleConfig{

  AppLocaleConfig() : super(path: 'assets/translations',);

  @override
  List<XLocale> get supportedLocales => [
    //Make sure your passing language code and country code same as in your translation folder as described above.
    const XLocale(id: 'en', name: 'English', languageCode: 'en', countryCode: 'US'),
    const XLocale(id: 'ar', name: 'العربية', languageCode: 'ar'),
  ];

  @override
  XLocale? get startLocale => supportedLocales[0];

  @override
  XLocale? get fallbackLocale => supportedLocales[0];

}
```



###  🔥  Boot the core

```dart  
 void main ()async{  
 WidgetsFlutterBinding.ensureInitialized();  
   
   // boot playx core package.  
   await PlayXCore.bootCore();  

  /// boot PlayxLocalization with your locale configuration.  
  await PlayxLocalization.boot(config: AppLocaleConfig());
  
  /// run the app wrapped with PlayxLocalizationBuilder widget.
  runApp(PlayxLocalizationBuilder(
    builder: (XLocale xLocale) {
      return const MyApp();
    },
  ));
}  
```  

###   🔥 Define your `Material App` or `GetMaterialApp` as below :

```dart  
class MyApp extends StatelessWidget {  
  const MyApp({super.key});  
  
  @override  
  Widget build(BuildContext context) {  
  return MaterialApp(  
       supportedLocales: PlayxLocalization.supportedLocales,  
       localizationsDelegates: PlayxLocalization.localizationDelegates,  
       locale: PlayxLocalization.currentLocale,  
       home: const MyHomePage(),  
    );  
   }  
 }
```  



###  🔥  XLocaleConfig properties :

| Properties              | Required | Default                   | Description                                                                                                                                                                   |
| ----------------------- | -------- | ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| supportedLocales        | true     |                           | List of supported x locales.                                                                                                                                                    |
| path                    | false    | 'assets/translations'    | Path to your folder with localization files.                                                                                                                                  |
| assetLoader             | false    | `RootBundleAssetLoader()` | Class loader for localization files. You can use custom loaders from [Easy Localization Loader](https://github.com/aissat/easy_localization_loader) or create your own class. |
| fallbackLocale          | false    |                           | Returns the x locale when the locale is not in the list `supportedLocales`.                                                                                                     |
| startLocale             | false    |                           | First Locale that the app starts with, if there is not any saved locale. If equals null then it uses device locale.                                                                                                                                                      |
| saveLocale              | false    | `true`                    | Save locale in device storage.                                                                                                                                                |
| useFallbackTranslations | false    | `true`                   | If a localization key is not found in the locale file, try to use the fallbackLocale file.                                                                                    |
| useOnlyLangCode         | false    | `false`                   | Trigger for using only language code for reading localization files.</br></br>Example:</br>`en.json //useOnlyLangCode: true`</br>`en-US.json //useOnlyLangCode: false`        |

###  🔥 Update App Locale

#### Use `PlayxLocalization` facade to switch between locales.

With `PlayxLocalization` you will have access to current app locale, it's index, name and id.
You can change current app locale to the next Locale, by id, by index, by device locale and more.

```dart   
   FloatingActionButton.extended(
        onPressed: () {
        //updates locale by index
          PlayxLocalization.updateByIndex(
              PlayxLocalization.isCurrentLocaleArabic() ? 0 : 1);
        },
        //label text changes after updating locale.
        label: Text('change_language'.tr),
        icon: const Icon(Icons.update),
      )
  ```  



### 🔥 Translate `tr()`

#### The package uses [`Easy Localization`](https://pub.dev/packages/easy_localization) under the hood to manage translations and Plurals as below.

Main function for translate your language keys

You can use extension methods of [String] or [Text] widget, you can also use `tr()` as a static function.

```dart
Text('title').tr() //Text widget

print('title'.tr)); //String

var title = tr('title') //Static function

Text(context.tr('title')) //Extension on BuildContext
```

#### Arguments:

| Name      | Type                  | Description                                                                         |
| --------- | --------------------- | ----------------------------------------------------------------------------------- |
| args      | `List<String>`        | List of localized strings. Replaces `{}` left to right                              |
| namedArgs | `Map<String, String>` | Map of localized strings. Replaces the name keys `{key_name}` according to its name |
| gender    | `String`              | Gender switcher. Changes the localized string based on gender string                |

Example:

``` json
{
   "msg":"{} are written in the {} language",
   "msg_named":"Easy localization is written in the {lang} language",
   "msg_mixed":"{} are written in the {lang} language",
   "gender":{
      "male":"Hi man ;) {}",
      "female":"Hello girl :) {}",
      "other":"Hello {}"
   }
}
```

```dart
// args
Text('msg').tr(args: ['Easy localization', 'Dart']),

// namedArgs
Text('msg_named').tr(namedArgs: {'lang': 'Dart'}),

// args and namedArgs
Text('msg_mixed').tr(args: ['Easy localization'], namedArgs: {'lang': 'Dart'}),

// gender
Text('gender').tr(gender: _gender ? "female" : "male"),

```

### 🔥 Plurals `plural()`

You can translate with pluralization.
To insert a number in the translated string, use `{}`. Number formatting supported, for more information read [NumberFormat](https://pub.dev/documentation/intl/latest/intl/NumberFormat-class.html) class documentation.

You can use extension methods of [String] or [Text] widget, you can also use `plural()` as a static function.

#### Arguments:

| Name      | Type                  | Description                                                                                                                  |
| --------- | --------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| value     | `num`                 | Number value for pluralization                                                                                               |
| args      | `List<String>`        | List of localized strings. Replaces `{}` left to right                                                                       |
| namedArgs | `Map<String, String>` | Map of localized strings. Replaces the name keys `{key_name}` according to its name                                          |
| name      | `String`              | Name of number value. Replaces `{$name}` to value                                                                            |
| format    | `NumberFormat`        | Formats a numeric value using a [NumberFormat](https://pub.dev/documentation/intl/latest/intl/NumberFormat-class.html) class |

Example:

``` json
{
  "day": {
    "zero":"{} дней",
    "one": "{} день",
    "two": "{} дня",
    "few": "{} дня",
    "many": "{} дней",
    "other": "{} дней"
  },
  "money": {
    "zero": "You not have money",
    "one": "You have {} dollar",
    "many": "You have {} dollars",
    "other": "You have {} dollars"
  },
  "money_args": {
    "zero": "{} has no money",
    "one": "{} has {} dollar",
    "many": "{} has {} dollars",
    "other": "{} has {} dollars"
  },
  "money_named_args": {
    "zero": "{name} has no money",
    "one": "{name} has {money} dollar",
    "many": "{name} has {money} dollars",
    "other": "{name} has {money} dollars"
  }
}
```
⚠️ Key "other" required!

```dart
//Text widget with format
Text('money').plural(1000000, format: NumberFormat.compact(locale: context.locale.toString())) // output: You have 1M dollars

//String
print('day'.plural(21)); // output: 21 день

//Static function
var money = plural('money', 10.23) // output: You have 10.23 dollars

//Text widget with plural BuildContext extension
Text(context.plural('money', 10.23))

//Static function with arguments
var money = plural('money_args', 10.23, args: ['John', '10.23'])  // output: John has 10.23 dollars

//Static function with named arguments
var money = plural('money_named_args', 10.23, namedArgs: {'name': 'Jane', 'money': '10.23'})  // output: Jane has 10.23 dollars
var money = plural('money_named_args', 10.23, namedArgs: {'name': 'Jane'}, name: 'money')  // output: Jane has 10.23 dollars
```

### 🔥 Linked translations:

If there's a translation key that will always have the same concrete text as another one you can just link to it. To link to another translation key, all you have to do is to prefix its contents with an `@:` sign followed by the full name of the translation key including the namespace you want to link to.

Example:
```json
{
  "example": {
    "hello": "Hello",
    "world": "World!",
    "helloWorld": "@:example.hello @:example.world"
  }
}
```

```dart
print('example.helloWorld'.tr()); //Output: Hello World!
```

You can also do nested anonymous and named arguments inside the linked messages.

Example:

```json
{
  "date": "{currentDate}.",
  "dateLogging": "INFO: the date today is @:date"
}
```
```dart
print(tr('dateLogging', namedArguments: {'currentDate': DateTime.now().toIso8601String()})); //Output: INFO: the date today is 2020-11-27T16:40:42.657.
```

#### Formatting linked translations:

Formatting linked locale messages
If the language distinguishes cases of character, you may need to control the case of the linked locale messages. Linked messages can be formatted with modifier `@.modifier:key`

The below modifiers are available currently.

- `upper`: Uppercase all characters in the linked message.
- `lower`: Lowercase all characters in the linked message.
- `capitalize`: Capitalize the first character in the linked message.

Example:

```json
{
  ...
  "example": {
    "fullName": "Full Name",
    "emptyNameError": "Please fill in your @.lower:example.fullName"
  }
  ...
}
```

Output:

```dart
print('example.emptyNameError'.tr()); //Output: Please fill in your full name
```

### 🔥 Get device locale `deviceLocale`

Get device locale

Example:

```dart
print(${PlayxLocalization.deviceLocale.toString()}) // OUTPUT: en_US
```

### 🔥 Delete save locale `deleteSaveLocale()`

Clears a saved locale from device storage

Example:

```dart
RaisedButton(
  onPressed: (){
    PlayxLocalization.deleteSaveLocale();
  },
  child: Text(LocaleKeys.reset_locale).tr(),
)
```


### 🔥``PlayxLocalization`` available methods :

| Method           | Description                                                |
| -----------      | :--------------------------------------------------------  |
| currentIndex     | Get current `XLocale` index.                                |
| currentXLocale   | Get current `XLocale`.                                      | 
| currentLocale    | Get current locale.                                    |
| deviceLocale     | Get current device locale.                                      |
| nextLocale       | updates the app locale to the next locale .                   |
| updateByIndex    | updates the app locale by the index.                        |
| updateById       | updates the app locale by the `XLocale` id.                        |
| updateTo         | updates the app locale to a specific `XLocale`.              |
| updateToDeviceLocale | Updates the app locale to current device locale.              |
| updateByLanguageCode | updates the app locale by language code and country code if available              |
| supportedXLocales| Get current supported x locales configured in `XLocaleConfig `. |
| supportedLocales| Get current supported locales of `supportedXLocales`.                         |
| isCurrentLocaleArabic| Check if current locale is arabic.                         |
| isCurrentLocaleEnglish| Check if current locale is english.                        |
| deleteSavedLocale| Deletes saved locale from device storage.                         |



### 🔥 Extensions & utilities

The package include other extensions and utitlies that can be helpful for development.

For Example:

#### Convert Date to formated and localized String using:

```dart
  final dateText = DateTime.now().toFormattedDate(
      format: 'yyyy-MM-dd',
      locale: PlayxLocalization.currentLocale.toStringWithSeparator());

  print('Curent date: $dateText');
```

#### There is also other extensions on nubmer 
| Method           | Description                                                |
| -----------      | :--------------------------------------------------------  |
| roundToPrecision     | Extension function to round number to certain number.   |
| toFormattedCurrencyNumber   | Extension function to format number to currency number.     | 
| toFormattedNumber    | Extension function to format number to  String.           |




## Documentation && References

-   [Easy Localization](https://pub.dev/packages/easy_localization), The app uses the easy localization package under the hood to load translations.
- [Documentaion](https://pub.dev/packages/playx_localization#documentation--references)


## See Also:
[Playx](https://pub.dev/packages/playx) : Playx eco system helps with redundant features , less code , more productivity , better organizing.

[playx_core](https://pub.dev/packages/playx_core) : core package of playx.

[playx_theme](https://pub.dev/packages/playx_theme) : Multi theme features for flutter apps from playx eco system.

[playx_widget](https://pub.dev/packages/playx_widget) : PlayX widget package for playx eco system that provide custom utility widgets to make development faster.

[playx_version_update](https://pub.dev/packages/playx_version_update) : Easily show material update dialog in Android or Cupertino dialog in IOS with support for Google play in app updates.

[playx_network](https://pub.dev/packages/playx_network) :  Wrapper around Dio that can perform api request with better error handling and easily get the result of any api request.

x 
