import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

import 'login_view.dart';
import 'channel_list_view.dart';
import 'create_channel_view.dart';

import 'dart:convert';

import 'notification_service.dart';

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");

  final sendbirdDataString = message.data["sendbird"];
  final sendbirdData = jsonDecode(sendbirdDataString);

  print("Notification title: ${sendbirdData["sender"]["name"]}");
  print("Notification body: ${sendbirdData["message"]}");

  NotificationService.showNotification(
    sendbirdData["sender"]["name"] ?? '',
    sendbirdData["message"] ?? '',
  );
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  print("notification tapped: notificationTapBackground");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      print("Notification Recieved with flutterLocalNotificationsPlugin");
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  await Firebase.initializeApp();
  return runApp(const MyApp());
}

final appState = AppState();

class AppState with ChangeNotifier {
  bool didRegisterToken = false;
  String? token;
  String? destChannelUrl;

  void setDestination(String? channelUrl) {
    destChannelUrl = channelUrl;
    notifyListeners();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  @override
  void initState() {
    SendbirdSdk(appId: '4DF99F17-28BF-4741-90AB-99DAAA707E58').isInitialized;
    initializeFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sendbird Demo',
      initialRoute: "/login",
      routes: <String, WidgetBuilder>{
        '/login': (context) => const LoginView(),
        '/channel_list': (context) => const ChannelListView(),
        '/create_channel': (context) => const CreateChannelView(),
      },
      theme: ThemeData(
          fontFamily: "Gellix",
          primaryColor: const Color(0xff742DDD),
          textTheme: const TextTheme(
              headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
              headline6:
                  TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold)),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color(0xff732cdd),
            selectionHandleColor: Color(0xff732cdd),
            selectionColor: Color(0xffD1BAF4),
          )),
    );
  }
}
// import 'dart:async';

// import 'package:chat_app/presentation/login_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

// const yourAppId = '4DF99F17-28BF-4741-90AB-99DAAA707E58';
// void main() {
//   runZonedGuarded<Future<void>>(
//     () async {
//       WidgetsFlutterBinding.ensureInitialized();
//       FlutterError.onError = (errorDetails) {
//         debugPrint('[FlutterError] ${errorDetails.stack}');
//       };
//       runApp(MyApp());
//     },
//     (error, stackTrace) async {
//       debugPrint('[Error] $error\n$stackTrace');
//     },
//   );
// }

// class MyApp extends StatelessWidget {
//   MyApp({super.key}) {
//     SendbirdChat.init(appId: yourAppId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         ),
//         debugShowCheckedModeBanner: false,
//         home: const LoginScreen());
//   }
// }
