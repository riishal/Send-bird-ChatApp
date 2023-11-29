import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'dart:async';

class GroupChannelView extends StatefulWidget {
  final GroupChannel groupChannel;
  const GroupChannelView({Key? key, required this.groupChannel})
      : super(key: key);

  @override
  GroupChannelViewState createState() => GroupChannelViewState();
}

class GroupChannelViewState extends State<GroupChannelView>
    with ChannelEventHandler {
  List<BaseMessage> _messages = [];
  @override
  void initState() {
    super.initState();
    getMessages(widget.groupChannel);
    SendbirdSdk().addChannelEventHandler(widget.groupChannel.channelUrl, this);
  }

  @override
  void dispose() {
    SendbirdSdk().removeChannelEventHandler(widget.groupChannel.channelUrl);
    super.dispose();
  }

  @override
  onMessageReceived(channel, message) {
    setState(() {
      _messages.add(message);
      _messages.sort(((a, b) => b.createdAt.compareTo(a.createdAt)));
    });
  }

  Future<void> getMessages(GroupChannel channel) async {
    try {
      List<BaseMessage> messages = await channel.getMessagesByTimestamp(
          DateTime.now().millisecondsSinceEpoch * 1000, MessageListParams());
      setState(() {
        messages.sort(((a, b) => b.createdAt.compareTo(a.createdAt)));
        _messages = messages;
      });
    } catch (e) {
      print('group_channel_view.dart: getMessages: ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navigationBar(widget.groupChannel),
      body: body(context),
    );
  }

  PreferredSizeWidget navigationBar(GroupChannel channel) {
    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: Colors.white,
      centerTitle: false,
      leading:
          BackButton(color: Theme.of(context).buttonTheme.colorScheme!.primary),
      title: Container(
        width: 250,
        child: Text(
          [for (final member in channel.members) member.userId].join(", "),
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget body(BuildContext context) {
    ChatUser user = asDashChatUser(SendbirdSdk().currentUser!);
    return Padding(
      // A little breathing room for devices with no home button.
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 40),
      child: DashChat(
        key: Key(widget.groupChannel.channelUrl),
        onSend: (ChatMessage message) async {
          var sentMessage =
              widget.groupChannel.sendUserMessageWithText(message.text);
          setState(() {
            _messages.add(sentMessage);
            _messages.sort(((a, b) => b.createdAt.compareTo(a.createdAt)));
          });
        },
        inputOptions: const InputOptions(
          sendOnEnter: true,
          textInputAction: TextInputAction.send,
          inputDecoration:
              InputDecoration.collapsed(hintText: "Type a message here..."),
        ),
        messageOptions: const MessageOptions(
          showCurrentUserAvatar: false,
          showOtherUsersAvatar: true,
        ),
        currentUser: user,
        messages: asDashChatMessages(_messages),
      ),
    );
  }

  List<ChatMessage> asDashChatMessages(List<BaseMessage> messages) {
    // BaseMessage is a Sendbird class
    // ChatMessage is a DashChat class
    List<ChatMessage> result = [];
    if (messages != null) {
      messages.forEach((message) {
        User user = message.sender as User;
        if (user == null) {
          return;
        }
        result.add(
          ChatMessage(
            createdAt: DateTime.fromMillisecondsSinceEpoch(message.createdAt),
            text: message.message,
            user: asDashChatUser(user),
          ),
        );
      });
    }
    return result;
  }

  ChatUser asDashChatUser(User user) {
    return ChatUser(
      firstName: user.userId, //nick name changed
      id: user.userId,
      profileImage: user.profileUrl,
    );
  }
}
