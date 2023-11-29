import 'package:flutter/material.dart';

import '../service/auth_service.dart';
import 'chat_list.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController userController = TextEditingController();
  // bool? isLoginUserId;

  @override
  void initState() {
    // UserService.getLoginUserId().then((loginUserId) {
    //   if (loginUserId != null) {
    //     setState(() => isLoginUserId = true);
    //     AuthService.loginUser(loginUserId);
    //     Navigator.of(context).pushReplacement(
    //         MaterialPageRoute(builder: (context) => const ChatListScreen()));
    //   } else {
    //     setState(() => isLoginUserId = false);
    //   }
    // });
    super.initState();
  }

  @override
  void dispose() {
    userController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          centerTitle: true,
        ),
        body:
            // isLoginUserId != null ? isLoginUserId!? Container():
            Center(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('User Id'),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: userController,
                    decoration: InputDecoration(
                      hintText: 'Enter user id',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            if (userController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('User Id should not be empty')));
                            } else {
                              AuthService.loginUser(userController.text.trim())
                                  .then((_) {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ChatListScreen()));
                              });
                            }
                          },
                          child: const Text('Login')))
                ]),
          ),
        )
        // : Container()
        );
  }
}
