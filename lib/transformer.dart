library sass.transformer;

import 'dart:async';

import 'package:barback/barback.dart';
import 'package:path/path.dart';
import 'sass.dart';
import 'src/transformer_options.dart';
import 'dart:isolate';

/// Transformer used by `pub build` and `pub serve` to convert Sass-files to CSS.
class SassTransformer extends AggregateTransformer {
  SassTransformer.asPlugin(BarbackSettings settings)
      : options = new TransformerOptions(settings.configuration),
        mode = settings.mode;

  final TransformerOptions options;

  final BarbackMode mode;

  // Only process assets where the extension is ".scss" or ".sass".
  classifyPrimary(AssetId id) =>
      ['.scss', '.sass'].any((e) => e == id.extension) ? id.extension : null;

  Future apply(AggregateTransform transform) async {
    var assets = await transform.primaryInputs.toList();

    return Future.wait(assets.map((asset) async {
      var id = asset.id;

      // files excluded of entry_points are not processed
      // if user don't specify entry_points, the default value is all '*.sass' and '*.html' files
      if (basename(id.path).startsWith('_')) {
        // if asset is not an entry point it wild be consumed
        // (this is to no output scss files in build folder)
        if (mode == BarbackMode.RELEASE) transform.consumePrimary(id);
        return;
      }

      var content = await transform.readInputAsString(id);
      print('[sass_transformer] processing: ${id}');

      var regExp = new RegExp(r'@import \"packages/(\w+)(.*)/(\w+)\";');
      content = await content.replaceAllMapped(regExp, (match) async {
        final s = 'package:${match.group(1)}${match.group(2)}/_${match.group(3)}.scss';
        // TODO return string not a Future
        var uri =  await Isolate.resolvePackageUri(Uri.parse(s));
        return '@import "${s}";';
      });

      //TODO: add support for no-symlinks packages
      options.includePaths
          .add(dirname(id.path).replaceFirst('lib', 'packages/${id.package}'));
      if (mode == BarbackMode.DEBUG)
        print('[sass_transformer] includePaths: ${options.includePaths}');
      try {
        var output = await (new Sass()
              ..scss = id.extension == '.scss'
              ..loadPath = options.includePaths
              ..executable = options.executable
              ..compass = options.compass)
            .transform(content);
        var newId = id.changeExtension('.css');
        transform.addOutput(new Asset.fromString(newId, output));
        // (this is to no output scss files in build folder)
        if (mode == BarbackMode.RELEASE) transform.consumePrimary(id);
      } catch (e) {
        print(e);
      }
    }));
  }
}
