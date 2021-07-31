import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/app.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/create_password/create_password.dart';
import 'package:home_services/src/screen/service_menu/service_menu.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/app_prefrences.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/common.dart';

class OtpVerification extends StatefulWidget {
  final email, phone, fromVerification, socialId;

  OtpVerification(
      {this.email, this.phone, this.fromVerification, this.socialId});

  @override
  State<StatefulWidget> createState() {
    return OtpVerificationState();
  }
}

class OtpVerificationState extends State<OtpVerification> {
  bool isLoading = false;
  TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  loginAndSetTheme(value) {
    setUserToken(value["token"]["access_token"]);
    setUser(json.encode(value["user"]));
    setAppTheme(value["user"]["role_id"] == 4 ? "seller" : "buyer");
    setWalletBalance(value["user"]["role_id"] == 4 ? value['balance'] : "0.00");
    HomeServices.setAppTheme(
        context, value["user"]["role_id"] == 4 ? "seller" : "buyer");
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ServiceMenu()),
        (Route<dynamic> route) => false);
  }

  submitOtp() async {
    getDeviceToken().then((token) {
      if (_formKey.currentState.validate()) {
        setState(() {
          isLoading = true;
        });
        if (widget.fromVerification) {
          UserApiProvider.verifySocialOtp(otpController.text.trim(),
                  widget.email, widget.phone, widget.socialId, token)
              .then((value) {
            setState(() {
              isLoading = false;
            });
            if (value['result']) {
              loginAndSetTheme(value);
            } else {
              showAlertDialog(context, value["message"]);
            }
          });
        } else {
          UserApiProvider.verifyOtp(
                  otpController.text.trim(), widget.email, widget.phone)
              .then((value) {
            setState(() {
              isLoading = false;
            });
            if (value["result"]) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => CreatePassword(
                          email: widget.email,
                        )),
              );
            } else {
              showAlertDialog(context, value["message"]);
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: isLoading
          ? loadingData(context)
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Container(
                  height: size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        height: size.height * 0.75,
                        padding: EdgeInsets.only(
                            top: size.height * 0.08,
                            left: size.width * 0.06,
                            right: size.width * 0.06,
                            bottom: size.height * 0.04),
                        width: size.width,
                        child: Column(
                          children: [
                            Container(
                              height: size.height * 0.25,
                              width: size.width * 0.5,
                              child:
                                  Image.asset("assets/icons/auth-banner.png"),
                            ),
                            Container(
                              width: size.width * 0.7,
                              margin: EdgeInsets.only(top: size.height * 0.01),
                              child: Text(
                                getTranslated(context, "one_time_verification"),
                                style: textTheme.headline5,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: size.width * 0.7,
                              margin: EdgeInsets.only(top: size.height * 0.015),
                              child: Text(
                                getTranslated(context, "enter_code_received"),
                                style: textTheme.subtitle1,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: size.width * 0.9,
                              margin: EdgeInsets.only(top: size.height * 0.015),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Enter valid otp";
                                  }
                                  return null;
                                },
                                controller: otpController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: text_field_background_color,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    hintText: "Enter OTP",
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.04)),
                              ),
                            ),
                            Container(
                              width: size.width * 0.9,
                              height: size.height * 0.06,
                              margin: EdgeInsets.only(top: size.height * 0.015),
                              child: RaisedButton(
                                onPressed: () {
                                  submitOtp();
                                },
                                child: Text(
                                  getTranslated(context, 'submit'),
                                  style: textTheme.subtitle1
                                      .copyWith(color: primary_font),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: size.height * 0.25,
                        width: size.width,
                        child: Image.asset(
                          "assets/icons/otp_background.jpg",
                          fit: BoxFit.cover,
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
