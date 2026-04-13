import 'package:simple_localization/simple_localization.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:flutter_test/flutter_test.dart';

import 'simple_localization_utils_test.dart';

void main() async {
  group('Logger testing', () {
    test('Logger enable', () {
      expect(SimpleLocalization.logger, equals(SimpleLocalization.logger));
      expect(SimpleLocalization.logger, isNotNull);
    });

    test('Logger print', overridePrint(() {
      printLog = [];
      SimpleLocalization.logger('Same print');
      expect(printLog.first, contains('Same print'));
      expect(printLog.first, contains(SimpleLocalization.logger.name));
    }));

    test('Logger print info', overridePrint(() {
      printLog = [];
      SimpleLocalization.logger('print info', level: LevelMessages.info);
      expect(printLog.first, contains('print info'));
      expect(printLog.first, contains('[INFO]'));
    }));

    test('Logger print debug', overridePrint(() {
      printLog = [];
      SimpleLocalization.logger('print debug', level: LevelMessages.debug);
      expect(printLog.first, contains('print debug'));
      expect(printLog.first, contains('[DEBUG]'));
    }));

    test('Logger print warning', overridePrint(() {
      printLog = [];
      SimpleLocalization.logger('print warning', level: LevelMessages.warning);
      expect(printLog.first, contains('print warning'));
      expect(printLog.first, contains('[WARNING]'));
    }));

    test('Logger print error', overridePrint(() {
      printLog = [];
      SimpleLocalization.logger('print error', level: LevelMessages.error);
      expect(printLog.first, contains('print error'));
      expect(printLog.first, contains('[ERROR]'));
    }));

    test('Logger print error with StackTrace', overridePrint(() {
      printLog = [];

      StackTrace testStackTrace;
      testStackTrace = StackTrace.fromString('test stack');

      SimpleLocalization.logger('print error',
          level: LevelMessages.error, stackTrace: testStackTrace);
      expect(printLog.first, contains('print error'));
      expect(printLog.first, contains('[ERROR]'));
      expect(printLog.last, contains('test stack'));
    }));
  });
}
