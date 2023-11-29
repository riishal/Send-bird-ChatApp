import 'package:chat_app/login_view.dart';
import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'group_channel_view.dart';
import 'service/user_service.dart';

class ChannelListView extends StatefulWidget {
  const ChannelListView({Key? key}) : super(key: key);

  @override
  ChannelListViewState createState() => ChannelListViewState();
}

class ChannelListViewState extends State<ChannelListView>
    with ChannelEventHandler {
  Future<List<GroupChannel>> getGroupChannels() async {
    try {
      final query = GroupChannelListQuery()
        ..includeEmptyChannel = true
        ..order = GroupChannelListOrder.latestLastMessage
        ..limit = 15;
      return await query.loadNext();
    } catch (e) {
      print('channel_list_view: getGroupChannel: ERROR: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    SendbirdSdk().addChannelEventHandler('channel_list_view', this);
  }

  @override
  void dispose() {
    SendbirdSdk().removeChannelEventHandler("channel_list_view");
    super.dispose();
  }

  @override
  void onChannelChanged(BaseChannel channel) {
    setState(() {
      // Force the list future builder to rebuild.
    });
  }

  @override
  void onChannelDeleted(String channelUrl, ChannelType channelType) {
    setState(() {
      // Force the list future builder to rebuild.
    });
  }

  @override
  void onUserJoined(GroupChannel channel, User user) {
    setState(() {
      // Force the list future builder to rebuild.
    });
  }

  @override
  void onUserLeaved(GroupChannel channel, User user) {
    setState(() {
      // Force the list future builder to rebuild.
    });
    super.onUserLeaved(channel, user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navigationBar(),
      body: body(context),
    );
  }

  PreferredSizeWidget navigationBar() {
    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
          onPressed: () async {
            var logout = await UserService.removeLoginUserId();
            if (logout) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Logout')));
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginView()));
            }
          },
          icon: const Icon(Icons.power_settings_new)),
      // leading: BackButton(color: Theme.of(context).primaryColor),
      title: const Text(
        'Channels',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        Container(
          width: 60,
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create_channel');
              },
              child: Image.asset("assets/iconCreate@3x.png")),
        ),
      ],
    );
  }

  Widget body(BuildContext context) {
    return FutureBuilder(
      future: getGroupChannels(),
      builder: (context, snapshot) {
        if (snapshot.hasData == false || snapshot.data == null) {
          // Nothing to display yet - good place for a loading indicator
          return Container();
        }
        List<GroupChannel> channels = snapshot.data as List<GroupChannel>;
        return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              GroupChannel channel = channels[index];
              return ListTile(
                // Display all channel members as the title
                title: Text(
                  [
                    for (final member in channel.members) member.userId
                  ] //changed nick name
                      .join(", "),
                ),
                // Display the last message presented
                subtitle: Text(channel.lastMessage?.message ?? ''),
                onTap: () {
                  gotoChannel(channel.channelUrl);
                },
              );
            });
      },
    );
  }

  void gotoChannel(String channelUrl) {
    GroupChannel.getChannel(channelUrl).then((channel) {
      // Navigator.pushNamed(context, '/channel_list');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChannelView(groupChannel: channel),
        ),
      );
    }).catchError((e) {
      //handle error
      print('channel_list_view: gotoChannel: ERROR: $e');
    });
  }
}
