import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/main.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/order_completed/order_completed.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:timezone/standalone.dart' as tz;

class TrackWork extends StatefulWidget {
  final jobId, consumerId;

  TrackWork({
    this.jobId,
    this.consumerId,
  });

  @override
  State<StatefulWidget> createState() {
    return TrackWorkState();
  }
}

class TrackWorkState extends State<TrackWork> with RouteAware {
  GlobalKey<ScaffoldState> key = GlobalKey();
  bool isJobCompleted = false, running = true, isLoading = false;
  Timer timer;
  String time = "00:00:00";
  int hours = 0, minutes = 0, seconds = 0;
  int extraHours = 0, extraMinutes = 0, extraSeconds = 0;
  var jobDetail;
  StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    getJobDetail();
    checkWorkTime();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => runWatch());
    //checkOrderCompleted();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    subscription?.cancel();
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
    subscription?.cancel();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    timer?.cancel();
    subscription?.cancel();
  }

  getJobDetail() {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    UserApiProvider.jobDetailForConsumer(widget.jobId).then((value) {
      setState(() {
        isLoading = false;
      });
      if (value['result']) {
        if (mounted) {
          setState(() {
            jobDetail = value['job_details'];
          });
        }
      }
    });
  }

  checkWorkTime() async {
    var jamaica = tz.getLocation('America/Jamaica');
    var jamaicaCurrentTime = tz.TZDateTime.now(jamaica).toString();
    FirebaseFirestore.instance
        .collection("jobs")
        .where('job_id', isEqualTo: widget.jobId)
        .where('consumer_id', isEqualTo: widget.consumerId)
        .where("buyer_accepted", isEqualTo: true)
        .get()
        .then((value) {
      var data = value.docs.map((e) => e.data()).toList();
      if (data[0]['order_completed']) {
        String startTime = data[0]["start_time"];
        String completeTime = data[0]['complete_time'];
        DateTime jobStartTime = DateTime.parse(startTime);
        DateTime jobCompleteTime = DateTime.parse(completeTime);
        Duration diff = jobCompleteTime.difference(jobStartTime);
        if (mounted) {
          setState(() {
            timer.cancel();
            hours = diff.inHours;
            minutes = diff.inMinutes.remainder(60);
            seconds = diff.inSeconds.remainder(60);
            isJobCompleted = true;
          });
        }
        subscription?.cancel();
      } else {
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
        checkOrderCompleted();
      }
    });
  }

  checkOrderCompleted() {
    subscription = FirebaseFirestore.instance
        .collection("jobs")
        .where('consumer_id', isEqualTo: widget.consumerId)
        .where("job_id", isEqualTo: widget.jobId)
        .where("buyer_accepted", isEqualTo: true)
        .snapshots()
        .listen((event) {
      var data = event.docs?.map((e) => e.data())?.toList() ?? [];
      if (data[0]["order_completed"]) {
        if (mounted) {
          setState(() {
            timer?.cancel();
            isJobCompleted = true;
          });
          subscription?.cancel();
        }
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    return Scaffold(
      key: key,
      drawer: BuyerDrawer(),
      appBar: primaryAppBar(context, "track_work", key),
      extendBodyBehindAppBar: isLoading,
      body: isLoading
          ? loadingData(context)
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(size.height * 0.009),
                    margin: EdgeInsets.only(top: size.height * 0.04),
                    child: isJobCompleted
                        ? RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(
                                  text:
                                      "Your order OO-${jobDetail['work_date']}-${jobDetail['id']} is now in ",
                                  style: textTheme.headline6),
                              TextSpan(
                                  text: "Completed",
                                  style: textTheme.headline6
                                      .copyWith(color: themeColor.primaryColor))
                            ]))
                        : RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(
                                  text:
                                      "Your order OO-${jobDetail['work_date']}-${jobDetail['id']} is now in ",
                                  style: textTheme.headline6),
                              TextSpan(
                                  text: "Progress",
                                  style: textTheme.headline6
                                      .copyWith(color: Color(0xFFFF7713)))
                            ])),
                  ),
                  Container(
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
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        )),
                    margin: EdgeInsets.symmetric(vertical: size.height * 0.03),
                    padding: EdgeInsets.all(size.height * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.asset(
                          "assets/icons/icon-tracker.png",
                          height: size.height * 0.1,
                          width: size.width * 0.2,
                        ),
                        Text(
                          '${hours.toString().padLeft(2, '0')} : ${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}',
                          style: textTheme.headline4.copyWith(
                              color: button_secondary,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(size.height * 0.009),
                    child: isJobCompleted
                        ? Text(
                            jobDetail['professional_name'] +
                                " " +
                                "has successfully completed your job.",
                            style: textTheme.headline6,
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            jobDetail['professional_name'] +
                                " " +
                                "has working on your job.",
                            style: textTheme.headline6,
                            textAlign: TextAlign.center,
                          ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: size.height * 0.02),
                    child: Divider(),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: size.height * 0.02),
                    height:
                        isJobCompleted ? size.height * 0.26 : size.height * 0.1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getTranslated(context, "package_selected"),
                              style: textTheme.subtitle1,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.005),
                              child: Text(
                                "JMD" +
                                    jobDetail['package_price'].toString() +
                                    " " +
                                    jobDetail['package_name'],
                                style: textTheme.subtitle1.copyWith(
                                    color: themeColor.primaryColor,
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          ],
                        ),
                        VerticalDivider(),
                        isJobCompleted
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    child: Text(
                                      getTranslated(
                                          context, "job_time_duration"),
                                      style: textTheme.subtitle1,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.005),
                                    child: Text(
                                        '${hours.toString().padLeft(2, '0')} : ${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}',
                                        style: textTheme.subtitle1.copyWith(
                                            color: themeColor.primaryColor,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.008),
                                    child: Text(
                                      getTranslated(
                                          context, "basic_package_duration"),
                                      style: textTheme.subtitle1,
                                    ),
                                  ),
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.005),
                                      child: Text("01:00:00",
                                          style: textTheme.subtitle1.copyWith(
                                              color: themeColor.primaryColor,
                                              fontWeight: FontWeight.w700))),
                                  Container(
                                    padding: EdgeInsets.only(
                                        top: size.height * 0.008),
                                    child: Text(
                                      getTranslated(
                                          context, "extra_time_duration"),
                                      style: textTheme.subtitle1,
                                    ),
                                  ),
                                  Container(
                                      padding: EdgeInsets.only(
                                          top: size.height * 0.005),
                                      child: Text("00:00:00",
                                          style: textTheme.subtitle1.copyWith(
                                              color: themeColor.primaryColor,
                                              fontWeight: FontWeight.w700)))
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    getTranslated(context, "extra_hourly_rate"),
                                    style: textTheme.subtitle1,
                                  ),
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.005),
                                      child: Text(
                                          jobDetail['additional_price']
                                                  .toString() +
                                              " " +
                                              "JMD/h",
                                          style: textTheme.subtitle1.copyWith(
                                              color: themeColor.primaryColor,
                                              fontWeight: FontWeight.w700)))
                                ],
                              )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: size.height * 0.02),
                    child: Divider(),
                  ),
                  Container(
                    padding: EdgeInsets.all(size.height * 0.009),
                    child: Text(getTranslated(context, "charges_note")),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: size.height * 0.02),
                    child: Divider(),
                  ),
                  Container(
                    padding: EdgeInsets.all(size.height * 0.009),
                    child: isJobCompleted
                        ? Container(
                            width: size.width * 0.8,
                            height: size.height * 0.06,
                            child: RaisedButton(
                              textColor: primary_font,
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.005),
                              child: Text(
                                getTranslated(context, "rate_seller"),
                                textAlign: TextAlign.center,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OrderCompleted(
                                            jobId: widget.jobId,
                                            consumerId: widget.consumerId,
                                            fromJobs: false)));
                              },
                            ),
                          )
                        : Text(
                            'Thanks for choosing Click Away!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                  )
                ],
              ),
            ),
    );
  }
}
