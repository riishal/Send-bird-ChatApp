// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../component/widgets.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

class OpenChannelPage extends StatefulWidget {
  const OpenChannelPage({Key? key}) : super(key: key);

  @override
  State<OpenChannelPage> createState() => OpenChannelPageState();
}

class OpenChannelPageState extends State<OpenChannelPage> {
  final channelUrl = Get.parameters['channel_url']!;
  final itemScrollController = ItemScrollController();
  final textEditingController = TextEditingController();
  late PreviousMessageListQuery query;

  String title = '';
  bool hasPrevious = false;
  List<BaseMessage> messageList = [];
  int? participantCount;

  OpenChannel? openChannel;

  @override
  void initState() {
    super.initState();
    SendbirdChat.addChannelHandler('OpenChannel', MyOpenChannelHandler(this));
    SendbirdChat.addConnectionHandler('OpenChannel', MyConnectionHandler(this));

    OpenChannel.getChannel(channelUrl).then((openChannel) {
      this.openChannel = openChannel;
      openChannel.enter().then((_) => _initialize());
    });
  }

  void _initialize() {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      query = PreviousMessageListQuery(
        channelType: ChannelType.open,
        channelUrl: channelUrl,
      )..next().then((messages) {
          setState(() {
            messageList
              ..clear()
              ..addAll(messages);
            title = '${openChannel.name} (${messageList.length})';
            hasPrevious = query.hasNext;
            participantCount = openChannel.participantCount;
          });
        });
    });
  }

  @override
  void dispose() {
    SendbirdChat.removeChannelHandler('OpenChannel');
    SendbirdChat.removeConnectionHandler('OpenChannel');
    textEditingController.dispose();

    OpenChannel.getChannel(channelUrl).then((channel) => channel.exit());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Widgets.pageTitle(title, maxLines: 2),
        actions: const [],
      ),
      body: Column(
        children: [
          participantCount != null ? _participantIdBox() : Container(),
          hasPrevious ? _previousButton() : Container(),
          Expanded(child: messageList.isNotEmpty ? _list() : Container()),
          _messageSender(),
        ],
      ),
    );
  }

  Widget _participantIdBox() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(Icons.person, size: 16.0),
              Text(
                participantCount.toString(),
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 12.0, color: Colors.green),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _previousButton() {
    return Container(
      width: double.maxFinite,
      height: 32.0,
      color: Colors.purple[200],
      child: IconButton(
        icon: const Icon(Icons.expand_less, size: 16.0),
        color: Colors.white,
        onPressed: () async {
          if (query.hasNext && !query.isLoading) {
            final messages = await query.next();
            final openChannel = await OpenChannel.getChannel(channelUrl);
            setState(() {
              messageList.insertAll(0, messages);
              title = '${openChannel.name} (${messageList.length})';
              hasPrevious = query.hasNext;
            });
            _scroll(0);
          }
        },
      ),
    );
  }

  Widget _list() {
    return ScrollablePositionedList.builder(
      physics: const ClampingScrollPhysics(),
      initialScrollIndex: messageList.length - 1,
      itemScrollController: itemScrollController,
      itemCount: messageList.length,
      itemBuilder: (BuildContext context, int index) {
        BaseMessage message = messageList[index];

        return Row(
          mainAxisAlignment: message.sender!.isCurrentUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            message.sender!.isCurrentUser
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Widgets.imageNetwork(
                        message.sender!.profileUrl, 35.0, Icons.account_circle),
                  ),
            Container(
              height: 45,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      topLeft: message.sender!.isCurrentUser
                          ? Radius.circular(10)
                          : Radius.circular(0),
                      bottomRight: Radius.circular(10),
                      topRight: message.sender!.isCurrentUser
                          ? Radius.circular(0)
                          : Radius.circular(10)),
                  color: message.sender!.isCurrentUser
                      ? Colors.deepPurple
                      : Colors.grey.shade300),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
              child: GestureDetector(
                onDoubleTap: () async {
                  final openChannel = await OpenChannel.getChannel(channelUrl);
                  Get.toNamed(
                          '/message/update/${openChannel.channelType.toString()}/${openChannel.channelUrl}/${message.messageId}')
                      ?.then((message) async {
                    if (message != null) {
                      for (int index = 0; index < messageList.length; index++) {
                        if (messageList[index].messageId == message.messageId) {
                          setState(() => messageList[index] = message);
                          break;
                        }
                      }
                    }
                  });
                },
                onLongPress: () async {
                  final openChannel = await OpenChannel.getChannel(channelUrl);
                  await openChannel.deleteMessage(message.messageId);
                  setState(() {
                    messageList.remove(message);
                    title = '${openChannel.name} (${messageList.length})';
                  });
                },
                child: Row(
                  children: [
                    Text(
                      '   ${message.message}    ',
                      style: TextStyle(
                        color: message.sender!.isCurrentUser
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Column(
                //   children: [
                //     ListTile(
                //       title:
                // Text(
                //         message.message,
                //         style: const TextStyle(
                //           color: Colors.black,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       subtitle: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Widgets.imageNetwork(message.sender?.profileUrl, 16.0,
                //               Icons.account_circle),
                //           Expanded(
                //             child: Padding(
                //               padding: const EdgeInsets.only(left: 4.0),
                //               child: Text(
                //                 message.sender?.userId ?? '',
                //                 style: const TextStyle(fontSize: 12.0),
                //               ),
                //             ),
                //           ),
                //           // Container(
                //           //   margin: const EdgeInsets.only(left: 16),
                //           //   alignment: Alignment.centerRight,
                //           //   child: Text(
                //           //     DateTime.fromMillisecondsSinceEpoch(message.createdAt)
                //           //         .toString(),
                //           //     style: const TextStyle(fontSize: 12.0),
                //           //   ),
                //           // ),
                //         ],
                //       ),
                //     ),
                //     const Divider(height: 1),
                //   ],
                // ),
              ),
            ),
            Text(
              message.sender!.isCurrentUser
                  ? '   '
                  : '   ${message.sender?.userId}    ',
              style: TextStyle(
                  fontSize: 12.0,
                  color: message.sender!.isCurrentUser
                      ? Colors.black
                      : Colors.blue),
            ),
          ],
        );
      },
    );
  }

  Widget _messageSender() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Widgets.textField(textEditingController, 'Message'),
          ),
          const SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () async {
              if (textEditingController.value.text.isEmpty) {
                return;
              }

              openChannel?.sendUserMessage(
                UserMessageCreateParams(
                  message: textEditingController.value.text,
                ),
                handler: (UserMessage message, SendbirdException? e) async {
                  if (e != null) {
                    await _showDialogToResendUserMessage(message);
                  } else {
                    _addMessage(message);
                  }
                },
              );

              textEditingController.clear();
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDialogToResendUserMessage(UserMessage message) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Text('Resend: ${message.message}'),
            actions: [
              TextButton(
                onPressed: () {
                  openChannel?.resendUserMessage(
                    message,
                    handler: (message, e) async {
                      if (e != null) {
                        await _showDialogToResendUserMessage(message);
                      } else {
                        _addMessage(message);
                      }
                    },
                  );

                  Get.back();
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('No'),
              ),
            ],
          );
        });
  }

  void _addMessage(BaseMessage message) {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      setState(() {
        messageList.add(message);
        title = '${openChannel.name} (${messageList.length})';
        participantCount = openChannel.participantCount;
      });

      Future.delayed(
        const Duration(milliseconds: 100),
        () => _scroll(messageList.length - 1),
      );
    });
  }

  void _updateMessage(BaseMessage message) {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      setState(() {
        for (int index = 0; index < messageList.length; index++) {
          if (messageList[index].messageId == message.messageId) {
            messageList[index] = message;
            break;
          }
        }

        title = '${openChannel.name} (${messageList.length})';
        participantCount = openChannel.participantCount;
      });
    });
  }

  void _deleteMessage(int messageId) {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      setState(() {
        for (int index = 0; index < messageList.length; index++) {
          if (messageList[index].messageId == messageId) {
            messageList.removeAt(index);
            break;
          }
        }

        title = '${openChannel.name} (${messageList.length})';
        participantCount = openChannel.participantCount;
      });
    });
  }

  void _updateParticipantCount() {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      setState(() {
        participantCount = openChannel.participantCount;
      });
    });
  }

  void _scroll(int index) async {
    if (messageList.length <= 1) return;

    while (!itemScrollController.isAttached) {
      await Future.delayed(const Duration(milliseconds: 1));
    }

    itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
  }
}

class MyOpenChannelHandler extends OpenChannelHandler {
  final OpenChannelPageState _state;

  MyOpenChannelHandler(this._state);

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    _state._addMessage(message);
  }

  @override
  void onMessageUpdated(BaseChannel channel, BaseMessage message) {
    _state._updateMessage(message);
  }

  @override
  void onMessageDeleted(BaseChannel channel, int messageId) {
    _state._deleteMessage(messageId);
  }

  @override
  void onUserEntered(OpenChannel channel, User user) {
    _state._updateParticipantCount();
  }

  @override
  void onUserExited(OpenChannel channel, User user) {
    _state._updateParticipantCount();
  }
}

class MyConnectionHandler extends ConnectionHandler {
  final OpenChannelPageState _state;

  MyConnectionHandler(this._state);

  @override
  void onConnected(String userId) {}

  @override
  void onDisconnected(String userId) {}

  @override
  void onReconnectStarted() {}

  @override
  void onReconnectSucceeded() {
    _state._initialize();
  }

  @override
  void onReconnectFailed() {}
}
