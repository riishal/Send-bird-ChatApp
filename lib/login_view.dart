import 'dart:async';
import 'dart:io';
import 'package:chat_app/channel_list_view.dart';
import 'package:chat_app/notification_service.dart';
import 'package:chat_app/push_notification.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/service/user_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:sendbird_sdk/sendbird_sdk.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  bool? isLoginUserId;
  // final _appIdController =
  //     TextEditingController(text: "4DF99F17-28BF-4741-90AB-99DAAA707E58");
  final _userIdController = TextEditingController();
  bool _enableSignInButton = false;
  PushNotification? _notificationInfo;
  @override
  void initState() {
    UserService.getLoginUserId().then((loginUserId) {
      if (loginUserId != null) {
        setState(() => isLoginUserId = true);
        AuthService.loginUser(loginUserId);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ChannelListView()));
      } else {
        setState(() => isLoginUserId = false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: isLoginUserId != null
            ? isLoginUserId!
                ? Container()
                : body(context)
            : Container());
  }

  Widget navigationBar() {
    return AppBar(
      toolbarHeight: 65,
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: true,
      title:
          const Text('Sendbird Sample', style: TextStyle(color: Colors.black)),
      actions: const [],
      centerTitle: true,
    );
  }

  Widget body(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 100),
        child: Column(
          children: [
            Container(
                width: 50,
                height: 50,
                child: const Image(
                  image: AssetImage('assets/logoSendbird@3x.png'),
                  fit: BoxFit.scaleDown,
                )),
            const SizedBox(height: 20),
            Text('Sendbird Sample',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 40),
            // TextField(
            //   controller: _appIdController,
            //   onChanged: (value) {
            //     setState(() {
            //       _enableSignInButton = _shouldEnableSignInButton();
            //     });
            //   },
            //   decoration: InputDecoration(
            //       border: InputBorder.none,
            //       labelText: 'App Id',
            //       filled: true,
            //       fillColor: Colors.grey[200],
            //       suffixIcon: IconButton(
            //         onPressed: () {
            //           _appIdController.clear();
            //         },
            //         icon: const Icon(Icons.clear),
            //       )),
            // ),
            const SizedBox(height: 10),
            TextField(
              controller: _userIdController,
              onChanged: (value) {
                setState(() {
                  _enableSignInButton = _shouldEnableSignInButton();
                });
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'User Id',
                  filled: true,
                  fillColor: Colors.grey[200],
                  suffixIcon: IconButton(
                    onPressed: () {
                      _userIdController.clear();
                    },
                    icon: const Icon(Icons.clear),
                  )),
            ),
            const SizedBox(height: 30),
            FractionallySizedBox(
              widthFactor: 1,
              child: _signInButton(context, _enableSignInButton),
            )
          ],
        ));
  }

  bool _shouldEnableSignInButton() {
    if (_userIdController.text.isEmpty) {
      return false;
    }
    return true;
  }

  Widget _signInButton(BuildContext context, bool enabled) {
    if (enabled == false) {
      // Disable the sign in button if required data not entered
      return TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey)),
        onPressed: () {},
        child: const Text(
          "Sign In",
          style: TextStyle(fontSize: 20.0),
        ),
      );
    }
    return TextButton(
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(const Color(0xff742DDD)),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white)),
      onPressed: () {
        // Login with Sendbird
        AuthService.loginUser(_userIdController.text.trim()).then((_) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ChannelListView()));
        });

        // connect('4DF99F17-28BF-4741-90AB-99DAAA707E58', _userIdController.text)
        //     .then((user) {
        //   Navigator.pushNamed(context, '/channel_list');
        // }).catchError((error) {
        //   print('login_view: _signInButton: ERROR: $error');
        // });
      },
      child: const Text(
        "Sign In",
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }

  Future<User> connect(String appId, String userId) async {
    // Init Sendbird SDK and connect with current user id
    try {
      final sendbird = SendbirdSdk(appId: appId);
      final user = await sendbird.connect(userId);

      final messaging = FirebaseMessaging.instance;

      // On iOS, this helps to take the user permissions
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
        String? token;

        if (Platform.isIOS) {
          //Retrieve pushtoken for IOS
          token = await messaging.getAPNSToken();
        } else {
          // Retrieve pushtoken for FCM
          token = await messaging.getToken();
        }

        sendbird.registerPushToken(
            type: Platform.isIOS ? PushTokenType.apns : PushTokenType.fcm,
            token: token!);

        print('The FCM token is: $token');

        // For handling the received notifications
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('title: ${message.notification?.title}');
          print('body: ${message.notification?.body}');
          // Parse the message received
          PushNotification notification = PushNotification(
            title: message.notification?.title,
            body: message.notification?.body,
          );

          setState(() {
            _notificationInfo = notification;
          });
          if (_notificationInfo != null) {
            NotificationService.showNotification(
                _notificationInfo?.title ?? '', _notificationInfo?.body ?? '');
          }
        });
      } else {
        print('User declined or has not accepted permission');
      }

      return user;
    } catch (e) {
      print('login_view: connect: ERROR: $e');
      rethrow;
    }
  }
}
