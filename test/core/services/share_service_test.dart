import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiozulawy/core/services/share_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'ClipboardShareService copies the given text to the clipboard',
    () async {
      String? copiedText;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              copiedText = (call.arguments as Map)['text'] as String?;
            }
            return null;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      const service = ClipboardShareService();
      await service.share('Słuchaj Radia Żuławy 106.4 FM');

      expect(copiedText, 'Słuchaj Radia Żuławy 106.4 FM');
    },
  );
}