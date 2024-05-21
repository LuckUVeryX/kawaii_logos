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
  }) : _logger = logger;

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

      // Combine all .png files into one folder
      for (final pngFile in pngFiles) {
        final pngFileName = pngFile.path.split('/').last;
        final pngFileContents = pngFile.readAsBytesSync();
        // Output to current directory in a `Kawaii_Logos` folder.
        final outputDir = Directory('${Directory.current.path}/Kawaii_Logos')
          ..createSync(recursive: true);
        File('${outputDir.path}/$pngFileName')
          ..createSync(recursive: true)
          ..writeAsBytesSync(pngFileContents);
      }
    } catch (e) {
      _logger.err('$e');
      return ExitCode.software.code;
    } finally {
      dir.deleteSync(recursive: true);
    }

    return ExitCode.success.code;
  }
}
