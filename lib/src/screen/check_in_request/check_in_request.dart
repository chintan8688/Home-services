import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/service_menu/service_menu.dart';
import 'package:home_services/src/screen/track_work/track_work.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:timezone/standalone.dart' as tz;

class CheckInRequest extends StatefulWidget {
  final jobId, consumerId, professionalId, consumerName;

  CheckInRequest(
      {this.jobId, this.consumerId, this.professionalId, this.consumerName});

  @override
  State<StatefulWidget> createState() {
    return CheckInRequestState();
  }
}

class CheckInRequestState extends State<CheckInRequest> {
  GlobalKey<ScaffoldState> key = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  rejectRequest(BuildContext context) {
    showActionDialog(context, "Are you sure you want to cancel request?");
  }

  Future<void> showActionDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alert"),
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
                FirebaseFirestore.instance
                    .collection("jobs")
                    .where('job_id', isEqualTo: widget.jobId)
                    .get()
                    .then((value) => value.docs.forEach((element) {
                          element.reference.update({
                            "check_in_request": false,
                            "buyer_accepted": false
                          }).then((value) => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ServiceMenu()),
                              (Route<dynamic> route) => false));
                        }));
              },
            ),
          ],
        );
      },
    );
  }

  acceptRequest(BuildContext context) async {
    var jamaica = tz.getLocation('America/Jamaica');
    var jamaicaCurrentTime = tz.TZDateTime.now(jamaica).toString();
    var jamaicaTimeZone = tz.TZDateTime.now(jamaica).timeZoneName;
    //var checkInTime = DateTime.now().toIso8601String();
    //var timeZone = DateTime.now().timeZoneName;
    UserApiProvider.checkinAccept(widget.jobId, widget.professionalId,
            jamaicaCurrentTime, jamaicaTimeZone)
        .then((value) {
      if (value['result']) {
        var notification = {
          "notification": {
            "title": 'CheckIn Request',
            "body": "${widget.consumerName} accept your check in request"
          },
          "priority": "high",
          "data": {
            "job_id": widget.jobId,
            "consumer_id": widget.consumerId,
            "screen": "work_in_progress",
            "click_action": "FLUTTER_NOTIFICATION_CLICK"
          },
          "to": value['professional_device_token']
        };
        UserApiProvider.sendPushNotification(notification).then((result) {
          FirebaseFirestore.instance
              .collection("jobs")
              .where('job_id', isEqualTo: widget.jobId)
              .get()
              .then((value) => value.docs.forEach((element) {
                    element.reference.update({
                      "buyer_accepted": true,
                      "start_time": jamaicaCurrentTime
                    }).then((value) =>
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => TrackWork(
                                  jobId: widget.jobId,
                                  consumerId: widget.consumerId,
                                ))));
                  }));
        });
      }
    });
  }

  loadingDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              ),
              Container(
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.05),
                child: Text(getTranslated(context, "loading")),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    return Scaffold(
      key: key,
      drawer: BuyerDrawer(),
      appBar: primaryAppBar(context, "track_work", key),
      body: Container(
        height: size.height,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: size.height * 0.1),
                  child: Text(
                    getTranslated(context, "job_not_started_yet"),
                    style: textTheme.headline6,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: size.height * 0.1),
                  child: Image.asset(
                    "assets/icons/icon-tracker.png",
                    height: size.height * 0.15,
                    width: size.width * 0.5,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: size.height * 0.1),
                  child: Text(
                    "00 : 00 : 00",
                    style: textTheme.headline4.copyWith(
                        color: button_secondary, fontWeight: FontWeight.w700),
                  ),
                )
              ],
            ),
            Column(
              children: [
                Container(
                  width: size.width,
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.04),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 7,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          "Check in request",
                          style: textTheme.headline6
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.02),
                        child: Text(
                          "Andrew want to start work on your request",
                          style: textTheme.subtitle1.copyWith(fontSize: 18),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: size.width * 0.42,
                              height: size.height * 0.06,
                              child: RaisedButton(
                                color: primary_color_seller,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.005),
                                child: Text(
                                  getTranslated(context, "reject"),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () async {
                                  rejectRequest(context);
                                },
                              ),
                            ),
                            Container(
                              width: size.width * 0.42,
                              height: size.height * 0.06,
                              child: RaisedButton(
                                textColor: primary_font,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.005),
                                child: Text(
                                  getTranslated(context, "accept"),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () {
                                  acceptRequest(context);
                                },
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
