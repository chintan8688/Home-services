import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/login/login_screen.dart';
import 'package:home_services/src/screen/terms_and_conditions/terms_and_condditions.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignUpScreenState();
  }
}

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _fullNameController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _addressController = new TextEditingController();

  File profilePicture, documentPicture;
  bool isProfileNull = false, isDocumentNull = false, isLoading = false;
  PhoneNumber number = PhoneNumber(isoCode: 'JM');
  var phoneCode;

  @override
  void initState() {
    super.initState();
  }

  getPictureFromGallery(String type) async {
    if (type == "profile") {
      final pickedFile = await ImagePicker()
          .getImage(source: ImageSource.gallery, imageQuality: 50);
      setState(() {
        if (pickedFile != null) {
          profilePicture = File(pickedFile.path);
        }
      });
    } else {
      final pickedFile = await ImagePicker()
          .getImage(source: ImageSource.gallery, imageQuality: 50);
      setState(() {
        if (pickedFile != null) {
          documentPicture = File(pickedFile.path);
        }
      });
    }
  }

  checkIsUploadImages() {
    if (profilePicture == null) {
      setState(() {
        isProfileNull = true;
      });
      return false;
    } else {
      return true;
    }
  }

  signUp() async {
    if (_formKey.currentState.validate()) {
      if (checkIsUploadImages()) {
        setState(() {
          isDocumentNull = false;
          isProfileNull = false;
          isLoading = true;
        });
        UserApiProvider.signUp(
          _fullNameController.text,
          _emailController.text,
          phoneCode,
          _phoneController.text,
          _addressController.text,
          profilePicture,
          3,
        ).then((value) {
          setState(() {
            isLoading = false;
          });
          if (value["result"]) {
            var data = value["user"];
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => TermsAndConditions(
                          email: data["email"].toString().trim(),
                          phone: data["phone_code"].toString().trim() +
                              data["phone"].toString().trim(),
                        )));
          } else {
            showAlertDialog(context, value["error"]);
          }
        });
      }
    } else {
      if (checkIsUploadImages()) {
        setState(() {
          isDocumentNull = false;
          isProfileNull = false;
        });
      }
    }
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
                                  child: Text("Sign up to get started!",
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
                                if (value == null || value.isEmpty) {
                                  return "Enter valid name";
                                }
                                return null;
                              },
                              controller: _fullNameController,
                              keyboardType: TextInputType.text,
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
                                  hintText: "Full Name",
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.04)),
                            ),
                          ),
                          Container(
                            width: size.width * 0.9,
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            child: InternationalPhoneNumberInput(
                              inputDecoration: InputDecoration(
                                  filled: true,
                                  fillColor: text_field_background_color,
                                  suffixIconConstraints: BoxConstraints(
                                      maxHeight: 24, maxWidth: 44),
                                  suffixIcon: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Image.asset(
                                      "assets/icons/icon-phone.png",
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  hintText: "Mobile Number",
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.04)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return getTranslated(
                                      context, "enter_valid_phone_no");
                                }
                                return null;
                              },
                              spaceBetweenSelectorAndTextField: 0,
                              selectorConfig: SelectorConfig(
                                  selectorType:
                                      PhoneInputSelectorType.BOTTOM_SHEET,
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
                                      "assets/icons/icon-email.png",
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
                                  return "Enter valid address";
                                }
                                return null;
                              },
                              controller: _addressController,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: text_field_background_color,
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  hintText: "House no. building and locality",
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.04)),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: text_field_background_color,
                                      border: Border.all(
                                          color: themeColor.accentColor),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0))),
                                  height: size.height * 0.1,
                                  width: size.width * 0.2,
                                  child: profilePicture != null
                                      ? Image.file(
                                          profilePicture,
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                Container(
                                  padding:
                                      EdgeInsets.only(left: size.width * 0.05),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Upload Profile Picture",
                                        style: textTheme.subtitle2,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        height: 20,
                                        child: RaisedButton(
                                          color: Color(0xFF8cc660),
                                          textColor: primary_font,
                                          onPressed: () {
                                            getPictureFromGallery("profile");
                                          },
                                          child: Text("Browse"),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Visibility(
                              visible: isProfileNull,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.008,
                                    horizontal: size.width * 0.04),
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Upload Profile Picture",
                                  style: textTheme.caption
                                      .copyWith(color: error_color),
                                ),
                              )),
                          Container(
                            width: size.width * 0.9,
                            height: size.height * 0.06,
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            child: RaisedButton(
                              onPressed: () {
                                signUp();
                              },
                              child: Text(
                                "Register",
                                style: textTheme.subtitle1
                                    .copyWith(color: primary_font),
                              ),
                            ),
                          ),
                          /*Container(
                            margin: EdgeInsets.only(top: size.height * 0.03),
                            child: Text("Register with",
                                style: textTheme.subtitle1),
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
                                  onTap: () {},
                                ),
                                GestureDetector(
                                  child: Image.asset(
                                    "assets/icons/icon-google.png",
                                    height: 32,
                                    width: 32,
                                  ),
                                  onTap: () {},
                                )
                              ],
                            ),
                          ),*/
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
                                  "Already Have An Account?,",
                                  style: textTheme.headline6
                                      .copyWith(color: primary_font),
                                ),
                              ),
                              Container(
                                padding:
                                    EdgeInsets.only(top: size.height * 0.003),
                                child: Text("Let's sign in!",
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
                                      builder: (context) => LoginScreen()));
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
