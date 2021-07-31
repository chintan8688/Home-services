import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/app.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/bank_details/bank_details.dart';
import 'package:home_services/src/screen/chat_list/chat_list.dart';
import 'package:home_services/src/screen/edit_become_seller/edit_become_seller.dart';
import 'package:home_services/src/screen/login/login_screen.dart';
import 'package:home_services/src/screen/my_jobs/my_jobs.dart';
import 'package:home_services/src/screen/professional_edit_profile/professional_edit_profile.dart';
import 'package:home_services/src/screen/seller_jobs_calendar/seller_jobs_calendar.dart';
import 'package:home_services/src/screen/service_menu/service_menu.dart';
import 'package:home_services/src/screen/update_services/update_services.dart';
import 'package:home_services/src/screen/wallet_details/wallet_details.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/app_prefrences.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/common.dart';

class SellerDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SellerDrawerState();
  }
}

class SellerDrawerState extends State<SellerDrawer> {
  bool isOnDuty = false;
  var user;
  String balance = "0.00";

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() {
    getUser().then((value) {
      var data = json.decode(value);
      getWalletBalance().then((bal) {
        if (mounted) {
          setState(() {
            balance = bal;
            user = data;
            isOnDuty = data['professional_details']['on_duty'] == 0 ||
                    data['professional_details']['on_duty'] == null
                ? false
                : true;
          });
        }
      });
    });
  }

  setIsOnDuty(value) async {
    UserApiProvider.changeDuty(value).then((res) {
      getUser().then((data) {
        var user = json.decode(data);
        user['professional_details']['on_duty'] = value ? 1 : 0;
        setUser(json.encode(user));
      });
    });
  }

  getBalance() {
    UserApiProvider.professionalWalletBalance().then((value) {
      if (value['result']) {
        setWalletBalance(value['balance']);
        if (mounted) {
          setState(() {
            balance = value['balance'];
          });
        }
      }
    });
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
                                type: "seller",
                              )));
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    leading: Image.asset(
                      "assets/icons/drawer-calendar.png",
                      height: 18,
                      width: 18,
                    ),
                    title: Text(
                      getTranslated(context, "calendar"),
                      style: textTheme.bodyText1
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SellerJobsCalendar()));
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

                  Column(
                    children: [
                      Divider(
                        thickness: 1.0,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.05,
                            vertical: size.height * 0.01),
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Selling",
                          style: textTheme.subtitle1
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      /*ListTile(
                        dense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        leading: Image.asset(
                          "assets/icons/drawer-sales.png",
                          height: 18,
                          width: 18,
                        ),
                        title: Text(
                          "Sales",
                          style: textTheme.bodyText1
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => OrderCompletedSeller()));
                        },
                      ),*/
                      ListTile(
                        dense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        leading: Image.asset(
                          "assets/icons/drawer-update-service.png",
                          height: 18,
                          width: 18,
                        ),
                        title: Text(
                          "Update My Services",
                          style: textTheme.bodyText1
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => UpdateServices()));
                        },
                      ),
                      /* ListTile(
                        dense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        leading: Image.asset(
                          "assets/icons/drawer-provide-quotes.png",
                          height: 18,
                          width: 18,
                        ),
                        title: Text(
                          "Provide Quotes",
                          style: textTheme.bodyText1
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ), */
                      ListTile(
                        dense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        leading: Image.asset(
                          "assets/icons/drawer-my-jobs.png",
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
                              builder: (context) => MyJobs()));
                        },
                      ),
                    ],
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
                              builder: (context) => ProfessionalEditProfile()));
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    leading: Icon(
                      Icons.edit,
                      color: Colors.black,
                    ),
                    title: Text(
                      "Professional Detail",
                      style: textTheme.bodyText1
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditBecomeSeller()));
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    leading: Image.asset(
                      "assets/icons/drawer-provide-quotes.png",
                      height: 18,
                      width: 18,
                    ),
                    title: Text(
                      "Bank Details",
                      style: textTheme.bodyText1
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BankDetails()));
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
                top: ((size.height * 0.25) - (size.height * 0.04 / 2)),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => WalletDetails()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: primary_background_color,
                        borderRadius: BorderRadius.circular(5.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 0.5,
                              blurRadius: 0.5)
                        ]),
                    height: size.height * 0.04,
                    width: size.height * 0.3,
                    padding:
                        EdgeInsets.symmetric(vertical: size.height * 0.005),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/drawer-wallet.png",
                          height: 18,
                          width: 18,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: size.width * 0.01),
                          child: Text("My Wallet: $balance JMD"),
                        ),
                        GestureDetector(
                          child: Container(
                            margin: EdgeInsets.only(left: size.width * 0.01),
                            child: Icon(
                              Icons.refresh,
                              size: 18,
                            ),
                          ),
                          onTap: () {
                            getBalance();
                          },
                        )
                      ],
                    ),
                  ),
                ),
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
                                  width: size.width * 0.2,
                                  height: size.width * 0.2,
                                )
                              : Container(
                                  color: Colors.blue,
                                ),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: size.width * 0.01),
                        child: Row(
                          children: [
                            Container(
                              height: size.width * 0.025,
                              width: size.width * 0.025,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: primary_color,
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.width * 0.01),
                                child: Container(
                                  margin:
                                      EdgeInsets.only(left: size.width * 0.01),
                                  child: Text(
                                    user != null ? user['name'] : "",
                                    style: textTheme.subtitle1
                                        .copyWith(color: primary_font),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Container(
                        height: size.height * 0.02,
                        child: Row(
                          children: [
                            Switch(
                                value: isOnDuty,
                                activeColor: primary_color,
                                activeTrackColor:
                                    primary_color.withOpacity(0.5),
                                onChanged: (value) {
                                  setState(() {
                                    isOnDuty = value;
                                  });
                                  setIsOnDuty(value);
                                }),
                            Container(
                              child: Text("Go off duty",
                                  style: textTheme.caption
                                      .copyWith(color: primary_font)),
                            )
                          ],
                        ),
                      ),
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
                UserApiProvider.logoutProfessional().then((value) {
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
