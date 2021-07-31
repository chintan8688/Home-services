import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/track_worker/track_worker.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';

class OrderSummary extends StatefulWidget {
  final jobId, consumerId;

  OrderSummary({this.jobId, this.consumerId});

  @override
  State<StatefulWidget> createState() {
    return OrderSummaryState();
  }
}

class OrderSummaryState extends State<OrderSummary> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  var jobDetail;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
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
        setState(() {
          jobDetail = value['job_details'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    return Scaffold(
      key: key,
      drawer: BuyerDrawer(),
      appBar: primaryAppBar(context, "order_summary", key),
      extendBodyBehindAppBar: isLoading,
      body: isLoading
          ? loadingData(context)
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        });
                                      }
                                    },*/
                                          child: Container(
                                            height: 20,
                                            width: 20,
                                            decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(100))),
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
                                      });
                                    },*/
                                          child: Container(
                                            height: 20,
                                            width: 20,
                                            decoration: BoxDecoration(
                                                color: button_secondary,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(100))),
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
                                  double.parse(jobDetail['package_price']
                                              .toString())
                                          .toString() +
                                      " JMD",
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                            style: textTheme.subtitle2.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            " : " +
                                                double.parse(jobDetail[
                                                            'package_price']
                                                        .toString())
                                                    .toString() +
                                                " JMD",
                                            textAlign: TextAlign.end,
                                            style: textTheme.subtitle2,
                                          ),
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: size.height * 0.03),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: "Buyer",
                              style: textTheme.headline6
                                  .copyWith(color: themeColor.primaryColor)),
                          TextSpan(
                              text: " Information", style: textTheme.headline6)
                        ]),
                      ),
                    ),
                    Divider(
                      thickness: 1.0,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.009),
                      width: size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(top: size.width * 0.009),
                              child: Text(
                                jobDetail['consumer_name'],
                                style: textTheme.subtitle1
                                    .copyWith(fontWeight: FontWeight.bold),
                              )),
                          Padding(
                              padding: EdgeInsets.only(top: size.width * 0.02),
                              child:
                                  Text("Address:", style: textTheme.subtitle1)),
                          Padding(
                              padding: EdgeInsets.only(top: size.width * 0.009),
                              child: Text(
                                jobDetail['address'],
                                style: textTheme.caption.copyWith(
                                    color: grey_color,
                                    fontWeight: FontWeight.w700),
                              )),
                          Padding(
                              padding: EdgeInsets.only(top: size.width * 0.02),
                              child:
                                  Text("Mobile:", style: textTheme.subtitle1)),
                          Padding(
                              padding: EdgeInsets.only(top: size.width * 0.009),
                              child: Text(
                                jobDetail['consumer_phone_code'] == null
                                    ? jobDetail['consumer_phone']
                                    : jobDetail['consumer_phone_code'] +
                                        " " +
                                        jobDetail['consumer_phone'],
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(
                                        color: grey_color,
                                        fontWeight: FontWeight.w700),
                              ))
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: size.height * 0.03),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: "Seller",
                              style: textTheme.headline6
                                  .copyWith(color: themeColor.primaryColor)),
                          TextSpan(
                              text: " Information", style: textTheme.headline6)
                        ]),
                      ),
                    ),
                    Divider(
                      thickness: 1.0,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.009),
                      width: size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(top: size.width * 0.009),
                              child: Row(
                                children: [
                                  Text(
                                    jobDetail['professional_name'],
                                    style: textTheme.subtitle1
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10),
                                    decoration: BoxDecoration(
                                        color: themeColor.primaryColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      child: Text(
                                        "JMD" +
                                            jobDetail['package_price']
                                                .toString() +
                                            " ${jobDetail['package_name']}",
                                        style: textTheme.caption
                                            .copyWith(color: primary_font),
                                      ),
                                    ),
                                  )
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(top: size.width * 0.02),
                              child:
                                  Text("Address:", style: textTheme.subtitle1)),
                          Padding(
                              padding: EdgeInsets.only(top: size.width * 0.009),
                              child: Text(
                                jobDetail['professional_address'],
                                style: textTheme.caption.copyWith(
                                    color: grey_color,
                                    fontWeight: FontWeight.w700),
                              )),
                          Padding(
                              padding: EdgeInsets.only(top: size.width * 0.02),
                              child:
                                  Text("Mobile:", style: textTheme.subtitle1)),
                          Padding(
                              padding: EdgeInsets.only(top: size.width * 0.009),
                              child: Text(
                                jobDetail['professional_phone_code'] +
                                    " " +
                                    jobDetail['professional_phone'],
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(
                                        color: grey_color,
                                        fontWeight: FontWeight.w700),
                              ))
                        ],
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(vertical: size.height * 0.02),
                      width: size.width * 0.9,
                      height: size.height * 0.06,
                      child: RaisedButton(
                        textColor: primary_font,
                        padding:
                            EdgeInsets.symmetric(vertical: size.height * 0.005),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 22,
                              width: 22,
                              child: Image.asset("assets/icons/icon-clock.png"),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              child: Text(
                                "Track " + jobDetail['professional_name'],
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TrackWorker(
                                        jobId: widget.jobId,
                                        consumerId: widget.consumerId,
                                        jobDetail: jobDetail,
                                      )));
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
