import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/en_route_job/en_route_job.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:home_services/src/widget/seller_drawer.dart';

class OrderSummarySeller extends StatefulWidget {
  final jobId, consumerId;

  OrderSummarySeller({@required this.jobId, @required this.consumerId});

  @override
  State<StatefulWidget> createState() {
    return OrderSummarySellerState();
  }
}

class OrderSummarySellerState extends State<OrderSummarySeller> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  int quantity = 1;
  var jobDetail;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getJobDetails();
  }

  getJobDetails() {
    setState(() {
      isLoading = true;
    });
    UserApiProvider.jobDetailForProfessional(widget.jobId).then((value) {
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
      drawer: SellerDrawer(),
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
                      margin: EdgeInsets.only(top: size.height * 0.03),
                      alignment: Alignment.center,
                      child: Text(
                        "Thanks for choosing clickaway services",
                        style: textTheme.subtitle1
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: size.height * 0.01),
                      child: Divider(),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Order: OO-${jobDetail['work_date']}-${jobDetail['id']}",
                        style: textTheme.subtitle1.copyWith(
                            fontWeight: FontWeight.w700,
                            color: themeColor.primaryColor),
                      ),
                    ),
                    Column(
                      children: [
                        Divider(),
                        Container(
                          height: size.height * 0.1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.009),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Service Date",
                                      style: textTheme.subtitle1,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.005),
                                      child: Text(
                                        jobDetail['type'] == "direct"
                                            ? "Request Service Now"
                                            : "Schedule",
                                        style: textTheme.subtitle1.copyWith(
                                            color: themeColor.primaryColor,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              VerticalDivider(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.009),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Order Status",
                                          textAlign: TextAlign.end,
                                          style: textTheme.subtitle1,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.height * 0.005),
                                          child: Text(
                                            "Paid",
                                            textAlign: TextAlign.end,
                                            style: textTheme.subtitle1.copyWith(
                                                color: themeColor.primaryColor,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider()
                      ],
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
                            getTranslated(context, "payment_information"),
                            style: textTheme.subtitle2
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                                color: themeColor.primaryColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0))),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              child: Text(
                                "Paypal",
                                style: textTheme.caption
                                    .copyWith(color: primary_font),
                              ),
                            ),
                          )
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
                                  padding:
                                      EdgeInsets.only(right: size.width * 0.03),
                                  child: Text(
                                    getTranslated(context, "subtotal"),
                                    style: textTheme.subtitle2
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Text(
                                  double.parse(jobDetail['package_price']
                                              .toString())
                                          .toString() +
                                      " " +
                                      "JMD",
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
                                  getTranslated(context, "extra_time_charge"),
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
                                            "Total Earning",
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
                                                " " +
                                                "JMD",
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
                                            " " +
                                            jobDetail['package_name'],
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
                        child: Container(
                          margin: EdgeInsets.only(left: 8),
                          child: Text(
                            "En Route To Job",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EnRouteJob(
                                        consumerId: widget.consumerId,
                                        jobId: widget.jobId,
                                        jobDetail: jobDetail,
                                        professionalName:
                                            jobDetail['professional_name'],
                                        consumerName:
                                            jobDetail['consumer_name'],
                                        professionalId:
                                            jobDetail['professional_id'],
                                        consumerAvatar:
                                            jobDetail['consumer_avatar'],
                                        professionalAvatar:
                                            jobDetail['professional_avatar'],
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
