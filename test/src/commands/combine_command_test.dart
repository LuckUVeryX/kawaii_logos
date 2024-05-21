import 'dart:io';

import 'package:kawaii_logos/src/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

void main() {
  group('combine', () {
    late Logger logger;
    late KawaiiLogosCommandRunner commandRunner;

    const outputPath = 'test/output';

    setUp(() {
      logger = _MockLogger();
      commandRunner = KawaiiLogosCommandRunner(logger: logger);
    });

    tearDown(() {
      Directory(outputPath).deleteSync(recursive: true);
    });

    test('exits with code 0', () async {
      final exitCode = await commandRunner.run([
        'combine',
        '-o',
        outputPath,
      ]);
      expect(exitCode, ExitCode.success.code);
    });
  });
}
