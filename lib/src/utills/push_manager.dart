import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:home_services/main.dart';
import 'package:home_services/src/screen/request_summary/request_summary.dart';
import 'package:home_services/src/screen/track_work/track_work.dart';
import 'package:home_services/src/screen/work_in_progress/work_in_progress.dart';
import 'package:home_services/src/utills/app_prefrences.dart';

class PushNotificationsManager {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Future<void> init() async {
    // For iOS request permission first.
    _firebaseMessaging.requestNotificationPermissions();

    String token = await _firebaseMessaging.getToken();
    print("FirebaseMessaging token: $token");

    setDeviceToken(token);

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {},
      onLaunch: (Map<String, dynamic> message) async {
        if (message['data']['route'].toString() != null) {
          setNotificationData(json.encode(message['data']));
        }
      },
      onResume: (Map<String, dynamic> message) async {
        navigateToNotifyScreen(message['data']);
      },
    );
  }

  navigateToNotifyScreen(notification) {
    if (notification['screen'].toString() == "home") {
      /*navigatorKey.currentState
          .push(MaterialPageRoute(builder: (context) => ServiceMenu()));*/
    } else if (notification['screen'] == "request_summary") {
      navigatorKey.currentState.pushReplacement(MaterialPageRoute(
          builder: (context) => RequestSummary(
                consumerId: int.parse(notification['consumer_id'].toString()),
                jobId: int.parse(notification['job_id'].toString()),
              )));
    } else if (notification['screen'] == "check_in_request") {
      /*navigatorKey.currentState.push(MaterialPageRoute(
          builder: (context) => CheckInRequest(
                consumerName: notification['consumer_name'],
                consumerId: int.parse(notification['consumer_id'].toString()),
                jobId: int.parse(notification['job_id'].toString()),
                professionalId:
                    int.parse(notification['professional_id'].toString()),
              )));*/
    } else if (notification['screen'] == "work_in_progress") {
      navigatorKey.currentState.pushReplacement(MaterialPageRoute(
          builder: (context) => WorkInProgress(
                consumerId: int.parse(notification['consumer_id'].toString()),
                jobId: int.parse(notification['job_id'].toString()),
              )));
    } else if (notification['screen'] == "order_completed") {
      navigatorKey.currentState.pushReplacement(MaterialPageRoute(
          builder: (context) => TrackWork(
                consumerId: int.parse(notification['consumer_id'].toString()),
                jobId: int.parse(notification['job_id'].toString()),
              )));
    }
  }
}
