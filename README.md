[![Build Status](https://travis-ci.org/dart-league/sass_transformer.svg?branch=master)](https://travis-ci.org/dart-league/sass_transformer)

## Sass integration for pub

[Sass](http://sass-lang.com/)-transformer for [pub-serve](http://pub.dartlang.org/doc/pub-serve.html) and
[pub-build](http://pub.dartlang.org/doc/pub-build.html).

## Usage

1\. Install [Sass](http://sass-lang.com/) and add it to your path.

2\. Add the following lines to your `pubspec.yaml`:

```yaml
dependencies:
  sass_transformer: any
transformers:
  - sass_transformer
```

After adding the transformer, all your `.sass` and `.scss` files that don't begin with `_` will be automatically transformed to
corresponding `.css` files.

If your main file imports other files outside the main files folder, you need to add the option `include_paths`,
 to let `sass` know which folder will be used for processing outside imports:

```yaml
dependencies:
  sass: any
transformers:
  - sass:
      include_paths: path/to/folder/with/other/scss
```

you can have multiple `include_paths`:

```yaml
dependencies:
  sass_transformer: any
transformers:
  - sass_transformer:
      include_paths:
        - path/to/folder/with/other/scss1
        - path/to/folder/with/other/scss2
```

> By using `pub serve` during development, css files are going to live in memory only.
 Executing `pub build` creates actual css files in build folder

3\. Finally in the html files you only need to import the generated css files:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="stylesheet" href="path/to/main.css">
</head>
<body>
    <!-- content goes hear -->
</body>
</html>
```

## Configuration

You can also pass options to Sass if necessary:

```yaml
transformers:
  - sass_transformer:
      executable: /path/to/sass     # Sass executable to use
      compass: true                 # Include compass
      line_numbers: true            # Include line numbers in output
      style: compact                # Style of generated CSS
      copy_sources: true            # Copy original .scss/.sass files to output directory
```

## Using SassC

You can use [SassC](https://github.com/hcatlin/sassc) instead of normal Sass by specifying executable
as 'sassc' (or any path ending with 'sassc'):

```yaml
transformers:
  - sass_transformer:
      executable: sassc  # or /path/to/sassc
```

SassC only supports `.scss`-files and does not support Compass.

## Current limitations

- UTF8-encoding is assumed for all input files.
