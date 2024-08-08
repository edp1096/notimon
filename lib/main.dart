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
    final isListenerEnabled = await _isNotificationListenerEnabled();

    if (!isListenerEnabled) {
      debugPrint('Notification listener is not enabled');
      await _openNotificationListenerSetting();
    } else {
      debugPrint('Notification listener is already enabled');
    }
  }

  Future<void> _openNotificationListenerSetting() async {
    try {
      final String result =
          await platform.invokeMethod('openNotificationListenerSetting');
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

        final String title = call.arguments["title"] ?? "";
        final String text = call.arguments["text"] ?? "";

        debugPrint("Package: $packageName");
        debugPrint("Title: $title");
        debugPrint("Text: $text");

        setState(() {
          notificationText = ""
              "Notification from $packageName:\n"
              "Title: $title\n"
              "Text: $text\n";
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
