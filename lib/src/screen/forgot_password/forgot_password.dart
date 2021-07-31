import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/login/login_screen.dart';
import 'package:home_services/src/screen/otp_verification/otp_verification.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class ForgotPassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ForgotPasswordState();
  }
}

class ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _phoneController = new TextEditingController();
  bool isLoading = false;
  PhoneNumber number = PhoneNumber(isoCode: 'JM');
  var phoneCode;

  @override
  void initState() {
    super.initState();
  }

  sendVerificationCode() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      UserApiProvider.forgotPassword(_phoneController.text.trim())
          .then((value) {
        setState(() {
          isLoading = false;
        });
        if (value["result"]) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerification(
                  email: value["user"]["email"].toString().trim(),
                  phone: phoneCode + _phoneController.text.trim(),
                  fromVerification: false,
                ),
              ));
        } else {
          showAlertDialog(context, value["error"]);
        }
      });
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
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Container(
                  height: size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                            top: size.height * 0.08,
                            left: size.width * 0.06,
                            right: size.width * 0.06,
                            bottom: size.height * 0.01),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: size.height * 0.25,
                                width: size.width * 0.5,
                                child:
                                    Image.asset("assets/icons/auth-banner.png"),
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
                                      padding: EdgeInsets.only(
                                          top: size.height * 0.003),
                                      child: Text("Forgot your password!",
                                          style: textTheme.headline5.copyWith(
                                              color: themeColor.primaryColor)),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: size.width * 0.9,
                                margin:
                                    EdgeInsets.only(top: size.height * 0.02),
                                child: InternationalPhoneNumberInput(
                                  inputDecoration: InputDecoration(
                                      filled: true,
                                      fillColor: text_field_background_color,
                                      suffixIconConstraints: BoxConstraints(
                                          maxHeight: 24, maxWidth: 44),
                                      suffixIcon: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Image.asset(
                                          "assets/icons/icon-phone.png",
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
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
                                  selectorTextStyle:
                                      TextStyle(color: Colors.black),
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
                                height: size.height * 0.06,
                                margin:
                                    EdgeInsets.only(top: size.height * 0.02),
                                child: RaisedButton(
                                  onPressed: () {
                                    sendVerificationCode();
                                  },
                                  child: Text(
                                    "Send Otp",
                                    style: textTheme.subtitle1
                                        .copyWith(color: primary_font),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                      Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: size.height * 0.06),
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
                                      EdgeInsets.only(top: size.height * 0.16),
                                  child: Text(
                                    "Already Have An Account?,",
                                    style: textTheme.headline6
                                        .copyWith(color: primary_font),
                                  ),
                                ),
                                Container(
                                  padding:
                                      EdgeInsets.only(top: size.height * 0.003),
                                  child: Text("Let's Sign in!",
                                      style: textTheme.headline6.copyWith(
                                          color: themeColor.primaryColor)),
                                ),
                                GestureDetector(
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: size.height * 0.02),
                                    child: Image.asset(
                                      "assets/icons/icon-arrow-right.png",
                                      height: 46,
                                      width: 46,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginScreen()));
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
            ),
    );
  }
}
