import 'dart:convert';
import 'dart:ui';
import 'package:simple_localization/simple_localization.dart';
import 'package:simple_localization/src/file_loaders/file_loader.dart';
import 'package:simple_localization/src/file_loaders/io_file_loader.dart';

/// abstract class used to building your Custom AssetLoader
/// Example:
/// ```
///class FileAssetLoader extends AssetLoader {
///  @override
///  Future<Map<String, dynamic>> load(String path, Locale locale) async {
///    final file = File(path);
///    return json.decode(await file.readAsString());
///  }
///}
/// ```
abstract class AssetLoader {
  const AssetLoader();

  Future<Map<String, dynamic>?> load(String path, Locale locale);
}

abstract class FileBasedAssetLoader extends AssetLoader {
  final FileLoader fileLoader;
  final LinkedFileResolver linkedFileResolver;

  const FileBasedAssetLoader({required this.linkedFileResolver, required this.fileLoader});
}

///
/// default used is RootBundleAssetLoader which uses flutter's assetloader
///
class RootBundleAssetLoader extends FileBasedAssetLoader {
  const RootBundleAssetLoader({required LinkedFileResolver linkedFileResolver, required FileLoader fileLoader})
      : super(linkedFileResolver: linkedFileResolver, fileLoader: fileLoader);

  factory RootBundleAssetLoader.fromRootBundle() {
    return const RootBundleAssetLoader(
      linkedFileResolver: JsonLinkedFileResolver(fileLoader: RootBundleFileLoader()),
      fileLoader: RootBundleFileLoader(),
    );
  }

  factory RootBundleAssetLoader.fromIOFile() {
    return const RootBundleAssetLoader(
      linkedFileResolver: JsonLinkedFileResolver(fileLoader: IOFileLoader()),
      fileLoader: IOFileLoader(),
    );
  }

  String getLocalePath(String basePath, Locale locale) {
    return '$basePath/${locale.toStringWithSeparator(separator: "-")}.json';
  }

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    var localePath = getLocalePath(path, locale);
    SimpleLocalization.logger.debug('Load asset from $path');

    Map<String, dynamic> baseJson = json.decode(await fileLoader.loadString(localePath));
    return await linkedFileResolver.resolveLinkedFiles(
      basePath: path,
      languageCode: locale.languageCode,
      countryCode: locale.countryCode,
      baseJson: baseJson,
    );
  }
}
