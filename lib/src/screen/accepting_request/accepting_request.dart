import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:home_services/main.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/job_details_seller/job_details_seller.dart';
import "package:home_services/src/screen/order_summary_seller/order_summary_seller.dart";
import 'package:home_services/src/screen/service_menu/service_menu.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:home_services/src/widget/seller_drawer.dart';

class AcceptRequest extends StatefulWidget {
  final jobId, consumerId;

  AcceptRequest({this.jobId, this.consumerId});

  @override
  State<StatefulWidget> createState() {
    return AcceptRequestState();
  }
}

class AcceptRequestState extends State<AcceptRequest> with RouteAware {
  GlobalKey<ScaffoldState> key = GlobalKey();

  CameraPosition mapcenter = CameraPosition(
    target: LatLng(18.1096, 77.2975),
    zoom: 15.0,
  );
  Completer<GoogleMapController> _controller = Completer();
  Position currentPosition;
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  StreamSubscription subscription;

  bool isArrived = false, isLoading = false;
  int minutes = 01, seconds = 10;
  String km = "0.0";
  String countDownTime = "00 : 00";
  var jobDetail;

  List<Marker> markers = <Marker>[];
  BitmapDescriptor markerIcon;

  Timer timer;

  @override
  void initState() {
    super.initState();
    setMarkerIcon();
    locateConsumer();
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
    timer?.cancel();
    _customInfoWindowController.dispose();
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
    subscription?.cancel();
    timer?.cancel();
    _customInfoWindowController.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    subscription?.cancel();
    timer?.cancel();
    _customInfoWindowController.dispose();
  }

  setMarkerIcon() async {
    markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1.0),
        "assets/icons/icon-marker-seller.png");
  }

  locateConsumer() {
    getLocationPermission().then((position) {
      if (mounted) {
        setState(() {
          currentPosition = position;
        });
      }
      FirebaseFirestore.instance
          .collection("jobs")
          .where('consumer_id', isEqualTo: widget.consumerId)
          .where("job_id", isEqualTo: widget.jobId)
          .get()
          .then((value) async {
        var data = value.docs.map((e) => e.data()).toList();
        var distanceInMeters = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            data[0]['consumer_latitude'],
            data[0]['consumer_longitude']);
        GoogleMapController controller = await _controller.future;

        controller.moveCamera(CameraUpdate.newLatLngZoom(
            LatLng(data[0]['consumer_latitude'], data[0]['consumer_longitude']),
            15.0));

        UserApiProvider.jobDetailForProfessional(widget.jobId).then((value) {
          if (value['result']) {
            jobDetail = value['job_details'];
            setMarker(
                value['job_details'],
                data[0]['consumer_latitude'],
                data[0]['consumer_longitude'],
                (distanceInMeters / 1000).toDouble().toStringAsPrecision(1));
          }
        });
      });
    });
  }

  setMarker(consumerData, consumerLatitude, consumerLongitude, distance) {
    var consumerMarker = Marker(
        markerId: MarkerId(consumerData['id'].toString()),
        position: LatLng(consumerLatitude, consumerLongitude),
        icon: markerIcon,
        onTap: () {
          _customInfoWindowController.addInfoWindow(
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => JobDetailsSeller(
                              job: consumerData,
                            )));
              },
              child: Column(
                children: [
                  Flexible(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(consumerData['consumer_name'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        .copyWith(color: primary_font)),
                                Container(
                                  padding: EdgeInsets.only(left: 5),
                                  child: GFRating(
                                      size: 14,
                                      color: primary_font,
                                      borderColor: primary_font,
                                      value: consumerData['consumer_rating']
                                                  ['average_rating'] !=
                                              null
                                          ? double.parse(
                                              consumerData['consumer_rating']
                                                      ['average_rating']
                                                  .toString())
                                          : 0.0),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text(
                                      '(${consumerData['consumer_rating']['rating_count'].toString()})',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          .copyWith(color: primary_font)),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text(
                                consumerData['address'].toString().length > 80
                                    ? consumerData['address']
                                            .toString()
                                            .substring(0, 80) +
                                        "..."
                                    : consumerData['address'],
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(color: primary_font)),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text(
                                "Mobile: " +
                                            consumerData[
                                                'consumer_phone_code'] ==
                                        null
                                    ? consumerData['consumer_phone']
                                    : consumerData['consumer_phone_code'] +
                                        " " +
                                        consumerData['consumer_phone'],
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(color: primary_font)),
                            Text(
                                "Schedule Start time: " +
                                    consumerData['work_date'],
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(color: primary_font)),
                            Text(
                                "Package Selected: JMD" +
                                    consumerData['package_price'].toString() +
                                    " " +
                                    consumerData['package_name'],
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(color: primary_font)),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text("View Details",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(color: primary_font)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            LatLng(consumerLatitude, consumerLongitude),
          );
        });
    if (mounted) {
      setState(() {
        markers.add(consumerMarker);
        km = distance;
      });
    }
  }

  checkIsBuyerPay() {
    subscription = FirebaseFirestore.instance
        .collection("jobs")
        .where('consumer_id', isEqualTo: widget.consumerId)
        .where("job_id", isEqualTo: widget.jobId)
        .snapshots()
        .listen((event) {
      var data = event.docs?.map((e) => e.data())?.toList() ?? [];
      if (data[0]["payment_done"] && data[0]["order_completed"] == false) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderSummarySeller(
                    jobId: widget.jobId, consumerId: widget.consumerId)));
      }
    });
  }

  consumerNotPay() async {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    subscription?.cancel();
    timer?.cancel();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alert"),
          content: Container(
            child:
                Text("${jobDetail['consumer_name']} didn't pay at the moment."),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => ServiceMenu()),
                    (Route<dynamic> route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  acceptJobRequest() {
    UserApiProvider.jobRequestAcceptReject(true, widget.jobId).then((res) {
      if (res['result']) {
        var notification = {
          "notification": {
            "title": "${jobDetail['title']}",
            "body":
                '${jobDetail['professional_name']} accepted your job request'
          },
          "priority": "high",
          "data": {
            "job_id": jobDetail['id'],
            "consumer_id": jobDetail['consumer_id'],
            "screen": "request_summary",
            "click_action": "FLUTTER_NOTIFICATION_CLICK"
          },
          "to": res['consumer_device_token']
        };
        UserApiProvider.sendPushNotification(notification).then((result) {
          FirebaseFirestore.instance
              .collection("jobs")
              .where('job_id', isEqualTo: widget.jobId)
              .get()
              .then((value) => value.docs.forEach((element) {
                    element.reference.update({
                      "professional_latitude": currentPosition.latitude,
                      "professional_longitude": currentPosition.longitude,
                      "seller_accepted": true,
                    }).then((value) {
                      FirebaseFirestore.instance
                          .collection("jobs_tracking")
                          .where('job_id', isEqualTo: widget.jobId)
                          .get()
                          .then((res) => res.docs.forEach((element) {
                                element.reference.update({
                                  "professional_latitude":
                                      currentPosition.latitude,
                                  "professional_longitude":
                                      currentPosition.longitude,
                                }).then((value) {
                                  /*Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              OrderSummarySeller(
                                                jobId: widget.jobId,
                                                consumerId: widget.consumerId,
                                              )));*/
                                  setState(() {
                                    isLoading = true;
                                  });
                                  checkIsBuyerPay();
                                  timer = Timer(Duration(minutes: 5), () {
                                    consumerNotPay();
                                  });
                                });
                              }));
                    });
                  }));
        });
      }
    });
  }

  rejectJobRequest() {
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
                UserApiProvider.jobRequestAcceptReject(false, widget.jobId)
                    .then((value) {
                  if (value['result']) {
                    var notification = {
                      "notification": {
                        "title": "${jobDetail['title']}",
                        "body":
                            '${jobDetail['professional_name']} rejected your job request'
                      },
                      "priority": "high",
                      "data": {
                        "job_id": jobDetail['id'],
                        "consumer_id": jobDetail['consumer_id'],
                        "screen": "home",
                        "click_action": "FLUTTER_NOTIFICATION_CLICK"
                      },
                      "to": value['consumer_device_token']
                    };
                    UserApiProvider.sendPushNotification(notification)
                        .then((result) {
                      FirebaseFirestore.instance
                          .collection("jobs")
                          .where('job_id', isEqualTo: widget.jobId)
                          .get()
                          .then((value) => value.docs.forEach((element) {
                                element.reference.update({
                                  "seller_rejected": true,
                                }).then((value) {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ServiceMenu()),
                                      (Route<dynamic> route) => false);
                                });
                              }));
                    });
                  }
                });
              },
            ),
          ],
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
      drawer: SellerDrawer(),
      appBar: primaryAppBar(context, "accepting_request", key),
      extendBodyBehindAppBar: true,
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: size.width * 0.8,
                    padding:
                        EdgeInsets.symmetric(vertical: size.height * 0.008),
                    child: Text(
                      "Please wait while payment done by" +
                          " " +
                          jobDetail['consumer_name'],
                      textAlign: TextAlign.center,
                      style: textTheme.headline6,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: size.height * 0.04),
                    child: CircularProgressIndicator(),
                  )
                ],
              ),
            )
          : Container(
              height: size.height,
              width: size.width,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: size.height * 0.75,
                        child: Stack(
                          children: [
                            GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: mapcenter,
                              markers: Set<Marker>.of(markers),
                              myLocationEnabled: true,
                              onMapCreated: (GoogleMapController controller) {
                                if (!_controller.isCompleted) {
                                  _controller.complete(controller);
                                }
                                _customInfoWindowController
                                    .googleMapController = controller;
                              },
                              onTap: (position) {
                                _customInfoWindowController.hideInfoWindow();
                              },
                              onCameraMove: (position) {
                                _customInfoWindowController.onCameraMove();
                              },
                            ),
                            CustomInfoWindow(
                              controller: _customInfoWindowController,
                              height: size.height * 0.24,
                              width: size.width * 0.8,
                              offset: 100,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: -10,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: size.height * 0.03,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 7,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30))),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: EdgeInsets.all(size.height * 0.009),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.access_time_outlined,
                                  size: 28,
                                ),
                                Container(
                                  child: Text(
                                    '${" " + km + getTranslated(context, "meter_away")}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                          ),
                          /*Container(
                          child: Text(
                            countDownTime,
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(
                                    color:
                                        themeColor.accentColor.withOpacity(0.8),
                                    fontWeight: FontWeight.w700),
                          ),
                        ),*/
                          Container(
                            //margin: EdgeInsets.only(top: size.height * 0.03),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: size.width * 0.4,
                                  height: size.height * 0.06,
                                  child: RaisedButton(
                                    child: Text(
                                      getTranslated(context, "accept"),
                                      textAlign: TextAlign.center,
                                    ),
                                    onPressed: () {
                                      acceptJobRequest();
                                    },
                                  ),
                                ),
                                Container(
                                  width: size.width * 0.4,
                                  height: size.height * 0.06,
                                  child: RaisedButton(
                                    color:
                                        themeColor.accentColor.withOpacity(0.8),
                                    child: Text(
                                      getTranslated(context, "cancel"),
                                      textAlign: TextAlign.center,
                                    ),
                                    onPressed: () {
                                      rejectJobRequest();
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
