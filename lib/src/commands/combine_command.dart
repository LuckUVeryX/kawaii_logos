import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

/// {@template combine_command}
/// A command which combines all kawaii_logos assets into one folder.
/// {@endtemplate}
class CombineCommand extends Command<int> {
  CombineCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'Output directory path. Defaults to present working directory',
    );
  }

  @override
  String get description => 'Combines all kawaii_logos assets into one folder.';

  @override
  String get name => 'combine';

  final Logger _logger;

  static const _repoUrl = 'https://github.com/SAWARATSUKI/KawaiiLogos.git';

  @override
  FutureOr<int>? run() async {
    final dir = Directory.systemTemp.createTempSync();
    try {
      // Clone the repository to temporary directory
      final cloneResult = await Process.start(
        'git',
        ['clone', _repoUrl, dir.path],
      );

      final cloneResultExitCode = await cloneResult.exitCode;
      if (cloneResultExitCode != 0) {
        _logger.err('Failed to clone repository: ${cloneResult.stderr}');
        return cloneResultExitCode;
      }

      // Find .png files
      final pngFiles = dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.png'));
      _logger.info('Found ${pngFiles.length} PNG files in ${dir.path}.');

      // Combine all .png files into one folder
      for (final pngFile in pngFiles) {
        final pngFileName = pngFile.path.split('/').last;
        final pngFileContents = pngFile.readAsBytesSync();
        // Output to current directory in a `Kawaii_Logos` folder.
        final outputPath = argResults?['output'] ?? Directory.current.path;
        _logger.info('Combining $pngFileName');
        final outputDir = Directory('$outputPath/Kawaii_Logos')
          ..createSync(recursive: true);
        File('${outputDir.path}/$pngFileName')
          ..createSync(recursive: true)
          ..writeAsBytesSync(pngFileContents);
      }
      _logger.info('Done.');
    } catch (e) {
      _logger.err('$e');
      return ExitCode.software.code;
    } finally {
      dir.deleteSync(recursive: true);
      _logger.info('Deleted temporary directory ${dir.path}.');
    }
    return ExitCode.success.code;
  }
}
