import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:home_services/src/screen/login/login_screen.dart';
import 'package:home_services/src/screen/request_summary/request_summary.dart';
import 'package:home_services/src/screen/service_menu/service_menu.dart';
import 'package:home_services/src/screen/track_work/track_work.dart';
import 'package:home_services/src/screen/work_in_progress/work_in_progress.dart';
import 'package:home_services/src/utills/app_prefrences.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkIsUserSigned();
  }

  checkIsUserSigned() {
    getUserToken().then((token) {
      if (token != null) {
        getNotificationData().then((data) {
          if (data != null) {
            var notification = json.decode(data);
            navigateToNotifyScreen(notification);
            clearNotificationData();
          } else {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 2000), () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => ServiceMenu()));
              });
            });
          }
        });
      } else {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 2000), () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()));
          });
        });
      }
    });
  }

  navigateToNotifyScreen(notification) {
    if (notification['screen'] == "home") {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ServiceMenu()));
        });
      });
    } else if (notification['screen'] == "request_summary") {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => RequestSummary(
                    consumerId:
                        int.parse(notification['consumer_id'].toString()),
                    jobId: int.parse(notification['job_id'].toString()),
                  )));
        });
      });
    } else if (notification['screen'] == "check_in_request") {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ServiceMenu()));
        });
      });
    } else if (notification['screen'] == "work_in_progress") {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => WorkInProgress(
                    consumerId:
                        int.parse(notification['consumer_id'].toString()),
                    jobId: int.parse(notification['job_id'].toString()),
                  )));
        });
      });
    } else if (notification['screen'] == "order_completed") {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => TrackWork(
                    consumerId:
                        int.parse(notification['consumer_id'].toString()),
                    jobId: int.parse(notification['job_id'].toString()),
                  )));
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      child: Center(
          child: Image.asset(
        'assets/icons/splash.png',
        fit: BoxFit.cover,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      )),
    );
  }
}
