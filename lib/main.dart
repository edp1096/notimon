import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform =
      MethodChannel('com.dream_world.notimon/notifications');

  String notificationText = 'No new notifications';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _setupNotificationListener();
  }

  Future<bool> _isNotificationListenerEnabled() async {
    try {
      final bool result =
          await platform.invokeMethod('isNotificationListenerEnabled');
      return result;
    } on PlatformException catch (e) {
      debugPrint(
          "Failed to check notification listener status: '${e.message}'.");
      return false;
    }
  }

  Future<void> _checkPermissions() async {
    final isNotificationPermissionGranted =
        await Permission.notification.isGranted;
    final isListenerEnabled = await _isNotificationListenerEnabled();

    if (!isNotificationPermissionGranted) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        debugPrint('Notification permission is not granted');
        await _openNotificationSettings();
        return;
      }
    }

    if (!isListenerEnabled) {
      debugPrint('Notification listener is not enabled');
      await _startNotificationListener();
    } else {
      debugPrint('Notification listener is already enabled');
    }
  }

  Future<void> _openNotificationSettings() async {
    try {
      final String result =
          await platform.invokeMethod('openNotificationSettings');
      debugPrint(result);
    } on PlatformException catch (e) {
      debugPrint("Failed to open notification settings: '${e.message}'.");
    }
  }

  Future<void> _startNotificationListener() async {
    try {
      final String result =
          await platform.invokeMethod('startNotificationListener');
      debugPrint(result);
    } on PlatformException catch (e) {
      debugPrint("Failed to start notification listener: '${e.message}'.");
    }
  }

  void _setupNotificationListener() {
    platform.setMethodCallHandler((call) async {
      debugPrint("onNotificationPosted received");
      if (call.method == "onNotificationPosted") {
        final String packageName = call.arguments["packageName"] ?? "";

        final String notiTag = call.arguments["notiTag"] ?? "";
        final String convTitle = call.arguments["convTitle"] ?? "";

        final String title = call.arguments["title"] ?? "";
        final String bigTitle = call.arguments["bigTitle"] ?? "";
        final String text = call.arguments["text"] ?? "";
        final String bigText = call.arguments["bigText"] ?? "";
        final String summary = call.arguments["summary"] ?? "";
        final String subtext = call.arguments["subtext"] ?? "";
        final String veritext = call.arguments["veritext"] ?? "";
        final String infotext = call.arguments["infotext"] ?? "";

        debugPrint("Title: $title");
        debugPrint("Text: $text");

        setState(() {
          notificationText = 'Notification from $packageName:\n'
              'Notification Tag: $notiTag\n'
              'Conversation Title: $convTitle\n'
              'Title: $title\n'
              'Big Title: $bigTitle\n'
              'Text: $text\n'
              'Big Text: $bigText\n'
              'Summary: $summary\n'
              'Sub Text: $subtext\n'
              'Verification Text: $veritext\n'
              'Info Text: $infotext\n';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Notification Listener'),
        ),
        body: Center(
          child: Text(notificationText),
        ),
      ),
    );
  }
}

void main() => runApp(const MyApp());
