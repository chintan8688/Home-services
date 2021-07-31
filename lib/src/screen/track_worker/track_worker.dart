import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:home_services/main.dart';
import 'package:home_services/src/screen/chat_screen/chat_screen.dart';
import 'package:home_services/src/screen/check_in_request/check_in_request.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';

class TrackWorker extends StatefulWidget {
  final consumerId, jobId, jobDetail;

  TrackWorker({
    @required this.jobId,
    @required this.consumerId,
    this.jobDetail,
  });

  @override
  State<StatefulWidget> createState() {
    return TrackWorkerState();
  }
}

class TrackWorkerState extends State<TrackWorker> with RouteAware {
  GlobalKey<ScaffoldState> key = GlobalKey();

  CameraPosition mapcenter = CameraPosition(
    target: LatLng(18.1096, 77.2975),
    zoom: 15.0,
  );
  Completer<GoogleMapController> _controller = Completer();
  Position currentPosition;
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  List<Marker> markers = <Marker>[];
  BitmapDescriptor markerIcon;

  bool isArrived = false;
  String km = "0.0";
  Timer timer;
  StreamSubscription _subscription, _locationSubscription;

  @override
  void initState() {
    super.initState();
    setMarkerIcon();
    checkChekInRequest();
    getWorkerLocation();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
    _locationSubscription?.cancel();
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
    _subscription.cancel();
    _locationSubscription?.cancel();
    _customInfoWindowController.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _subscription.cancel();
    _locationSubscription?.cancel();
    _customInfoWindowController.dispose();
  }

  setMarkerIcon() async {
    markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1.0),
        "assets/icons/icon-marker-buyer.png");
  }

  checkChekInRequest() async {
    _subscription = FirebaseFirestore.instance
        .collection("jobs")
        .where("consumer_id", isEqualTo: widget.consumerId)
        .where("job_id", isEqualTo: widget.jobId)
        .snapshots()
        .listen((event) {
      var data = event.docs?.map((e) => e.data())?.toList() ?? [];
      if (data[0]["check_in_request"] &&
          data[0]["order_completed"] == false &&
          data[0]["buyer_accepted"] == false) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CheckInRequest(
                jobId: widget.jobId,
                consumerId: widget.consumerId,
                professionalId: widget.jobDetail['professional_id'],
                consumerName: widget.jobDetail['consumer_name'])));
      }
    });
  }

  getWorkerLocation() {
    _locationSubscription = FirebaseFirestore.instance
        .collection("jobs_tracking")
        .where("consumer_id", isEqualTo: widget.consumerId)
        .where("job_id", isEqualTo: widget.jobId)
        .snapshots()
        .listen((event) {
      var data = event.docs?.map((e) => e.data())?.toList() ?? [];
      var pLongitude = data[0]['professional_longitude'];
      var pLatitude = data[0]['professional_latitude'];
      var cLatitude = data[0]['consumer_latitude'];
      var cLongitude = data[0]['consumer_longitude'];
      setMarker(cLatitude, cLongitude, pLatitude, pLongitude);
    });
  }

  setMarker(clatitude, clongitude, platitude, plongitude) async {
    CameraPosition pPosition = CameraPosition(
      zoom: 15.0,
      target: LatLng(platitude, plongitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(pPosition));
    var distanceInMeters = Geolocator.distanceBetween(
        platitude, plongitude, clatitude, clongitude);
    var distanceInKm = (distanceInMeters / 1000).toDouble().toStringAsFixed(1);
    if (distanceInKm == "0.0") {
      setState(() {
        markers.removeWhere((m) => m.markerId.value == "0");
        markers.add(Marker(
            markerId: MarkerId("0"),
            position: LatLng(platitude, plongitude),
            icon: markerIcon));
        km = distanceInKm;
        isArrived = true;
      });
      _locationSubscription.cancel();
    } else {
      setState(() {
        markers.removeWhere((m) => m.markerId.value == "0");
        markers.add(Marker(
            markerId: MarkerId("0"),
            position: LatLng(platitude, plongitude),
            icon: markerIcon));
        km = distanceInKm;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
        key: key,
        drawer: BuyerDrawer(),
        appBar: primaryAppBar(context, "track_worker", key),
        extendBodyBehindAppBar: true,
        body: Container(
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
                            _controller.complete(controller);
                            _customInfoWindowController.googleMapController =
                                controller;
                          },
                          /* onTap: (position) {
                              _customInfoWindowController.hideInfoWindow();
                            },
                            onCameraMove: (position) {
                              _customInfoWindowController.onCameraMove();
                            }, */
                        ),
                        /* CustomInfoWindow(
                            controller: _customInfoWindowController,
                            height: size.height * 0.25,
                            width: size.width * 0.8,
                            offset: 100,
                          ), */
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
                              offset:
                                  Offset(0, 3), // changes position of shadow
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              size: 30,
                              color: grey_color,
                            ),
                            Container(
                              padding: EdgeInsets.only(left: size.width * 0.05),
                              child: Text(
                                '${km + " " + getTranslated(context, "meter_away")}',
                                style: textTheme.subtitle1
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                      Visibility(
                          visible: isArrived,
                          child: Container(
                              child: Text(
                            getTranslated(context, "arrived"),
                            style: textTheme.headline6.copyWith(
                                fontWeight: FontWeight.bold,
                                color: themeColor.primaryColor),
                          ))),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: size.width * 0.4,
                            height: size.height * 0.06,
                            child: RaisedButton(
                              textColor: primary_font,
                              child: Text(
                                getTranslated(context, "track_work"),
                                textAlign: TextAlign.center,
                              ),
                              onPressed: () async {
                                /* if (isArrived) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => TrackWork()));
                                  } */
                              },
                            ),
                          ),
                          Container(
                            width: size.width * 0.4,
                            height: size.height * 0.06,
                            child: RaisedButton(
                              textColor: primary_font,
                              child: Text(
                                getTranslated(context, "chat"),
                                textAlign: TextAlign.center,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                              type: "buyer",
                                              professionalId: widget
                                                  .jobDetail['professional_id'],
                                              consumerId: widget.consumerId,
                                              consumerName: widget
                                                  .jobDetail['consumer_name'],
                                              professionalName:
                                                  widget.jobDetail[
                                                      'professional_name'],
                                              consumerAvatar: widget
                                                  .jobDetail['consumer_avatar'],
                                              professionalAvatar:
                                                  widget.jobDetail[
                                                      'professional_avatar'],
                                            )));
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
