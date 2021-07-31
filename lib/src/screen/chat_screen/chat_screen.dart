import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_services/main.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:home_services/src/widget/seller_drawer.dart';
import 'package:timezone/standalone.dart' as tz;

class ChatScreen extends StatefulWidget {
  final type,
      professionalId,
      professionalName,
      consumerName,
      consumerId,
      consumerAvatar,
      professionalAvatar;

  ChatScreen(
      {this.type,
      this.professionalId,
      this.professionalName,
      this.consumerId,
      this.consumerName,
      this.consumerAvatar,
      this.professionalAvatar});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with RouteAware {
  GlobalKey<ScaffoldState> key = GlobalKey();
  TextEditingController messageController = TextEditingController();
  StreamSubscription _subscription;

  List messages = [];

  @override
  void initState() {
    super.initState();
    getMessageUpdates();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
    routeObserver.unsubscribe(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPushNext() {
    super.didPushNext();
    _subscription?.cancel();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _subscription?.cancel();
  }

  sendMessage() {
    if (messageController.text != null || messageController.text.trim() == "") {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      firestore
          .collection("chatroom")
          .doc("${widget.consumerId}_${widget.professionalId}")
          .collection("chats")
          .get()
          .then((value) {
        var data = value.docs?.map((e) => e.data())?.toList() ?? [];
        if (data.length != 0) {
          addChatMessage();
        } else {
          firestore.collection("users").add({
            "sender_id": widget.type == "buyer"
                ? widget.consumerId
                : widget.professionalId,
            "receiver_id": widget.type == "buyer"
                ? widget.professionalId
                : widget.consumerId,
            "sender_name": widget.type == "buyer"
                ? widget.consumerName
                : widget.professionalName,
            "receiver_name": widget.type == "buyer"
                ? widget.professionalName
                : widget.consumerName,
            "sender_avatar": widget.type == "buyer"
                ? widget.consumerAvatar
                : widget.professionalAvatar,
            "receiver_avatar": widget.type == "buyer"
                ? widget.professionalAvatar
                : widget.consumerAvatar,
            "initiate": widget.type,
          });
          addChatMessage();
        }
        setState(() {
          messageController.text = "";
        });
      });
    }
  }

  addChatMessage() {
    var jamaica = tz.getLocation('America/Jamaica');
    var jamaicaCurrentTime = tz.TZDateTime.now(jamaica);
    var jamaicaTimeStamp = jamaicaCurrentTime
        .toString()
        .substring(0, jamaicaCurrentTime.toString().lastIndexOf("-"));
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var message = {
      "message": messageController.text,
      "sender_name": widget.type == "buyer"
          ? widget.consumerName
          : widget.professionalName,
      "receiver_name": widget.type == "buyer"
          ? widget.professionalName
          : widget.consumerName,
      "sender_id":
          widget.type == "buyer" ? widget.consumerId : widget.professionalId,
      "receiver_id":
          widget.type == "buyer" ? widget.professionalId : widget.consumerId,
      "time": DateTime.parse(jamaicaTimeStamp),
    };
    firestore
        .collection("chatroom")
        .doc("${widget.consumerId}_${widget.professionalId}")
        .collection("chats")
        .add(message);
  }

  getMessageUpdates() {
    _subscription = FirebaseFirestore.instance
        .collection("chatroom")
        .doc("${widget.consumerId}_${widget.professionalId}")
        .collection("chats")
        .orderBy("time", descending: false)
        .snapshots()
        .listen((event) {
      var data = event.docs?.map((e) => e.data())?.toList() ?? [];
      if (mounted) {
        setState(() {
          messages = data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      key: key,
      appBar: primaryAppBar(context, "Chats", key),
      drawer: widget.type == "buyer" ? BuyerDrawer() : SellerDrawer(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: size.height * 0.8,
                padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      var data = messages[index];
                      var avatarReceiver = widget.type == "buyer"
                          ? widget.professionalAvatar
                          : widget.consumerAvatar;
                      var avatarSender = widget.type == "buyer"
                          ? widget.consumerAvatar
                          : widget.professionalAvatar;
                      return Row(
                        mainAxisAlignment: data['sender_id'] ==
                                (widget.type == "buyer"
                                    ? widget.consumerId
                                    : widget.professionalId)
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          data['sender_id'] ==
                                  (widget.type == "buyer"
                                      ? widget.professionalId
                                      : widget.consumerId)
                              ? Container(
                                  padding:
                                      EdgeInsets.only(right: size.width * 0.02),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        Constant.STORAGE_PATH + avatarReceiver,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      width: size.width * 0.05,
                                      height: size.width * 0.05,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          Container(
                            alignment: data['sender_id'] ==
                                    (widget.type == "buyer"
                                        ? widget.consumerId
                                        : widget.professionalId)
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            margin: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            padding: EdgeInsets.symmetric(
                                vertical: size.width * 0.03,
                                horizontal: size.width * 0.05),
                            decoration: BoxDecoration(
                                color: data['sender_id'] ==
                                        (widget.type == "buyer"
                                            ? widget.consumerId
                                            : widget.professionalId)
                                    ? themeColor.primaryColor
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(20.0)),
                            child: Text(
                              data['message'],
                              style: textTheme.subtitle2
                                  .copyWith(color: primary_font),
                            ),
                          ),
                          data['sender_id'] ==
                                  (widget.type == "buyer"
                                      ? widget.consumerId
                                      : widget.professionalId)
                              ? Container(
                                  padding:
                                      EdgeInsets.only(left: size.width * 0.02),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        Constant.STORAGE_PATH + avatarSender,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      width: size.width * 0.05,
                                      height: size.width * 0.05,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                  ))
                              : Container(),
                        ],
                      );
                    }),
              ),
              Container(
                width: size.width * 0.95,
                padding: EdgeInsets.only(bottom: size.height * 0.02),
                child: TextField(
                  controller: messageController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        child: Icon(
                          Icons.send_sharp,
                          color: themeColor.primaryColor,
                        ),
                        onTap: () {
                          sendMessage();
                        },
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      hintText: "Send Message",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.04)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
