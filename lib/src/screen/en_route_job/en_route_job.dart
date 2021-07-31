import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:home_services/main.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/chat_screen/chat_screen.dart';
import 'package:home_services/src/screen/work_in_progress/work_in_progress.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:home_services/src/widget/seller_drawer.dart';

class EnRouteJob extends StatefulWidget {
  final jobId,
      consumerId,
      jobDetail,
      professionalId,
      professionalName,
      consumerName,
      consumerAvatar,
      professionalAvatar;

  EnRouteJob(
      {@required this.jobId,
      @required this.consumerId,
      this.jobDetail,
      this.professionalName,
      this.professionalId,
      this.consumerName,
      this.consumerAvatar,
      this.professionalAvatar});

  @override
  State<StatefulWidget> createState() {
    return EnRouteJobState();
  }
}

class EnRouteJobState extends State<EnRouteJob> with RouteAware {
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

  StreamSubscription subscription, initialSubscription;
  StreamSubscription<Position> positionStream;

  bool isArrived = false;
  String km = "0.0";
  Timer timer;

  @override
  void initState() {
    super.initState();
    setMarkerIcon();
    checkLocationPermission();
  }

  @override
  void dispose() {
    super.dispose();
    _customInfoWindowController.dispose();
    subscription?.cancel();
    positionStream?.cancel();
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
    _customInfoWindowController.dispose();
    subscription?.cancel();
    positionStream?.cancel();
    initialSubscription?.cancel();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _customInfoWindowController.dispose();
    subscription?.cancel();
    positionStream?.cancel();
    initialSubscription?.cancel();
  }

  setMarkerIcon() async {
    markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1.0),
        "assets/icons/icon-marker-seller.png");
  }

  checkLocationPermission() {
    getLocationPermission().then((value) async {
      initPlatformState(value);
    });
  }

  void initPlatformState(Position position) async {
    if (mounted) {
      setState(() {
        currentPosition = position;
      });
    }
    initialSubscription = FirebaseFirestore.instance
        .collection("jobs")
        .where('consumer_id', isEqualTo: widget.consumerId)
        .where("job_id", isEqualTo: widget.jobId)
        .snapshots()
        .listen((event) async {
      var data = event.docs?.map((e) => e.data())?.toList() ?? [];
      var distanceInMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          data[0]['consumer_latitude'],
          data[0]['consumer_longitude']);
      /* GoogleMapController controller = await _controller.future;
      controller.moveCamera(CameraUpdate.newLatLngZoom(
          LatLng(data[0]['consumer_latitude'], data[0]['consumer_longitude']),
          15.0)); */

      setConsumerMarker(
          data[0]['consumer_latitude'],
          data[0]['consumer_longitude'],
          position.latitude,
          position.longitude,
          (distanceInMeters / 1000).toDouble().toStringAsFixed(1));
    });
  }

  setConsumerMarker(clatitude, clongitude, platitude, plongitude, distance) {
    var consumerMarker = Marker(
        markerId: MarkerId("0"),
        position: LatLng(clatitude, clongitude),
        icon: markerIcon,
        onTap: () {
          _customInfoWindowController.addInfoWindow(
            Column(
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
                          Text(
                              widget.jobDetail['address'].toString().length > 80
                                  ? widget.jobDetail['address']
                                      .toString()
                                      .substring(0, 80)
                                  : widget.jobDetail['address'],
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
            LatLng(clatitude, clongitude),
          );
        });
    setState(() {
      markers.add(consumerMarker);
      km = distance;
    });
    updateCurrentLocation(clatitude, clongitude, distance);
    initialSubscription.cancel();
  }

  updateCurrentLocation(clatitude, clongitude, distance) {
    positionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.high,
            intervalDuration: Duration(seconds: 5))
        .listen((Position position) async {
      CameraPosition pPosition = CameraPosition(
        zoom: 15.0,
        target: LatLng(position.latitude, position.longitude),
      );
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(pPosition));
      var distanceInMeters = Geolocator.distanceBetween(
          position.latitude, position.longitude, clatitude, clongitude);
      var distanceInKm =
          (distanceInMeters / 1000).toDouble().toStringAsFixed(1);
      FirebaseFirestore.instance
          .collection("jobs_tracking")
          .where('job_id', isEqualTo: widget.jobId)
          .get()
          .then((value) => value.docs.forEach((element) {
                element.reference.update({
                  "professional_latitude": position.latitude,
                  "professional_longitude": position.longitude
                });
              }));
      if (distanceInKm == "0.0") {
        setState(() {
          km = distanceInKm;
          isArrived = true;
        });
        positionStream.cancel();
      } else {
        setState(() {
          km = distanceInKm;
        });
      }
    });
  }

  checkIsRequestAccepted() {
    subscription = FirebaseFirestore.instance
        .collection("jobs")
        .where('consumer_id', isEqualTo: widget.consumerId)
        .where("job_id", isEqualTo: widget.jobId)
        .snapshots()
        .listen((event) {
      var data = event.docs?.map((e) => e.data())?.toList() ?? [];
      if (data[0]["buyer_accepted"]) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WorkInProgress(
                      jobId: widget.jobId,
                      consumerId: widget.consumerId,
                    )));
      }
    });
  }

  requestCheckIn() {
    positionStream.cancel();
    var notification = {
      "notification": {
        "title": "${widget.jobDetail['title']}",
        "body": '${widget.jobDetail['professional_name']} request for check in'
      },
      "priority": "high",
      "data": {
        "job_id": widget.jobDetail['id'],
        "consumer_id": widget.jobDetail['consumer_id'],
        "professional_id": widget.jobDetail['professional_id'],
        "consumer_name": widget.jobDetail['consumer_name'],
        "screen": "check_in_request",
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      },
      "to": widget.jobDetail['consumer_device_token']
    };
    UserApiProvider.sendPushNotification(notification).then((result) {
      FirebaseFirestore.instance
          .collection("jobs")
          .where('job_id', isEqualTo: widget.jobId)
          .get()
          .then((value) => value.docs.forEach((element) {
                element.reference.update({"check_in_request": true}).then(
                    (value) => checkIsRequestAccepted());
              }));
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
      appBar: primaryAppBar(context, "en_route_to_job", key),
      extendBodyBehindAppBar: true,
      body: Container(
        height: size.height,
        width: size.width,
        child: Column(
          children: [
            Container(
              height: size.height * 0.75,
              //margin: EdgeInsets.only(top: size.height * 0.09),
              child: Stack(
                children: [
                  Stack(
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
                        onTap: (position) {
                          _customInfoWindowController.hideInfoWindow();
                        },
                        onCameraMove: (position) {
                          _customInfoWindowController.onCameraMove();
                        },
                      ),
                      CustomInfoWindow(
                        controller: _customInfoWindowController,
                        height: size.height * 0.15,
                        width: size.width * 0.8,
                        offset: 100,
                      ),
                    ],
                  ),
                  /* Container(
                    color: Colors.white,
                    height: size.height * 0.07,
                    width: size.width,
                    margin: EdgeInsets.all(size.height * 0.03),
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${widget.jobDetail['consumer_name']}",
                            style: textTheme.headline6),
                        Icon(
                          Icons.message,
                          size: 35,
                          color: themeColor.primaryColor,
                        )
                      ],
                    ),
                  ), */
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
                            size: 34,
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
                              color: themeColor.accentColor.withOpacity(0.8)),
                        ))),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: size.width * 0.4,
                          height: size.height * 0.06,
                          child: RaisedButton(
                            child: Text(
                              getTranslated(context, "check_in"),
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () {
                              requestCheckIn();
                              /*Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WorkInProgress()));*/
                            },
                          ),
                        ),
                        Container(
                          width: size.width * 0.4,
                          height: size.height * 0.06,
                          child: RaisedButton(
                            color: themeColor.accentColor,
                            child: Text(
                              'Chat',
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                            consumerId: widget.consumerId,
                                            consumerName: widget.consumerName,
                                            professionalId:
                                                widget.professionalId,
                                            professionalName:
                                                widget.professionalName,
                                            consumerAvatar:
                                                widget.consumerAvatar,
                                            professionalAvatar:
                                                widget.professionalAvatar,
                                            type: "seller",
                                          )));
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
