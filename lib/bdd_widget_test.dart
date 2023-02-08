import 'dart:io';

import 'package:bdd_widget_test/src/existing_steps.dart';
import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:bdd_widget_test/src/util/fs.dart';
import 'package:build/build.dart';
import 'package:bdd_widget_test/src/util/fs.dart';
import 'package:collection/collection.dart';

import 'package:path/path.dart' as p;

Builder featureBuilder(BuilderOptions options) => FeatureBuilder(
      GeneratorOptions.fromMap(options.config),
    );

class FeatureBuilder implements Builder {
  static FeaturesStore _store = FeaturesStore();

  FeatureBuilder(this.generatorOptions);

  final GeneratorOptions generatorOptions;

  @override
  Future<void> build(BuildStep buildStep) async {
    final options = await prepareOptions();

    final inputId = buildStep.inputId;
    final contents = await buildStep.readAsString(inputId);

    final featureDir = p.dirname(inputId.path);
    final root = await findRootDirectory(featureDir);
    final shared = await fs.directory(p.join(root.path, "sharedSteps"));

    if (FeaturesStore._singleton.duplicationsSteps == null) {
      final featuresFilesList = await findFeaturesFiles(root, [], "");

      final featuresList = <FeatureFile>[];
      for (var a in featuresFilesList) {
        final input = fs.file(a.featureFile).readAsStringSync();

        final featureList = FeatureFile(
          featureDir: featureDir,
          package: a.importPath,
          input: input,
          generatorOptions: options,
          isIntegrationTest: inputId.pathSegments.contains('integration_test'),
        );

        featuresList.add(featureList);
      }

      final duplicationsSteps = featuresList
          .map((e) => e.getStepFiles())
          .expand((element) => element)
          .groupListsBy((element) => element.fName);

      duplicationsSteps.removeWhere((key, value) => value.length <= 1);

      FeaturesStore._singleton.duplicationsSteps = {
        for (var v in duplicationsSteps.keys) v: p.join(shared.path, v)
      };
    }

    final sharedStepsForFeature = FeaturesStore._singleton.duplicationsSteps
            ?.map((key, value) =>
                MapEntry(key, p.relative(value, from: featureDir))) ??
        {};

    final feature = FeatureFile(
      featureDir: featureDir,
      package: inputId.package,
      isIntegrationTest: inputId.pathSegments.contains('integration_test'),
      existingSteps: {
        ...sharedStepsForFeature,
      },
      input: contents,
      generatorOptions: options,
    );

    final featureDart = inputId.changeExtension('_test.dart');
    await buildStep.writeAsString(
        featureDart, feature.getDartContent(sharedStepsForFeature));

    final steps = feature
        .getStepFiles()
        .whereType<NewStepFile>()
        .where((element) => !sharedStepsForFeature.keys.contains(element.fName))
        .map((e) => createFileRecursively(e.filename, e.dartContent))
        .toList();

    final sharedSteps = feature
        .getStepFiles()
        .whereType<NewStepFile>()
        .where((element) => sharedStepsForFeature.keys.contains(element.fName))
        .map((e) {
      final import =
          FeaturesStore._singleton.duplicationsSteps?[e.fName] ?? e.import;
      return NewStepFile(import, import, e.package, e.line);
    }).map((e) => createFileRecursively(e.filename, e.dartContent));

    await Future.wait(steps);
    await Future.wait(sharedSteps);
  }

  Future<GeneratorOptions> prepareOptions() async {
    final fileOptions = fs.file('bdd_options.yaml').existsSync()
        ? readFromUri(Uri.file('bdd_options.yaml'))
        : null;
    final mergedOptions = fileOptions != null
        ? merge(generatorOptions, fileOptions)
        : generatorOptions;
    final options = await flattenOptions(mergedOptions);
    return options;
  }

  Future<void> createFileRecursively(String filename, String content) async {
    final f = fs.file(filename);
    if (f.existsSync()) {
      return;
    }
    final file = await f.create(recursive: true);
    await file.writeAsString(content);
  }

  Future<List<FeatureFileInfo>> findFeaturesFiles(Directory directory,
      List<FeatureFileInfo> features, String importPath) async {
    final files = directory.listSync();

    for (var file in files) {
      if (await fs.isDirectory(file.path)) {
        features = await findFeaturesFiles(fs.directory(file.path), features,
            p.join(importPath, p.basename(file.path)));
      } else if (await fs.isFile(file.path) &&
          file.path.endsWith(buildExtensions.keys.first)) {
        features.add(FeatureFileInfo(file, importPath));
      }
    }

    return features;
  }

  @override
  final buildExtensions = const {
    '.feature': ['_test.dart']
  };
}

class FeaturesStore {
  static final FeaturesStore _singleton = FeaturesStore._internal();
  factory FeaturesStore() => _singleton;
  FeaturesStore._internal();

  Map<String, String>? duplicationsSteps = null;

  Map<String, String> findDuplicationStepsOnPath(String featureDir) {
    return {};
  }
}

class FeatureFileInfo {
  final FileSystemEntity featureFile;
  String importPath;

  FeatureFileInfo(this.featureFile, this.importPath);
}

Future<Directory> findRootDirectory(String featureDir) async {
  final path = p.split(featureDir);
  final testDirIndex = path.indexWhere(
      (element) => element == "integration_test" || element == "test");

  if (testDirIndex < 1) {
    return fs.directory(path.first);
  }

  path.removeRange(testDirIndex + 1, path.length);
  return fs.directory(p.joinAll(path));
}
