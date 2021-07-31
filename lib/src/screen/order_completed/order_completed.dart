import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/payment_service/payment_service.dart';
import 'package:home_services/src/screen/service_menu/service_menu.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';

class OrderCompleted extends StatefulWidget {
  final jobId, consumerId, fromJobs;

  OrderCompleted({this.jobId, this.consumerId, this.fromJobs});

  @override
  State<StatefulWidget> createState() {
    return OrderCompletedState();
  }
}

class OrderCompletedState extends State<OrderCompleted> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  GlobalKey<FormState> orderCompleteForm = GlobalKey();
  GlobalKey<FormState> tipFormKey = GlobalKey();
  TextEditingController commentController = TextEditingController();
  TextEditingController professionalCommentController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  double rating = 0.0,
      punctualityRate = 0.0,
      professionalismRate = 0.0,
      serviceRate = 0.0,
      timingRate = 0.0,
      satisfactionRate = 0.0;
  var jobDetail;
  bool isLoading = false, fromJobs = false;

  @override
  void initState() {
    super.initState();
    fromJobs = widget.fromJobs;
    getJobDetail();
  }

  getJobDetail() {
    setState(() {
      isLoading = true;
    });
    UserApiProvider.jobDetailForConsumer(widget.jobId).then((value) {
      setState(() {
        isLoading = false;
      });
      if (value['result']) {
        if (widget.fromJobs) {
          professionalCommentController.text =
              value['job_details']['rating'] != null
                  ? value['job_details']['rating']['comment']
                  : "";
        }
        setState(() {
          jobDetail = value['job_details'];
        });
      }
    });
  }

  postComment() {
    setState(() {
      isLoading = true;
    });
    double averageRating = (punctualityRate +
            professionalismRate +
            serviceRate +
            timingRate +
            satisfactionRate) /
        5;
    UserApiProvider.reviewToProfessional(
            widget.jobId,
            jobDetail['professional_id'],
            commentController.text.toString(),
            averageRating,
            punctualityRate,
            professionalismRate,
            serviceRate,
            timingRate,
            satisfactionRate)
        .then((value) {
      setState(() {
        isLoading = false;
      });
      if (value['result']) {
        showMessage(context, "Review submitted successfully!");
      }
    });
  }

  Dialog provideTipDialog() {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Form(
            key: tipFormKey,
            child: Container(
              height: size.height * 0.25,
              width: size.width * 0.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: size.width,
                    height: size.height * 0.05,
                    color: themeColor.primaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Tip",
                          textAlign: TextAlign.center,
                          style:
                              textTheme.headline6.copyWith(color: primary_font),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.04),
                            child: TextFormField(
                                controller: amountController,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      int.parse(value.trim()) <= 0) {
                                    return "Enter valid amount";
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: stepper_background,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    hintText: "Enter amount",
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.04))),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            child: RaisedButton(
                              child: Text(
                                "Send Tip",
                              ),
                              textColor: primary_font,
                              onPressed: () async {
                                if (tipFormKey.currentState.validate()) {
                                  var data = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => PaymentService(
                                              consumerId: widget.consumerId,
                                              jobId: widget.jobId,
                                              jobDetail: jobDetail,
                                              fromOrderComplete: true,
                                              amount: amountController.text
                                                  .trim())));
                                  if (data != null) {
                                    Navigator.of(context).pop();
                                    showMessage(
                                        context, "Tip Paid Successfully.");
                                  } else {
                                    Navigator.of(context).pop();
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
                Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    return Scaffold(
      key: key,
      drawer: BuyerDrawer(),
      appBar: primaryAppBar(context, "order_completed", key),
      extendBodyBehindAppBar: isLoading,
      body: isLoading
          ? loadingData(context)
          : SingleChildScrollView(
              child: !fromJobs
                  ? Form(
                      key: orderCompleteForm,
                      child: Container(
                        width: size.width,
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.04),
                        child: Column(
                          children: [
                            Container(
                              width: size.width,
                              decoration: BoxDecoration(
                                  color: secondary_color,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10.0),
                                      topLeft: Radius.circular(10.0))),
                              margin: EdgeInsets.only(top: size.height * 0.03),
                              padding: EdgeInsets.all(size.height * 0.02),
                              child: Text(
                                'Thanks for choosing ${jobDetail['professional_name']}',
                                style: textTheme.subtitle2
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: size.height * 0.002),
                              decoration: BoxDecoration(
                                  color: secondary_color,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0))),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.01,
                                        horizontal: size.height * 0.02),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(
                                                    right: size.width * 0.03),
                                                child: Text(
                                                  "Order Id",
                                                  style: textTheme.subtitle2
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.w700),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          "#OO-${jobDetail['work_date']}-${jobDetail['id']}",
                                          style: textTheme.subtitle2,
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.height * 0.01,
                                              horizontal: size.height * 0.02),
                                          child: Text(
                                            getTranslated(
                                                context, "service_date"),
                                            style: textTheme.subtitle2.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                            width: size.width * 0.6,
                                            height: size.height * 0.048,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        "assets/icons/white-bg-corner-shape-2.png"),
                                                    fit: BoxFit.fill)),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: size.height * 0.01,
                                                  horizontal:
                                                      size.height * 0.02),
                                              child: Container(
                                                alignment: Alignment.topRight,
                                                child: Text(
                                                  "${jobDetail['work_date']}",
                                                  style: textTheme.subtitle2,
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.01),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Punctuality",
                                    style: textTheme.subtitle2
                                        .copyWith(fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.left,
                                  ),
                                  GFRating(
                                    color: themeColor.accentColor,
                                    size: 26.0,
                                    value: punctualityRate,
                                    onChanged: (value) {
                                      setState(() {
                                        punctualityRate = value;
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.01),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Professionalism",
                                    style: textTheme.subtitle2
                                        .copyWith(fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.left,
                                  ),
                                  GFRating(
                                    color: themeColor.accentColor,
                                    size: 26.0,
                                    value: professionalismRate,
                                    onChanged: (value) {
                                      setState(() {
                                        professionalismRate = value;
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.01),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Customer service",
                                    style: textTheme.subtitle2
                                        .copyWith(fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.left,
                                  ),
                                  GFRating(
                                    color: themeColor.accentColor,
                                    size: 26.0,
                                    value: serviceRate,
                                    onChanged: (value) {
                                      setState(() {
                                        serviceRate = value;
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.01),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Completion time",
                                    style: textTheme.subtitle2
                                        .copyWith(fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.left,
                                  ),
                                  GFRating(
                                    color: themeColor.accentColor,
                                    size: 26.0,
                                    value: timingRate,
                                    onChanged: (value) {
                                      setState(() {
                                        timingRate = value;
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.01),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Satisfaction",
                                    style: textTheme.subtitle2
                                        .copyWith(fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.left,
                                  ),
                                  GFRating(
                                    color: themeColor.accentColor,
                                    size: 26.0,
                                    value: satisfactionRate,
                                    onChanged: (value) {
                                      setState(() {
                                        satisfactionRate = value;
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: size.height * 0.006),
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.01),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Enter comment";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    hintText: getTranslated(
                                        context, "write_comment_here"),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3.0)))),
                                controller: commentController,
                                minLines: 6,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                              ),
                            ),
                            Container(
                              width: size.width * 0.9,
                              height: size.height * 0.06,
                              margin: EdgeInsets.only(
                                  bottom: size.height * 0.01,
                                  top: size.height * 0.02),
                              child: RaisedButton(
                                textColor: primary_font,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.005),
                                child: Text(
                                  getTranslated(context, "post_comment"),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () {
                                  if (orderCompleteForm.currentState
                                      .validate()) {
                                    postComment();
                                  }
                                },
                              ),
                            ),
                            Container(
                              width: size.width * 0.9,
                              height: size.height * 0.06,
                              margin: EdgeInsets.symmetric(
                                  vertical: size.height * 0.01),
                              child: RaisedButton(
                                textColor: primary_font,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.005),
                                child: Text(
                                  "Tip",
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () async {
                                  await showDialog(
                                      context: context,
                                      builder: (_) => provideTipDialog());
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: size.height * 0.01),
                              width: size.width * 0.9,
                              height: size.height * 0.06,
                              child: RaisedButton(
                                color: button_secondary,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.005),
                                child: Text(
                                  getTranslated(context, "no_thanks"),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ServiceMenu()),
                                      (Route<dynamic> route) => false);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : Form(
                      key: orderCompleteForm,
                      child: Container(
                        width: size.width,
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.04),
                        child: Column(
                          children: [
                            Container(
                              width: size.width,
                              decoration: BoxDecoration(
                                  color: secondary_color,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10.0),
                                      topLeft: Radius.circular(10.0))),
                              margin: EdgeInsets.only(top: size.height * 0.03),
                              padding: EdgeInsets.all(size.height * 0.02),
                              child: Text(
                                'Thanks for choosing ${jobDetail['professional_name']}',
                                style: textTheme.subtitle2
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: size.height * 0.002),
                              decoration: BoxDecoration(
                                  color: secondary_color,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0))),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.01,
                                        horizontal: size.height * 0.02),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(
                                                    right: size.width * 0.03),
                                                child: Text(
                                                  "Order Id",
                                                  style: textTheme.subtitle2
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.w700),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          "#OO-${jobDetail['work_date']}-${jobDetail['id']}",
                                          style: textTheme.subtitle2,
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.01,
                                        horizontal: size.height * 0.02),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          getTranslated(
                                              context, "service_date"),
                                          style: textTheme.subtitle2.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "${jobDetail['work_date']}",
                                          style: textTheme.subtitle2,
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.height * 0.01,
                                              horizontal: size.height * 0.02),
                                          child: Text(
                                            "Ratings",
                                            style: textTheme.subtitle2.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                            width: size.width * 0.6,
                                            height: size.height * 0.048,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        "assets/icons/white-bg-corner-shape-2.png"),
                                                    fit: BoxFit.fill)),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: size.height * 0.01,
                                                  horizontal:
                                                      size.height * 0.02),
                                              child: Container(
                                                alignment: Alignment.topRight,
                                                child: GFRating(
                                                  value: jobDetail['rating'] !=
                                                          null
                                                      ? jobDetail['rating']
                                                                  ['rating'] !=
                                                              null
                                                          ? double.parse(
                                                              jobDetail['rating']
                                                                      ['rating']
                                                                  .toString())
                                                          : 0.0
                                                      : 0.0,
                                                  size: 20.0,
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: size.width,
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.02),
                              child: Text(
                                "Comment",
                                style: textTheme.subtitle2
                                    .copyWith(fontWeight: FontWeight.w700),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: size.height * 0.002),
                              //padding: EdgeInsets.all(size.height * 0.01),
                              child: TextField(
                                decoration: InputDecoration(
                                    hintText:
                                        "No review given by professional.",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3.0)))),
                                controller: professionalCommentController,
                                minLines: 6,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                readOnly: true,
                              ),
                            ),
                            Container(
                              width: size.width * 0.9,
                              height: size.height * 0.06,
                              margin: EdgeInsets.symmetric(
                                  vertical: size.height * 0.02),
                              child: RaisedButton(
                                textColor: primary_font,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.005),
                                child: Text(
                                  "Tip",
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () async {
                                  await showDialog(
                                      context: context,
                                      builder: (_) => provideTipDialog());
                                },
                              ),
                            ),
                            jobDetail['consumer_rating'] == null
                                ? Column(
                                    children: [
                                      Container(
                                        width: size.width,
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.02),
                                        child: Text(
                                          "Give Review To Professional:",
                                          style: textTheme.subtitle1.copyWith(
                                              fontWeight: FontWeight.w700),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.01),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Punctuality",
                                              style: textTheme.subtitle2
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700),
                                              textAlign: TextAlign.left,
                                            ),
                                            GFRating(
                                              color: themeColor.accentColor,
                                              size: 26.0,
                                              value: punctualityRate,
                                              onChanged: (value) {
                                                setState(() {
                                                  punctualityRate = value;
                                                });
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.01),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Professionalism",
                                              style: textTheme.subtitle2
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700),
                                              textAlign: TextAlign.left,
                                            ),
                                            GFRating(
                                              color: themeColor.accentColor,
                                              size: 26.0,
                                              value: professionalismRate,
                                              onChanged: (value) {
                                                setState(() {
                                                  professionalismRate = value;
                                                });
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.01),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Customer service",
                                              style: textTheme.subtitle2
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700),
                                              textAlign: TextAlign.left,
                                            ),
                                            GFRating(
                                              color: themeColor.accentColor,
                                              size: 26.0,
                                              value: serviceRate,
                                              onChanged: (value) {
                                                setState(() {
                                                  serviceRate = value;
                                                });
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.01),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Completion time",
                                              style: textTheme.subtitle2
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700),
                                              textAlign: TextAlign.left,
                                            ),
                                            GFRating(
                                              color: themeColor.accentColor,
                                              size: 26.0,
                                              value: timingRate,
                                              onChanged: (value) {
                                                setState(() {
                                                  timingRate = value;
                                                });
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.01),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Satisfaction",
                                              style: textTheme.subtitle2
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700),
                                              textAlign: TextAlign.left,
                                            ),
                                            GFRating(
                                              color: themeColor.accentColor,
                                              size: 26.0,
                                              value: satisfactionRate,
                                              onChanged: (value) {
                                                setState(() {
                                                  satisfactionRate = value;
                                                });
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: size.height * 0.01),
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Enter comment";
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              hintText: getTranslated(context,
                                                  "write_comment_here"),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              3.0)))),
                                          controller: commentController,
                                          minLines: 6,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                        ),
                                      ),
                                      Container(
                                        width: size.width * 0.9,
                                        height: size.height * 0.06,
                                        margin: EdgeInsets.symmetric(
                                            vertical: size.height * 0.02),
                                        child: RaisedButton(
                                          textColor: primary_font,
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.height * 0.005),
                                          child: Text(
                                            getTranslated(
                                                context, "post_comment"),
                                            textAlign: TextAlign.center,
                                          ),
                                          onPressed: () {
                                            if (orderCompleteForm.currentState
                                                .validate()) {
                                              postComment();
                                            }
                                          },
                                        ),
                                      )
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
            ),
    );
  }
}
