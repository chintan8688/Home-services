import 'dart:convert';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:home_services/main.dart';
import 'package:home_services/src/screen/order_summary/order_summary.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:webview_flutter/webview_flutter.dart';

class PaymentService extends StatefulWidget {
  final jobId, consumerId, jobDetail, amount, fromOrderComplete;

  PaymentService(
      {this.jobId,
      this.consumerId,
      this.jobDetail,
      this.amount,
      this.fromOrderComplete});

  @override
  State<StatefulWidget> createState() {
    return PaymentServiceState();
  }
}

class PaymentServiceState extends State<PaymentService> {
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  String checkoutUrl,
      returnURL = "https://clickaway.fanstter.com/payment_success";

  bool isLoading = false;
  var jamaica;

  @override
  void initState() {
    super.initState();
    jamaica = tz.getLocation('America/Jamaica');
    getJwtToken();
  }

  getJwtToken() {
    var header = {
      "alg": "HS256",
      "typ": "JWT",
      "kid": "cf2232a8-361c-4874-afe6-d4c74e0b49dd"
    };
    var payload = {
      "amount": widget.fromOrderComplete
          ? widget.amount.toString()
          : widget.jobDetail['package_price'].toString(),
      "custom_reference": widget.fromOrderComplete
          ? "TIP_" + widget.jobId.toString()
          : "JOB_" + widget.jobId.toString(),
      "exp": (tz.TZDateTime.now(jamaica)
                  .add(Duration(days: 1))
                  .millisecondsSinceEpoch /
              1000)
          .round(),
      "nbf": (tz.TZDateTime.now(jamaica).millisecondsSinceEpoch / 1000).round()
    };

    String token = base64UrlEncode(utf8.encode(json.encode(header))) +
        "." +
        base64UrlEncode(utf8.encode(json.encode(payload)));

    var digest =
        Hmac(sha256, utf8.encode("WBCzs1D5W00kjB_rCKYDjqMbI7CBZxHLg2cCp3G1usU"))
            .convert(utf8.encode(token)); // HMAC-SHA256

    var jwtToken = (token + "." + base64UrlEncode(digest.bytes));

    setState(() {
      checkoutUrl =
          "https://www.fygaro.com/en/pb/4a55020c-1fde-4673-87ea-0cd25d8fc31a?jwt=" +
              jwtToken;
    });
  }

  paymentSuccess() {
    FirebaseFirestore.instance
        .collection("jobs")
        .where('job_id', isEqualTo: widget.jobId)
        .get()
        .then((value) => value.docs.forEach((element) {
              element.reference.update({"payment_done": true}).then((value) =>
                  navigatorKey.currentState.pushReplacement(MaterialPageRoute(
                      builder: (context) => OrderSummary(
                            jobId: widget.jobId,
                            consumerId: widget.consumerId,
                          ))));
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: primaryAppBar(context, "Payment", key),
      extendBodyBehindAppBar: checkoutUrl == null ? true : false,
      drawer: BuyerDrawer(),
      body: checkoutUrl == null
          ? loadingData(context)
          : WebView(
              initialUrl: checkoutUrl,
              javascriptMode: JavascriptMode.unrestricted,
              navigationDelegate: (NavigationRequest request) {
                if (request.url.contains(returnURL)) {
                  if (widget.fromOrderComplete) {
                    Navigator.of(context).pop({"tip_send": true});
                  } else {
                    paymentSuccess();
                  }
                }
                return NavigationDecision.navigate;
              },
            ),
    );
  }
}
