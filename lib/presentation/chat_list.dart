import 'package:chat_app/presentation/chat_screen.dart';
import 'package:flutter/material.dart';

import '../service/user_service.dart';
import 'login_screen.dart';

int buttonIndex = 0;

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade100,
        title: Text(
          'Chat List',
          style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                var logout = await UserService.removeLoginUserId();
                if (logout) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Logout')));
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const LoginScreen()));
                }
              },
              icon: const Icon(Icons.power_settings_new))
        ],
      ),
      body: Expanded(
          child: ListView.separated(
              itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      buttonIndex = index;
                      print(buttonIndex);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(index: index),
                          ));
                    },
                    child: ListTile(
                        leading: CircleAvatar(radius: 23),
                        title: Text("Name Titile"),
                        subtitle: Text("nick name")),
                  ),
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.grey.shade100),
              itemCount: 10)),
    );
  }
}
