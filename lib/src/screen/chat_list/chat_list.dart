import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/screen/chat_screen/chat_screen.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/app_prefrences.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:home_services/src/widget/seller_drawer.dart';

class ChatList extends StatefulWidget {
  final type;
  ChatList({this.type});
  @override
  State<StatefulWidget> createState() {
    return ChatListState();
  }
}

class ChatListState extends State<ChatList> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  List userList = [], listModified = [];
  bool isLoading = true;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getUserList();
  }

  getUserList() {
    getUser().then((value) async {
      var user = json.decode(value);
      await firestore.collection("users").get().then((event) {
        var data = event.docs?.map((e) => e.data())?.toList() ?? [];
        var filteredUsers = data
                ?.where((element) => (element['sender_id'] == user['id'] ||
                    element['receiver_id'] == user['id']))
                ?.toList() ??
            [];
        filteredUsers.map((e) {
          firestore
              .collection("chatroom")
              .doc(e['initiate'] == "buyer"
                  ? '${e['sender_id']}_${e['receiver_id']}'
                  : '${e['receiver_id']}_${e['sender_id']}')
              .collection("chats")
              .orderBy("time", descending: true)
              .get()
              .then((value) {
            var chats = value.docs?.map((e) => e.data())?.toList() ?? [];
            e['last_message'] = chats[0]['message'];
            listModified.add(e);
          });
        }).toList();
      });
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          userList = listModified;
          isLoading = false;
        });
      });
    });
  }

  listData(context, result) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    return ListView.builder(
        itemCount: result.length,
        itemBuilder: (context, index) {
          var chat = result[index];
          var imagePath = widget.type == "buyer"
              ? chat['initiate'] == "buyer"
                  ? chat['receiver_avatar']
                  : chat['sender_avatar']
              : chat['initiate'] == "seller"
                  ? chat['receiver_avatar']
                  : chat['sender_avatar'];
          /*chat['sender_id'] == user['id']
                  ? chat['receiver_avatar']
                  : chat['sender_avatar'];*/
          return Container(
            margin: EdgeInsets.only(bottom: size.height * 0.01),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatScreen(
                              consumerAvatar: widget.type == "buyer"
                                  ? chat['initiate'] == "buyer"
                                      ? chat['sender_avatar']
                                      : chat['receiver_avatar']
                                  : chat['initiate'] == "seller"
                                      ? chat['receiver_avatar']
                                      : chat['sender_avatar'],
                              professionalAvatar: widget.type == "buyer"
                                  ? chat['initiate'] == "buyer"
                                      ? chat['receiver_avatar']
                                      : chat['sender_avatar']
                                  : chat['initiate'] == "seller"
                                      ? chat['sender_avatar']
                                      : chat['receiver_avatar'],
                              consumerId: widget.type == "buyer"
                                  ? chat['initiate'] == "buyer"
                                      ? chat['sender_id']
                                      : chat['receiver_id']
                                  : chat['initiate'] == "seller"
                                      ? chat['receiver_id']
                                      : chat['sender_id'],
                              consumerName: widget.type == "buyer"
                                  ? chat['initiate'] == "buyer"
                                      ? chat['sender_name']
                                      : chat['receiver_name']
                                  : chat['initiate'] == "seller"
                                      ? chat['receiver_name']
                                      : chat['sender_name'],
                              professionalId: widget.type == "buyer"
                                  ? chat['initiate'] == "buyer"
                                      ? chat['receiver_id']
                                      : chat['sender_id']
                                  : chat['initiate'] == "seller"
                                      ? chat['sender_id']
                                      : chat['receiver_id'],
                              professionalName: widget.type == "buyer"
                                  ? chat['initiate'] == "buyer"
                                      ? chat['receiver_name']
                                      : chat['sender_name']
                                  : chat['initiate'] == "seller"
                                      ? chat['sender_name']
                                      : chat['receiver_name'],
                              type: widget.type,
                            )));
              },
              child: Card(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.015,
                      horizontal: size.width * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CachedNetworkImage(
                        imageUrl: Constant.STORAGE_PATH + imagePath,
                        imageBuilder: (context, imageProvider) => Container(
                          width: size.width * 0.15,
                          height: size.width * 0.15,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Container(
                        width: size.width * 0.6,
                        padding: EdgeInsets.only(left: size.width * 0.025),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.01),
                              child: Text(
                                widget.type == "buyer"
                                    ? chat['initiate'] == "buyer"
                                        ? chat['receiver_name']
                                        : chat['sender_name']
                                    : chat['initiate'] == "seller"
                                        ? chat['receiver_name']
                                        : chat['sender_name'],
                                /*chat['sender_id'] == user['id']
                                      ? chat['receiver_name']
                                      : chat['sender_name'],*/
                                style: textTheme.subtitle2
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: Text(
                                chat['last_message'],
                                style: textTheme.caption,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    return Scaffold(
      key: key,
      appBar: primaryAppBar(context, "Chats", key),
      drawer: widget.type == "buyer" ? BuyerDrawer() : SellerDrawer(),
      extendBodyBehindAppBar: isLoading,
      body: isLoading
          ? loadingData(context)
          : userList.length == 0
              ? noDataFound(context)
              : Container(
                  width: size.width,
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.02,
                      vertical: size.height * 0.02),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                            width: size.width,
                            color: primary_font,
                            child: listData(context, userList)),
                      ),
                    ],
                  ),
                ),
    );
  }
}
