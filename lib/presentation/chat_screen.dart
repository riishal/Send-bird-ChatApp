import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      titleSpacing: 0,
      backgroundColor: Colors.purple.shade100,
      title: Row(children: [
        CircleAvatar(),
        SizedBox(
          width: 10,
        ),
        Text(
          "Title Name",
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
        )
      ]),
    ));
  }
}
