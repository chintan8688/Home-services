import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:home_services/src/app.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/forgot_password/forgot_password.dart';
import 'package:home_services/src/screen/otp_verification/otp_verification.dart';
import 'package:home_services/src/screen/service_menu/service_menu.dart';
import 'package:home_services/src/screen/signup/signup.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/app_prefrences.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final formKeyDialog = GlobalKey<FormState>();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _dialogEmailController = TextEditingController();
  bool isLoading = false, dialogLoading = false;
  PhoneNumber number = PhoneNumber(isoCode: 'JM');
  var phoneCode;

  @override
  void initState() {
    super.initState();
  }

  facebookSignIn() async {
    final LoginResult result = await FacebookAuth.instance.login(
        loginBehavior: LoginBehavior.WEB_VIEW_ONLY, permissions: ['email']);
    final Dio dio = new Dio();
    switch (result.status) {
      case LoginStatus.success:
        final profile = await dio.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,picture,email&access_token=${result.accessToken.token}');
        String avatarUrl =
            'https://graph.facebook.com/${profile.data['id']}/picture?height=300&width=300';
        break;
      case LoginStatus.cancelled:
        break;
      case LoginStatus.failed:
        break;
      default:
        return null;
    }
  }

  googleSignIn() async {
    getDeviceToken().then((token) async {
      try {
        GoogleSignIn _googleSignIn = GoogleSignIn(
          scopes: <String>[
            'email',
          ],
        );
        await _googleSignIn
            .signIn()
            .then((value) => value.authentication.then((value) {}));

        String email = _googleSignIn.currentUser.email;
        String name = _googleSignIn.currentUser.displayName;
        String avatarUrl = _googleSignIn.currentUser.photoUrl;
        String socialId = _googleSignIn.currentUser.id.toString();

        UserApiProvider.signUpWithGoogle(
                name, email, avatarUrl, socialId, token, 3)
            .then((value) {
          if (value['result'] && value['is_verified']) {
            loginAndSetTheme(value);
          } else if (value['result'] && !value['is_verified']) {
            userVerificationDialog(email, socialId);
          } else {
            showAlertDialog(context, value["message"]);
          }
        });
      } catch (e) {
        print(e);
      }
    });
  }

  login() async {
    getDeviceToken().then((token) {
      if (_formKey.currentState.validate()) {
        setState(() {
          isLoading = true;
        });
        UserApiProvider.signIn(
                _emailController.text, _passwordController.text, token)
            .then((value) {
          setState(() {
            isLoading = false;
          });
          if (value["result"]) {
            loginAndSetTheme(value);
          } else if (value["result"] == false && value["is_verified"] == 1) {
            showAlertDialog(context, value["error"]);
          } else if (value["result"] == false && value["is_verified"] == 0) {
            UserApiProvider.sendOtp(
                    value["user"]["phone_code"] + value["user"]["phone"])
                .then((data) => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OtpVerification(
                              email: value["user"]["email"],
                              phone: value["user"]["phone_code"] +
                                  value["user"]["phone"],
                              fromVerification: false,
                            ))));
          }
        });
      }
    });
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

  userVerificationDialog(email, socialId) async {
    await showDialog(
        barrierDismissible: false,
        context: (context),
        builder: (_) {
          return WillPopScope(
              child: verificationDialog(email, socialId),
              onWillPop: () async => false);
        });
  }

  Dialog verificationDialog(email, socialId) {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Dialog(child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Form(
        key: formKeyDialog,
        child: Container(
          height: (email.toString() == null || email.toString().trim() == "")
              ? size.height * 0.30
              : size.height * 0.25,
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  "Verify Profile",
                  style: textTheme.headline6
                      .copyWith(color: themeColor.primaryColor),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: size.height * 0.02),
                child: InternationalPhoneNumberInput(
                  inputDecoration: InputDecoration(
                      filled: true,
                      fillColor: text_field_background_color,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      hintText: "Mobile Number",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.04)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return getTranslated(context, "enter_valid_phone_no");
                    }
                    return null;
                  },
                  spaceBetweenSelectorAndTextField: 0,
                  selectorConfig: SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      setSelectorButtonAsPrefixIcon: true),
                  selectorTextStyle: TextStyle(color: Colors.black),
                  initialValue: number,
                  textFieldController: _phoneController,
                  formatInput: false,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                  onInputChanged: (PhoneNumber number) async {
                    phoneCode = number.dialCode;
                  },
                ),
              ),
              Visibility(
                visible:
                    (email.toString().trim() == "" || email.toString() == null),
                child: Container(
                  width: size.width * 0.9,
                  margin: EdgeInsets.only(top: size.height * 0.02),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          (!isValidEmail(value))) {
                        return getTranslated(context, "enter_valid_email");
                      }
                      return null;
                    },
                    controller: _dialogEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: text_field_background_color,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        hintText: getTranslated(context, 'email'),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.04)),
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: size.height * 0.02),
                  child: RaisedButton(
                    child: dialogLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            "Continue",
                          ),
                    textColor: primary_font,
                    onPressed: () {
                      if (formKeyDialog.currentState.validate()) {
                        setState(() => {dialogLoading = true});

                        UserApiProvider.sendOtp(phoneCode.toString() +
                                _phoneController.text.toString().trim())
                            .then((value) {
                          setState(() => {dialogLoading = false});
                          if (value['result']) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OtpVerification(
                                          email: email,
                                          phone: phoneCode.toString() +
                                              _phoneController.text
                                                  .toString()
                                                  .trim(),
                                          socialId: socialId,
                                          fromVerification: true,
                                        )));
                          } else {
                            showAlertDialog(context, value['message']);
                          }
                        });
                      }
                    },
                  ))
            ],
          ),
        ),
      );
    }));
  }

  isValidEmail(String email) {
    bool emailValid = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
        .hasMatch(email);
    return emailValid;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: isLoading
          ? loadingData(context)
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                          top: size.height * 0.08,
                          left: size.width * 0.06,
                          right: size.width * 0.06,
                          bottom: size.height * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: size.height * 0.25,
                            width: size.width * 0.5,
                            child: Image.asset("assets/icons/auth-banner.png"),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello there,",
                                  style: textTheme.headline5,
                                ),
                                Container(
                                  padding:
                                      EdgeInsets.only(top: size.height * 0.003),
                                  child: Text("Let's sign you in!",
                                      style: textTheme.headline5.copyWith(
                                          color: themeColor.primaryColor)),
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: size.width * 0.9,
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    (!isValidEmail(value))) {
                                  return getTranslated(
                                      context, "enter_valid_email");
                                }
                                return null;
                              },
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: text_field_background_color,
                                  suffixIconConstraints: BoxConstraints(
                                      maxHeight: 24, maxWidth: 44),
                                  suffixIcon: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Image.asset(
                                      "assets/icons/icon-user.png",
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  hintText: getTranslated(context, 'email'),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.04)),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.02),
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Image.asset(
                                      "assets/icons/icon-lock.png",
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  hintText: getTranslated(context, 'password'),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.04)),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            width: size.width * 0.9,
                            height: size.height * 0.06,
                            child: RaisedButton(
                              onPressed: () {
                                login();
                              },
                              child: Text(
                                getTranslated(context, 'login'),
                                style: textTheme.subtitle1
                                    .copyWith(color: primary_font),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ForgotPassword()));
                                },
                                child: Text(
                                  getTranslated(
                                      context, "forgot_your_password"),
                                  style: textTheme.subtitle1,
                                )),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.03),
                            child:
                                Text("Login with", style: textTheme.subtitle1),
                          ),
                          Container(
                            width: size.width * 0.4,
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  child: Image.asset(
                                    "assets/icons/icon-facebook.png",
                                    height: 32,
                                    width: 32,
                                  ),
                                  onTap: () {
                                    facebookSignIn();
                                  },
                                ),
                                /* GestureDetector(
                                  child: Image.asset(
                                    "assets/icons/icon-twitter.png",
                                    height: 32,
                                    width: 32,
                                  ),
                                  onTap: () {},
                                ), */
                                GestureDetector(
                                  child: Image.asset(
                                    "assets/icons/icon-google.png",
                                    height: 32,
                                    width: 32,
                                  ),
                                  onTap: () {
                                    googleSignIn();
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          width: size.width,
                          child: Image.asset(
                            "assets/icons/curve-background.png",
                            width: size.width,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Container(
                          width: size.width,
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.06),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding:
                                    EdgeInsets.only(top: size.height * 0.1),
                                child: Text(
                                  getTranslated(context, "don't_have_account"),
                                  style: textTheme.headline6
                                      .copyWith(color: primary_font),
                                ),
                              ),
                              Container(
                                padding:
                                    EdgeInsets.only(top: size.height * 0.003),
                                child: Text("Let's create it!",
                                    style: textTheme.headline6.copyWith(
                                        color: themeColor.primaryColor)),
                              ),
                              GestureDetector(
                                child: Container(
                                  padding:
                                      EdgeInsets.only(top: size.height * 0.02),
                                  child: Image.asset(
                                    "assets/icons/icon-arrow-right.png",
                                    height: 46,
                                    width: 46,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => SignUpScreen()));
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
