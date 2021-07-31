import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:home_services/main.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/request_summary/request_summary.dart';
import 'package:home_services/src/screen/service_menu/service_menu.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/app_prefrences.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:intl/intl.dart';
import 'package:timezone/standalone.dart' as tz;

class WorkerServiceDetail extends StatefulWidget {
  final professional,
      type,
      category,
      scheduledJob,
      jobId,
      fromFavourite,
      fromBids,
      services;

  WorkerServiceDetail(
      {Key key,
      @required this.professional,
      @required this.type,
      @required this.category,
      @required this.scheduledJob,
      @required this.jobId,
      @required this.fromFavourite,
      @required this.fromBids,
      this.services})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WorkerServiceDetailState();
  }
}

class WorkerServiceDetailState extends State<WorkerServiceDetail>
    with RouteAware {
  GlobalKey<ScaffoldState> key = GlobalKey();
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  ScrollController _scrollController;

  var titleOpacity = 0.0, professional, package, category;
  bool isLoading = false;
  StreamSubscription subscription;
  int categoryId;
  bool formError = false, fromFavourite = false;
  Timer timer;
  int consumerId;

  @override
  void initState() {
    super.initState();
    category = widget.category;
    professional = widget.professional;
    package = widget.professional['packages']
        .singleWhere((i) => i['name'] == widget.type);
    getUserId();
    _scrollController = ScrollController()
      ..addListener(() {
        if (!_isAppBarExpanded) {
          setState(() {
            titleOpacity = 0;
          });
        } else {
          setState(() {
            titleOpacity = 1;
          });
        }
      });
  }

  getUserId() async {
    getUser().then((value) {
      var data = json.decode(value);
      consumerId = data['id'];
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
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
    subscription?.cancel();
    timer?.cancel();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    subscription?.cancel();
    timer?.cancel();
  }

  checkIsRequestAccepted(consumerId, jobId) {
    subscription = FirebaseFirestore.instance
        .collection("jobs")
        .where('consumer_id', isEqualTo: consumerId)
        .where("job_id", isEqualTo: jobId)
        .snapshots()
        .listen((event) {
      var data = event.docs?.map((e) => e.data())?.toList() ?? [];
      try {
        if (data[0]["seller_accepted"] && data[0]["order_completed"] == false) {
          setState(() {
            isLoading = false;
          });
          timer?.cancel();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RequestSummary(
                        consumerId: consumerId,
                        jobId: jobId,
                      )));
          /*Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OrderSummary(
                        jobId: jobId,
                        consumerId: consumerId,
                      )));*/
        }
      } catch (e) {
        print(e);
      }
    });
  }

  professionalNotConnected() async {
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
            child: Text("Professional didn't connect at the moment."),
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

  requestForJob() {
    getLocationPermission().then((value) async {
      var jamaica = tz.getLocation('America/Jamaica');
      var jamaicaCurrentTime = tz.TZDateTime.now(jamaica);
      var latitude = value.latitude;
      var longitude = value.longitude;
      final coordinates = new Coordinates(latitude, longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var address = '${addresses.first.addressLine}';
      var date = jamaicaCurrentTime;
      var time = jamaicaCurrentTime;

      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      String ftime = DateFormat('HH:mm:ss').format(time);

      if (widget.fromBids) {
        setState(() {
          isLoading = true;
        });

        UserApiProvider.jobRequest(
                "",
                "",
                category['id'],
                double.parse(package['price'].toString()),
                latitude,
                longitude,
                address,
                formattedDate,
                ftime,
                professional['professional_id'],
                1,
                widget.scheduledJob ? 'schedule' : 'direct',
                widget.jobId,
                package['id'])
            .then((value) {
          if (value['result'] && value['already_requested'] != 1) {
            var notification = {
              "notification": {
                "title": "Job Request",
                "body": value['job']['title']
              },
              "priority": "high",
              "data": {
                "job_id": value['job']['id'],
                "screen": "home",
                "click_action": "FLUTTER_NOTIFICATION_CLICK"
              },
              "to": value['professional_device_token']
            };

            UserApiProvider.sendPushNotification(notification).then((result) {
              FirebaseFirestore firestore = FirebaseFirestore.instance;
              CollectionReference jobs = firestore.collection('jobs');
              CollectionReference jobsTracking =
                  firestore.collection('jobs_tracking');
              jobsTracking.add({
                "job_id": value['job']['id'],
                "consumer_id": value['job']['consumer_id'],
                "consumer_latitude": value['job']['latitude'],
                "consumer_longitude": value['job']['longitude'],
                "professional_id": professional['professional_id'],
              });
              jobs.add({
                "job_id": value['job']['id'],
                "consumer_id": value['job']['consumer_id'],
                "consumer_latitude": value['job']['latitude'],
                "consumer_longitude": value['job']['longitude'],
                "professional_id": professional['professional_id'],
                "check_in_request": false,
                "buyer_accepted": false,
                "order_completed": false,
                "seller_accepted": false,
                "seller_rejected": false,
                "payment_done": false
              }).then((res) {
                checkIsRequestAccepted(
                    value['job']['consumer_id'], value['job']['id']);
                timer = Timer(Duration(minutes: 5), () {
                  professionalNotConnected();
                });
              });
            });
          } else {
            setState(() {
              isLoading = false;
            });
            showMessage(
                context, "You have already requested to this professional.");
          }
        });
      } else {
        var data = await showDialog(
            context: context, builder: (_) => jobDetailDialog());

        if (data != null) {
          setState(() {
            isLoading = true;
          });

          UserApiProvider.jobRequest(
                  data['title'],
                  data['description'],
                  widget.fromFavourite ? data['id'] : category['id'],
                  double.parse(package['price'].toString()),
                  latitude,
                  longitude,
                  address,
                  formattedDate,
                  ftime,
                  widget.fromFavourite
                      ? professional['professional_id']
                      : professional['id'],
                  1,
                  widget.scheduledJob ? 'schedule' : 'direct',
                  widget.jobId,
                  package['id'])
              .then((value) {
            if (value['result'] && value['already_requested'] != 1) {
              var notification = {
                "notification": {
                  "title": "Job Request",
                  "body": value['job']['title']
                },
                "priority": "high",
                "data": {
                  "job_id": value['job']['id'],
                  "screen": "home",
                  "click_action": "FLUTTER_NOTIFICATION_CLICK"
                },
                "to": value['professional_device_token']
              };

              UserApiProvider.sendPushNotification(notification).then((result) {
                FirebaseFirestore firestore = FirebaseFirestore.instance;
                CollectionReference jobs = firestore.collection('jobs');
                CollectionReference jobsTracking =
                    firestore.collection('jobs_tracking');
                jobsTracking.add({
                  "job_id": value['job']['id'],
                  "consumer_id": value['job']['consumer_id'],
                  "consumer_latitude": value['job']['latitude'],
                  "consumer_longitude": value['job']['longitude'],
                  "professional_id": widget.fromFavourite
                      ? professional['professional_id']
                      : professional['id'],
                });
                jobs.add({
                  "job_id": value['job']['id'],
                  "consumer_id": value['job']['consumer_id'],
                  "consumer_latitude": value['job']['latitude'],
                  "consumer_longitude": value['job']['longitude'],
                  "professional_id": widget.fromFavourite
                      ? professional['professional_id']
                      : professional['id'],
                  "check_in_request": false,
                  "buyer_accepted": false,
                  "order_completed": false,
                  "seller_accepted": false,
                  "seller_rejected": false,
                  "payment_done": false
                }).then((res) {
                  checkIsRequestAccepted(
                      value['job']['consumer_id'], value['job']['id']);
                  timer = Timer(Duration(minutes: 5), () {
                    professionalNotConnected();
                  });
                });
              });
            } else {
              setState(() {
                isLoading = false;
              });
              showMessage(
                  context, "You have already requested to this professional.");
            }
          });
        }
      }
    });
  }

  Dialog jobDetailDialog() {
    var size = MediaQuery.of(context).size;

    var textTheme = Theme.of(context).textTheme;
    return Dialog(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Form(
            key: formKey,
            child: Container(
              height: size.height * 0.4,
              width: size.width * 0.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.04),
                            child: TextFormField(
                                controller: titleController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Enter Job title";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    hintText: "Enter Job Title",
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.04))),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.04),
                            child: TextFormField(
                                controller: descriptionController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Enter Job Description";
                                  }
                                  return null;
                                },
                                maxLines: 3,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    hintText: "Enter Job Description",
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.04,
                                        vertical: size.height * 0.02))),
                          ),
                          widget.fromFavourite
                              ? Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * 0.04),
                                      child: Container(
                                        height: size.height * 0.06,
                                        margin: EdgeInsets.only(
                                            top: size.height * 0.02),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.width * 0.04),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                              color: formError
                                                  ? error_color
                                                  : grey_color),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton(
                                            isDense: true,
                                            isExpanded: true,
                                            hint: Text("Select Category"),
                                            value: categoryId,
                                            items: (widget.services as List)
                                                .map(
                                                    (value) => DropdownMenuItem(
                                                          child: Text(
                                                              value['category']
                                                                  ['name']),
                                                          value:
                                                              value['category']
                                                                  ['id'],
                                                        ))
                                                .toList(),
                                            onChanged: (newValue) {
                                              setState(() {
                                                categoryId = newValue;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                        visible: formError,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.height * 0.008,
                                              horizontal: size.width * 0.08),
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "Select Category",
                                            style: textTheme.caption
                                                .copyWith(color: error_color),
                                          ),
                                        )),
                                  ],
                                )
                              : Container(),
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            child: RaisedButton(
                              child: Text(
                                "Confirm Request",
                              ),
                              textColor: primary_font,
                              onPressed: () {
                                if (formKey.currentState.validate()) {
                                  if (widget.fromFavourite) {
                                    if (categoryId == null) {
                                      setState(() {
                                        formError = true;
                                      });
                                    } else {
                                      var jobData = {
                                        "title": titleController.text,
                                        "description":
                                            descriptionController.text,
                                        "id": categoryId
                                      };
                                      Navigator.pop(context, jobData);
                                    }
                                  } else {
                                    var jobData = {
                                      "title": titleController.text,
                                      "description": descriptionController.text,
                                    };
                                    Navigator.pop(context, jobData);
                                  }
                                } else {
                                  if (categoryId == null) {
                                    setState(() {
                                      formError = true;
                                    });
                                  }
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> showMessage(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message'),
          content: Container(
            child: Text(message),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool get _isAppBarExpanded {
    return _scrollController.hasClients &&
        _scrollController.offset > (200 - kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    var kef = size.height > 690 ? 2 : 1.6;

    return Scaffold(
      key: key,
      drawer: BuyerDrawer(),
      body: isLoading
          ? Container(
              width: size.width,
              height: size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: size.width * 0.8,
                    padding:
                        EdgeInsets.symmetric(vertical: size.height * 0.008),
                    child: Text(
                      "Please wait while connecting" +
                          " " +
                          professional['name'],
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
          : NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30))),
                    expandedHeight: (size.height / kef) - 200,
                    floating: false,
                    pinned: true,
                    snap: false,
                    leading: IconButton(
                      icon: Image.asset(
                        "assets/icons/icon-drawer.png",
                        height: 24,
                        width: 24,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        collapseMode: CollapseMode.parallax,
                        title: Opacity(
                          opacity: titleOpacity,
                          child: Opacity(
                            opacity: titleOpacity,
                            child: Text(
                              professional['name'],
                              style: textTheme.headline6.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primary_font),
                            ),
                          ),
                        ),
                        background: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: CachedNetworkImage(
                                imageUrl: Constant.STORAGE_PATH +
                                    professional['avatar'],
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                                bottom: -1,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          topRight: Radius.circular(30))),
                                ))
                          ],
                        )),
                  )
                ];
              },
              body: SingleChildScrollView(
                child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.06),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              professional['name'],
                              style: textTheme.headline6,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.01),
                            child: Text(professional['service_description']),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: size.height * 0.025),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Reviews",
                                      style: textTheme.subtitle1,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: size.height * 0.005),
                                      child: Row(
                                        children: [
                                          GFRating(
                                            value: professional['rating']
                                                        ['average_rating'] !=
                                                    null
                                                ? double.parse(
                                                    professional['rating']
                                                            ['average_rating']
                                                        .toString())
                                                : 0.0,
                                            size: 16.0,
                                            color: themeColor.primaryColor,
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: size.width * 0.01),
                                            child: Text(
                                              '(${professional['rating']['rating_count']})',
                                              style: textTheme.subtitle1
                                                  .copyWith(
                                                      color: themeColor
                                                          .primaryColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      getTranslated(context, "languages"),
                                      style: textTheme.subtitle1,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: size.height * 0.005),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: professional['languages']
                                            .map<Widget>(
                                              (e) => Text(
                                                e['language'] +
                                                    " " +
                                                    e['level'],
                                                style: textTheme.subtitle1
                                                    .copyWith(
                                                        color: themeColor
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.w700),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          Divider(
                            color: secondary_color,
                            thickness: 1,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.009),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: size.height * 0.01),
                                    child: RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: "JMD${package['price']}",
                                          style: textTheme.headline6.copyWith(
                                              color: themeColor.primaryColor)),
                                      TextSpan(
                                          text: ' ${package['name']}',
                                          style: textTheme.headline6),
                                    ])),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: size.height * 0.01),
                                    child: RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: ">",
                                          style: textTheme.subtitle1.copyWith(
                                              color: button_secondary,
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text: " Basic package up to 1 hour",
                                          style: textTheme.subtitle1),
                                    ])),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: size.height * 0.01),
                                    child: RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: ">",
                                          style: textTheme.subtitle1.copyWith(
                                              color: button_secondary,
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text:
                                              " Additional ${package['additional_price']} JMD/ 1 Hour",
                                          style: textTheme.subtitle1),
                                    ])),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.01),
                            child: Text(package['description']),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.width * 0.04),
                            child: Row(
                              children: [
                                Text(getTranslated(context, "service_date"),
                                    style: textTheme.subtitle1),
                                Text(" " + getTranslated(context, "now"),
                                    style: textTheme.subtitle1),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.width * 0.01),
                            child: Text(
                                getTranslated(context, "all_price_with_tax")),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: size.width * 0.05),
                            width: size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: size.width * 0.4,
                                  height: size.height * 0.06,
                                  child: RaisedButton(
                                    textColor: primary_font,
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.005),
                                    child: Text(
                                      getTranslated(context, "confirm"),
                                      textAlign: TextAlign.center,
                                    ),
                                    onPressed: () {
                                      requestForJob();
                                    },
                                  ),
                                ),
                                Container(
                                  width: size.width * 0.4,
                                  height: size.height * 0.06,
                                  child: OutlineButton(
                                    borderSide: BorderSide(color: Colors.black),
                                    textColor: Colors.black,
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.005),
                                    child: Text(
                                      getTranslated(context, "cancel"),
                                      textAlign: TextAlign.center,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                )
                              ],
                            ),
                          )
                        ])),
              ),
            ),
    );
  }
}
