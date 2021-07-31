import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/app.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/become_seller/become_seller.dart';
import 'package:home_services/src/screen/chat_list/chat_list.dart';
import 'package:home_services/src/screen/consumer_edit_profile/consumer_edit_profile.dart';
import 'package:home_services/src/screen/consumer_jobs/consumer_jobs.dart';
import 'package:home_services/src/screen/consumer_transactions/consumer_transactions.dart';
import 'package:home_services/src/screen/favourite_professionals/favourite_professionals.dart';
import 'package:home_services/src/screen/login/login_screen.dart';
import 'package:home_services/src/screen/service_menu/service_menu.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/app_prefrences.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/common.dart';

class BuyerDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BuyerDrawerState();
  }
}

class BuyerDrawerState extends State<BuyerDrawer> {
  var user;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() async {
    var data = json.decode(await getUser());
    if (mounted) {
      setState(() {
        user = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Drawer(
      child: SingleChildScrollView(
        child: Container(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    height: size.height * 0.25,
                    decoration: BoxDecoration(
                        color: themeColor.primaryColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0))),
                  ),
                  SizedBox(height: size.height * 0.02),
                  ListTile(
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    leading: Image.asset(
                      "assets/icons/drawer-home.png",
                      height: 18,
                      width: 18,
                    ),
                    title: Text(
                      getTranslated(context, "home"),
                      style: textTheme.bodyText1
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ServiceMenu()));
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    leading: Image.asset(
                      "assets/icons/drawer-inbox.png",
                      height: 18,
                      width: 18,
                    ),
                    title: Text(
                      getTranslated(context, "inbox"),
                      style: textTheme.bodyText1
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChatList(
                                type: "buyer",
                              )));
                    },
                  ),
                  /*ListTile(
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    leading: Image.asset(
                      "assets/icons/drawer-notification.png",
                      height: 18,
                      width: 18,
                    ),
                    title: Text(
                      getTranslated(context, "notifications"),
                      style: textTheme.bodyText1
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    onTap: () {},
                  ),*/
                  ListTile(
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    leading: Image.asset(
                      "assets/icons/drawer-favourite.png",
                      height: 18,
                      width: 18,
                    ),
                    title: Text(
                      getTranslated(context, "favourites"),
                      style: textTheme.bodyText1
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FavouriteWorkersList()));
                    },
                  ),
                  Divider(
                    thickness: 1.0,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                        vertical: size.height * 0.01),
                    alignment: Alignment.topLeft,
                    child: Text(
                      getTranslated(context, "buying"),
                      style: textTheme.subtitle1
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    leading: Image.asset(
                      "assets/icons/drawer-wallet.png",
                      height: 18,
                      width: 18,
                    ),
                    title: Text(
                      getTranslated(context, "my_transactions"),
                      style: textTheme.bodyText1
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ConsumerTransactions()));
                    },
                  ),
                  /* ListTile(
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    leading: Image.asset(
                      "assets/icons/drawer-my-orders.png",
                      height: 18,
                      width: 18,
                    ),
                    title: Text(
                      getTranslated(context, "my_orders"),
                      style: textTheme.bodyText1
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => RequestSummary(
                                jobId: 96,
                                consumerId: 24,
                              )));
                    },
                  ), */
                  ListTile(
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    leading: Image.asset(
                      "assets/icons/drawer-my-orders.png",
                      height: 18,
                      width: 18,
                    ),
                    title: Text(
                      "My Jobs",
                      style: textTheme.bodyText1
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ConsumerJobs()));
                    },
                  ),
                  Divider(
                    thickness: 1.0,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                        vertical: size.height * 0.01),
                    alignment: Alignment.topLeft,
                    child: Text(
                      getTranslated(context, "general"),
                      style: textTheme.subtitle1
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    leading: Icon(
                      Icons.person_rounded,
                      color: Colors.black,
                    ),
                    title: Text(
                      "Edit Profile",
                      style: textTheme.bodyText1
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ConsumerEditProfile()));
                    },
                  ),
                  ListTile(
                    dense: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      showLogoutDialog(
                          context, "Are you sure you want to logout?");
                    },
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    leading: Icon(
                      Icons.logout,
                      color: Colors.black,
                    ),
                    title: Text(
                      "Logout",
                      style: textTheme.bodyText1
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: ((size.height * 0.25) - size.height * 0.2),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: size.width * 0.08,
                        child: ClipOval(
                          child: user != null
                              ? CachedNetworkImage(
                                  imageUrl:
                                      Constant.STORAGE_PATH + user['avatar'],
                                  fit: BoxFit.cover,
                                  width: size.width * 0.3,
                                  height: size.width * 0.3,
                                )
                              : Container(
                                  color: Colors.blue,
                                ),
                        ),
                      ),
                      Container(
                          padding:
                              EdgeInsets.symmetric(vertical: size.width * 0.01),
                          child: Container(
                            margin: EdgeInsets.only(left: size.width * 0.01),
                            child: Text(
                              user != null ? user['name'] : "",
                              style: textTheme.subtitle1
                                  .copyWith(color: primary_font),
                            ),
                          )),
                      Container(
                        width: size.width * 0.50,
                        child: RaisedButton(
                          color: Colors.white,
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BecomeSeller()));
                          },
                          child:
                              Text(getTranslated(context, "become_a_seller")),
                        ),
                      )
                    ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showLogoutDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: Container(
            child: Text(message),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text('Ok'),
              onPressed: () {
                UserApiProvider.logoutConsumer().then((value) {
                  if (!value['error']) {
                    clearPreferences();
                    HomeServices.setAppTheme(context, "buyer");
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false);
                  } else {
                    Navigator.pop(context);
                    showAlertDialog(context, value['message']);
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }
}
