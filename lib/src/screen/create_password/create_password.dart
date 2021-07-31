import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/app.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/service_menu/service_menu.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/app_prefrences.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/common.dart';

class CreatePassword extends StatefulWidget {
  final email;

  CreatePassword({this.email});

  @override
  State<StatefulWidget> createState() {
    return CreatePasswordState();
  }
}

class CreatePasswordState extends State<CreatePassword> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _confirmPasswordController =
      new TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  verifyPassword() async {
    getDeviceToken().then((token) {
      if (_formKey.currentState.validate()) {
        setState(() {
          isLoading = true;
        });
        UserApiProvider.createPassword(
                _passwordController.text, widget.email, token)
            .then((value) {
          setState(() {
            isLoading = false;
          });
          if (value["result"]) {
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
          } else {
            showAlertDialog(context, value["error"]);
          }
        });
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
                        children: [
                          Container(
                            width: size.width,
                            height: size.height * 0.75,
                            padding: EdgeInsets.only(
                                top: size.height * 0.08,
                                left: size.width * 0.06,
                                right: size.width * 0.06,
                                bottom: size.height * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  height: size.height * 0.25,
                                  width: size.width * 0.5,
                                  child: Image.asset(
                                      "assets/icons/auth-banner.png"),
                                ),
                                Container(
                                  width: size.width * 0.7,
                                  margin:
                                      EdgeInsets.only(top: size.height * 0.01),
                                  child: Text(
                                    "Create Password",
                                    style: textTheme.headline5,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(top: size.height * 0.02),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return getTranslated(
                                            context, "enter_valid_password");
                                      }
                                      return null;
                                    },
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: text_field_background_color,
                                        suffixIconConstraints: BoxConstraints(
                                            maxHeight: 24, maxWidth: 44),
                                        suffixIcon: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Image.asset(
                                            "assets/icons/icon-lock.png",
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        hintText:
                                            getTranslated(context, 'password'),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: size.width * 0.04)),
                                  ),
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(top: size.height * 0.02),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return getTranslated(
                                            context, "enter_valid_password");
                                      } else if (value !=
                                          _passwordController.text) {
                                        return getTranslated(
                                            context, "both_password_not_match");
                                      }
                                      return null;
                                    },
                                    controller: _confirmPasswordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: text_field_background_color,
                                        suffixIconConstraints: BoxConstraints(
                                            maxHeight: 24, maxWidth: 44),
                                        suffixIcon: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Image.asset(
                                            "assets/icons/icon-lock.png",
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        hintText: getTranslated(
                                            context, 'confirm_password'),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: size.width * 0.04)),
                                  ),
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(top: size.height * 0.02),
                                  width: size.width * 0.9,
                                  height: size.height * 0.06,
                                  child: RaisedButton(
                                    textColor: primary_font,
                                    onPressed: () {
                                      verifyPassword();
                                    },
                                    child: Text("Submit"),
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
                      )),
                ),
              ));
  }
}
