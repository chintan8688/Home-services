import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/payment_service/payment_service.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';

class RequestSummary extends StatefulWidget {
  final consumerId, jobId;

  RequestSummary({@required this.consumerId, this.jobId});

  @override
  State<StatefulWidget> createState() {
    return RequestSummaryState();
  }
}

class RequestSummaryState extends State<RequestSummary> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  ScrollController _scrollController;

  var jobDetail;
  bool isLoading = false;
  var titleOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    getJobDetail();
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

  bool get _isAppBarExpanded {
    return _scrollController.hasClients &&
        _scrollController.offset > (200 - kToolbarHeight);
  }

  getJobDetail() {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    UserApiProvider.jobDetailForConsumer(widget.jobId).then((value) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      if (value['result']) {
        if (mounted) {
          setState(() {
            jobDetail = value['job_details'];
          });
        }
      }
    });
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
          ? loadingData(context)
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
                          child: Text(
                            jobDetail['professional_name'],
                            style: textTheme.headline6.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primary_font),
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
                                    jobDetail['professional_avatar'],
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
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        //margin: EdgeInsets.only(top: size.height * 0.04),
                        child: Text(
                          jobDetail['professional_name'],
                          style: textTheme.headline6,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.01),
                        child: Text(jobDetail['professional_description']),
                      ),
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: size.height * 0.025),
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
                                  margin:
                                      EdgeInsets.only(top: size.height * 0.005),
                                  child: Row(
                                    children: [
                                      GFRating(
                                        value: jobDetail[
                                                        'professional_average_rating']
                                                    ['average_rating'] !=
                                                null
                                            ? double.parse(jobDetail[
                                                        'professional_average_rating']
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
                                          '(${jobDetail['professional_average_rating']['rating_count'] != null ? jobDetail['professional_average_rating']['rating_count'] : "0"})',
                                          style: textTheme.subtitle1.copyWith(
                                              color: themeColor.primaryColor),
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
                                  margin:
                                      EdgeInsets.only(top: size.height * 0.005),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: jobDetail['languages']
                                        .map<Widget>(
                                          (e) => Text(
                                            e['language'] + " " + e['level'],
                                            style: textTheme.subtitle1.copyWith(
                                                color: themeColor.primaryColor,
                                                fontWeight: FontWeight.w700),
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
                        padding:
                            EdgeInsets.symmetric(vertical: size.height * 0.009),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(top: size.height * 0.01),
                                child: RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                      text: "JMD${jobDetail['package_price']}",
                                      style: textTheme.headline6.copyWith(
                                          color: themeColor.primaryColor)),
                                  TextSpan(
                                      text: ' ${jobDetail['package_name']}',
                                      style: textTheme.headline6),
                                ])),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(top: size.height * 0.01),
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
                                padding:
                                    EdgeInsets.only(top: size.height * 0.01),
                                child: RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                      text: ">",
                                      style: textTheme.subtitle1.copyWith(
                                          color: button_secondary,
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text:
                                          " Additional ${jobDetail['additional_price']} JMD/ 1 Hour",
                                      style: textTheme.subtitle1),
                                ])),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.01),
                        child: Text(jobDetail['package_description']),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: secondary_color,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10.0),
                                topLeft: Radius.circular(10.0))),
                        margin: EdgeInsets.only(top: size.height * 0.03),
                        padding: EdgeInsets.all(size.height * 0.02),
                        child: Row(
                          children: [
                            Text(
                              getTranslated(context, "service_date"),
                              style: textTheme.subtitle2
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              " " + jobDetail['work_date'],
                              style: textTheme.subtitle2
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
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
                                            getTranslated(context, "quantity"),
                                            style: textTheme.subtitle2.copyWith(
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              right: size.width * 0.02),
                                          child: GestureDetector(
                                            /*onTap: () {
                                        if (quantity > 1) {
                                          setState(() {
                                            quantity--;
                                            totalAmount = double.parse(
                                                (quantity *
                                                        jobDetail[
                                                            'package_price'])
                                                    .toString());
                                          });
                                        }
                                      },*/
                                            child: Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              100))),
                                              child: Text(
                                                "-",
                                                style: textTheme.subtitle1,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '1',
                                          style: textTheme.subtitle2,
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: size.width * 0.02),
                                          child: GestureDetector(
                                            /*onTap: () {
                                        setState(() {
                                          quantity++;
                                          totalAmount = double.parse((quantity *
                                                  jobDetail['package_price'])
                                              .toString());
                                        });
                                      },*/
                                            child: Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                  color: button_secondary,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              100))),
                                              child: Text(
                                                "+",
                                                style: textTheme.subtitle1
                                                    .copyWith(
                                                        color: primary_font),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${double.parse(jobDetail['package_price'].toString())} JMD',
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
                                    getTranslated(context, "processing_fee"),
                                    style: textTheme.subtitle2.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "0.0 JMD",
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
                                    getTranslated(context, "vat_amount"),
                                    style: textTheme.subtitle2.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "0.0 JMD",
                                    style: textTheme.subtitle2,
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: size.width * 0.6,
                                    height: size.height * 0.045,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                "assets/icons/white-bg-corner-shape-2.png"),
                                            fit: BoxFit.fill)),
                                    child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.01,
                                            horizontal: size.height * 0.02),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              getTranslated(context, "total"),
                                              style:
                                                  textTheme.subtitle2.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              ' : ${double.parse(jobDetail['package_price'].toString())} JMD',
                                              textAlign: TextAlign.end,
                                              style: textTheme.subtitle2,
                                            ),
                                          ],
                                        )),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: size.height * 0.02, bottom: size.width * 0.02),
                        width: size.width * 0.9,
                        height: size.height * 0.06,
                        child: RaisedButton(
                          textColor: primary_font,
                          child: Text(
                            getTranslated(context, "proceed_to_payment"),
                            textAlign: TextAlign.center,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PaymentService(
                                          jobId: widget.jobId,
                                          consumerId: widget.consumerId,
                                          jobDetail: jobDetail,
                                          fromOrderComplete: false,
                                        )));
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
