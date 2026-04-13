import 'dart:async';

import 'package:simple_localization/simple_localization.dart';
import 'package:simple_localization/src/simple_localization_controller.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'localization.dart';

part 'utils.dart';

///  SimpleLocalization
///  example:
///  ```
///  void main(){
///    runApp(SimpleLocalization(
///      child: MyApp(),
///      supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
///      path: 'resources/langs/langs.csv',
///      assetLoader: CsvAssetLoader()
///    ));
///  }
///  ```
class SimpleLocalization extends StatefulWidget {
  /// Place for your main page widget.
  final Widget child;

  /// List of supported locales.
  /// {@macro flutter.widgets.widgetsApp.supportedLocales}
  final List<Locale> supportedLocales;

  /// Locale when the locale is not in the list
  final Locale? fallbackLocale;

  /// Overrides device locale.
  final Locale? startLocale;

  /// Trigger for using only language code for reading localization files.
  /// @Default value false
  /// Example:
  /// ```
  /// en.json //useOnlyLangCode: true
  /// en-US.json //useOnlyLangCode: false
  /// ```
  final bool useOnlyLangCode;

  /// If a localization key is not found in the locale file, try to use the fallbackLocale file.
  /// @Default value false
  /// Example:
  /// ```
  /// useFallbackTranslations: true
  /// ```
  final bool useFallbackTranslations;

  /// If a localization key is empty in the locale file, try to use the fallbackLocale file.
  /// Does not take effect if [useFallbackTranslations] is false.
  /// @Default value false
  /// Example:
  /// ```
  /// useFallbackTranslationsForEmptyResources: true
  /// ```
  final bool useFallbackTranslationsForEmptyResources;

  /// Ignore usage of plural strings for languages that do not use plural rules.
  /// @Default value false
  /// Example:
  /// ```
  /// // Default behavior, use "zero" rule for 0 even if the language doesn't
  /// // use it by default (e.g. "en"). If "zero" localization for that string
  /// // doesn't exist, "other" is still used as fallback.
  /// // "nTimes": "{count, plural, =0{never} =1{once} other{{count} times}}"
  /// // Text(AppLocalizations.of(context)!.nTimes(_counter)),
  /// // will print "never, once, 2 times" for ALL languages.
  /// ignorePluralRules: true
  /// // Use "zero" rule for 0 only if the language is set to do so (e.g. for
  /// "lt" but not for "en").
  /// // "nTimes": "{count, plural, =0{never} =1{once} other{{count} times}}"
  /// // Text(AppLocalizations.of(context)!.nTimes(_counter)),
  /// // will print "never, once, 2 times" ONLY for languages with plural rules.
  /// ignorePluralRules: false
  /// ```
  final bool ignorePluralRules;

  /// Path to your folder with localization files.
  /// Example:
  /// ```dart
  /// path: 'assets/translations',
  /// path: 'assets/translations/lang.csv',
  /// ```
  final String path;

  /// Class loader for localization files.
  /// You can use custom loaders from [Simple Localization Loader](https://github.com/aissat/simple_localization_loader) or create your own class.
  /// @Default value `const RootBundleAssetLoader()`
  // ignore: prefer_typing_uninitialized_variables
  final AssetLoader assetLoader;

  /// Class loader for localization files that belong to other packages.
  /// You can use custom loaders from [Simple Localization Loader](https://github.com/aissat/simple_localization_loader) or create your own class.
  /// Example:
  /// ```dart
  //   runApp(
  //   SimpleLocalization(
  //     supportedLocales: const <Locale>[
  //       Locale('en'),
  //     ],
  //     fallbackLocale: const Locale('en'),
  //     assetLoader: const RootBundleAssetLoader(),
  //     extraAssetLoaders: [
  //         TranslationsLoader(packageName: 'package_example_1'),
  //         TranslationsLoader(packageName: 'package_example_2'),
  //     ],
  //     path: 'lib/l10n/translations',
  //     child: const MainApp(),
  //   ),
  // );
  /// @Default value `null`
  final List<AssetLoader>? extraAssetLoaders;

  /// Save locale in device storage.
  /// @Default value true
  final bool saveLocale;

  /// Shows a custom error widget when an error is encountered instead of the default error widget.
  /// @Default value `errorWidget = ErrorWidget()`
  final Widget Function(FlutterError? message)? errorWidget;

  SimpleLocalization({
    Key? key,
    required this.child,
    required this.supportedLocales,
    required this.path,
    this.fallbackLocale,
    this.startLocale,
    this.useOnlyLangCode = false,
    this.useFallbackTranslations = false,
    this.useFallbackTranslationsForEmptyResources = false,
    this.ignorePluralRules = true,
    this.assetLoader = const RootBundleAssetLoader(
      fileLoader: RootBundleFileLoader(),
      linkedFileResolver: JsonLinkedFileResolver(fileLoader: RootBundleFileLoader()),
    ),
    this.extraAssetLoaders,
    this.saveLocale = true,
    this.errorWidget,
  })  : assert(supportedLocales.isNotEmpty),
        assert(path.isNotEmpty),
        super(key: key) {
    SimpleLocalization.logger.debug('Start');
  }

  @override
  // ignore: library_private_types_in_public_api
  _SimpleLocalizationState createState() => _SimpleLocalizationState();

  // ignore: library_private_types_in_public_api
  static _SimpleLocalizationProvider? of(BuildContext context) => _SimpleLocalizationProvider.of(context);

  /// ensureInitialized needs to be called in main
  /// so that savedLocale is loaded and used from the
  /// start.
  static Future<void> ensureInitialized() async => await SimpleLocalizationController.initEasyLocation();

  /// Customizable logger
  static EasyLogger logger = EasyLogger(name: '🌎 Simple Localization');
}

class _SimpleLocalizationState extends State<SimpleLocalization> {
  _SimpleLocalizationDelegate? delegate;
  SimpleLocalizationController? localizationController;
  FlutterError? translationsLoadError;

  @override
  void initState() {
    SimpleLocalization.logger.debug('Init state');
    localizationController = SimpleLocalizationController(
      saveLocale: widget.saveLocale,
      fallbackLocale: widget.fallbackLocale,
      supportedLocales: widget.supportedLocales,
      startLocale: widget.startLocale,
      assetLoader: widget.assetLoader,
      extraAssetLoaders: widget.extraAssetLoaders,
      useOnlyLangCode: widget.useOnlyLangCode,
      useFallbackTranslations: widget.useFallbackTranslations,
      path: widget.path,
      onLoadError: (FlutterError e) {
        setState(() {
          translationsLoadError = e;
        });
      },
    );
    // causes localization to rebuild with new language
    localizationController!.addListener(() {
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    localizationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SimpleLocalization.logger.debug('Build');
    if (translationsLoadError != null) {
      return widget.errorWidget != null
          ? widget.errorWidget!(translationsLoadError)
          : ErrorWidget(translationsLoadError!);
    }
    return _SimpleLocalizationProvider(
      widget,
      localizationController!,
      delegate: _SimpleLocalizationDelegate(
        localizationController: localizationController,
        supportedLocales: widget.supportedLocales,
        useFallbackTranslationsForEmptyResources: widget.useFallbackTranslationsForEmptyResources,
        ignorePluralRules: widget.ignorePluralRules,
      ),
    );
  }
}

class _SimpleLocalizationProvider extends InheritedWidget {
  final SimpleLocalization parent;
  final SimpleLocalizationController _localeState;
  final Locale? currentLocale;
  final _SimpleLocalizationDelegate delegate;
  final bool _translationsLoaded;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  ///
  /// ```dart
  ///   delegates = [
  ///     delegate
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///     GlobalCupertinoLocalizations.delegate
  ///   ],
  /// ```
  List<LocalizationsDelegate> get delegates => [
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  /// Get List of supported locales
  List<Locale> get supportedLocales => parent.supportedLocales;

  // _SimpleLocalizationDelegate get delegate => parent.delegate;

  _SimpleLocalizationProvider(this.parent, this._localeState, {Key? key, required this.delegate})
      : currentLocale = _localeState.locale,
        _translationsLoaded = _localeState.translations != null,
        super(key: key, child: parent.child) {
    SimpleLocalization.logger.debug('Init provider');
  }

  /// Get current locale
  Locale get locale => _localeState.locale;

  /// Get fallback locale
  Locale? get fallbackLocale => parent.fallbackLocale;

  // Locale get startLocale => parent.startLocale;

  /// Change app locale
  Future<void> setLocale(Locale locale) async {
    // Check old locale
    if (locale != _localeState.locale) {
      assert(parent.supportedLocales.contains(locale));
      await _localeState.setLocale(locale);
    }
  }

  /// Clears a saved locale from device storage
  Future<void> deleteSaveLocale() async {
    await _localeState.deleteSaveLocale();
  }

  /// Getting device locale from platform
  Locale get deviceLocale => _localeState.deviceLocale;
  Locale? get savedLocale => _localeState.savedLocale;

  /// Reset locale to platform locale
  Future<void> resetLocale() => _localeState.resetLocale();

  @override
  bool updateShouldNotify(_SimpleLocalizationProvider oldWidget) {
    return oldWidget.currentLocale != locale || oldWidget._translationsLoaded != _translationsLoaded;
  }

  static _SimpleLocalizationProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SimpleLocalizationProvider>();
}

class _SimpleLocalizationDelegate extends LocalizationsDelegate<Localization> {
  final List<Locale>? supportedLocales;
  final SimpleLocalizationController? localizationController;
  final bool useFallbackTranslationsForEmptyResources;
  final bool ignorePluralRules;

  ///  * use only the lang code to generate i18n file path like en.json or ar.json
  // final bool useOnlyLangCode;

  _SimpleLocalizationDelegate({
    required this.useFallbackTranslationsForEmptyResources,
    this.ignorePluralRules = true,
    this.localizationController,
    this.supportedLocales,
  }) {
    SimpleLocalization.logger.debug('Init Localization Delegate');
  }

  @override
  bool isSupported(Locale locale) => supportedLocales!.contains(locale);

  @override
  Future<Localization> load(Locale value) async {
    SimpleLocalization.logger.debug('Load Localization Delegate');
    if (localizationController!.translations == null) {
      await localizationController!.loadTranslations();
    }

    Localization.load(
      value,
      translations: localizationController!.translations,
      fallbackTranslations: localizationController!.fallbackTranslations,
      useFallbackTranslationsForEmptyResources: useFallbackTranslationsForEmptyResources,
      ignorePluralRules: ignorePluralRules,
    );
    return Future.value(Localization.instance);
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => false;
}
