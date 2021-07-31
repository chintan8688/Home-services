import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/main.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/order_completed_seller/order_completed_seller.dart';
import 'package:home_services/src/utills/app_prefrences.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:home_services/src/widget/seller_drawer.dart';
import 'package:timezone/standalone.dart' as tz;

class WorkInProgress extends StatefulWidget {
  final jobId, consumerId;

  WorkInProgress({
    @required this.jobId,
    @required this.consumerId,
  });

  @override
  State<StatefulWidget> createState() {
    return WorkInProgressState();
  }
}

class WorkInProgressState extends State<WorkInProgress> with RouteAware {
  GlobalKey<ScaffoldState> key = GlobalKey();
  Timer timer;
  int hours = 0, minutes = 0, seconds = 0;
  var isJobCompleted = false, user;

  @override
  void initState() {
    super.initState();
    getUser().then((value) {
      user = json.decode(value);
    });
    checkWorkTime();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      runWatch();
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
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
    timer?.cancel();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    timer?.cancel();
  }

  checkout() {
    var jamaica = tz.getLocation('America/Jamaica');
    var jamaicaCurrentTime = tz.TZDateTime.now(jamaica).toString();
    timer?.cancel();
    UserApiProvider.checkout(widget.jobId, jamaicaCurrentTime).then((value) {
      if (value['result']) {
        var notification = {
          "notification": {
            "title": 'Job Completed',
            "body": "${user['name']} completed your job."
          },
          "priority": "high",
          "data": {
            "job_id": widget.jobId,
            "consumer_id": widget.consumerId,
            "screen": "order_completed",
            "click_action": "FLUTTER_NOTIFICATION_CLICK"
          },
          "to": value['consumer_device_token']
        };
        UserApiProvider.sendPushNotification(notification).then((result) {
          FirebaseFirestore.instance
              .collection("jobs")
              .where('job_id', isEqualTo: widget.jobId)
              .get()
              .then((value) => value.docs.forEach((element) {
                    element.reference.update({
                      "order_completed": true,
                      "complete_time": jamaicaCurrentTime
                    }).then((value) =>
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => OrderCompletedSeller(
                                  jobId: widget.jobId,
                                  consumerId: widget.consumerId,
                                  fromJobs: false,
                                ))));
                  }));
        });
      }
    });
  }

  runWatch() {
    if (mounted) {
      if (isJobCompleted) {
        timer.cancel();
      } else {
        if (seconds != 59) {
          setState(() {
            seconds++;
          });
        } else {
          if (minutes == 59) {
            setState(() {
              minutes = 0;
              seconds = 0;
              hours++;
            });
          } else {
            setState(() {
              minutes++;
              seconds = 0;
            });
          }
        }
      }
    }
  }

  checkWorkTime() {
    var jamaica = tz.getLocation('America/Jamaica');
    var jamaicaCurrentTime = tz.TZDateTime.now(jamaica).toString();
    FirebaseFirestore.instance
        .collection("jobs")
        .where('job_id', isEqualTo: widget.jobId)
        .where("buyer_accepted", isEqualTo: true)
        .get()
        .then((value) {
      var data = value.docs.map((e) => e.data()).toList();
      String startTime = data[0]["start_time"];
      String currentTime = jamaicaCurrentTime;
      DateTime jobStartTime = DateTime.parse(startTime);
      DateTime currentJobTime = DateTime.parse(currentTime);
      Duration diff = currentJobTime.difference(jobStartTime);
      if (mounted) {
        setState(() {
          hours = diff.inHours;
          minutes = diff.inMinutes.remainder(60);
          seconds = diff.inSeconds.remainder(60);
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
      drawer: SellerDrawer(),
      appBar: primaryAppBar(context, "work_in_progress", key),
      body: Container(
        height: size.height,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: size.height * 0.1),
              child: Text(
                getTranslated(context, "work_in_progress"),
                style: textTheme.headline6,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: size.height * 0.06),
              child: Image.asset(
                "assets/icons/icon-tracker-seller.png",
                height: size.height * 0.2,
                width: size.width * 0.4,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: size.height * 0.03),
              child: Text(
                '${hours.toString().padLeft(2, '0')} : ${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}',
                style: textTheme.headline3.copyWith(
                    fontWeight: FontWeight.bold, color: themeColor.accentColor),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: size.height * 0.15),
              width: size.width * 0.5,
              height: size.height * 0.06,
              child: RaisedButton(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.005),
                child: Text(
                  getTranslated(context, "check_out"),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  checkout();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
