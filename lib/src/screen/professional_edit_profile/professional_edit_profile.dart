import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/service_menu/service_menu.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/app_prefrences.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:home_services/src/widget/seller_drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class ProfessionalEditProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfessionalEditProfileState();
  }
}

class ProfessionalEditProfileState extends State<ProfessionalEditProfile> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  GlobalKey<FormState> formKey = GlobalKey();
  GlobalKey<FormState> pformKey = GlobalKey();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

  PhoneNumber number = PhoneNumber(isoCode: 'JM');
  var phoneCode, isLoading = true, isJwt = false;
  File profilePicture;
  String avatar;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() {
    getUser().then((value) async {
      var userData = json.decode(value);
      var phoneData = await PhoneNumber.getRegionInfoFromPhoneNumber(
          userData['phone_code'] == null
              ? userData['phone']
              : userData['phone_code'] + userData['phone']);
      setState(() {
        isJwt = userData['type'] == "jwt" ? true : false;
        avatar = userData['avatar'];
        number = phoneData;
        _fullNameController.text = userData['name'];
        _phoneController.text = userData['phone'];
        _addressController.text = userData['address'];
        isLoading = false;
      });
    });
  }

  getPictureFromGallery() async {
    final pickedFile = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        profilePicture = File(pickedFile.path);
      });
    }
  }

  saveProfile() {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      UserApiProvider.updateProfileProfessional(
              _fullNameController.text,
              _addressController.text,
              phoneCode,
              _phoneController.text,
              profilePicture)
          .then((value) {
        setState(() {
          isLoading = false;
        });
        if (value['result']) {
          setUser(json.encode(value['professional']));
          showMessage(context, "Profile updated successfully!");
        } else {
          showAlertDialog(context, value["message"]);
        }
      });
    }
  }

  changePassword() {
    if (pformKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      UserApiProvider.changePasswordProfessional(passwordController.text.trim())
          .then((value) {
        setState(() {
          isLoading = false;
        });
        if (value['result']) {
          showMessage(context, "Password change successfully!");
        } else {
          showAlertDialog(context, value["message"]);
        }
      });
    }
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
                Navigator.of(context).pop();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ServiceMenu()));
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
      appBar: primaryAppBar(context, "Edit Profile", key),
      drawer: SellerDrawer(),
      extendBodyBehindAppBar: isLoading,
      body: isLoading
          ? loadingData(context)
          : SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Container(
                  width: size.width,
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.06,
                      vertical: size.height * 0.05),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: size.height * 0.15,
                            width: size.width * 0.3,
                            child: GestureDetector(
                              onTap: () {
                                getPictureFromGallery();
                              },
                              child: CircleAvatar(
                                radius: size.width * 0.12,
                                child: ClipOval(
                                  child: profilePicture == null
                                      ? CachedNetworkImage(
                                          imageUrl:
                                              Constant.STORAGE_PATH + avatar,
                                          fit: BoxFit.cover,
                                          width: size.width * 0.3,
                                          height: size.width * 0.3,
                                        )
                                      : Image(
                                          image: FileImage(profilePicture),
                                          fit: BoxFit.cover,
                                          width: size.width * 0.3,
                                          height: size.width * 0.3,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 5,
                            child: GestureDetector(
                              onTap: () {
                                getPictureFromGallery();
                              },
                              child: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                    color: grey_color.withOpacity(0.4),
                                    shape: BoxShape.circle),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Container(
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
                              fillColor: text_field_background_color_seller,
                              suffixIconConstraints:
                                  BoxConstraints(maxHeight: 24, maxWidth: 44),
                              suffixIcon: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
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
                        margin: EdgeInsets.only(top: size.height * 0.02),
                        child: InternationalPhoneNumberInput(
                          inputDecoration: InputDecoration(
                              filled: true,
                              fillColor: text_field_background_color_seller,
                              suffixIconConstraints:
                                  BoxConstraints(maxHeight: 24, maxWidth: 44),
                              suffixIcon: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
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
                              fillColor: text_field_background_color_seller,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              hintText: "House no. building and locality",
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04)),
                        ),
                      ),
                      Container(
                        width: size.width * 0.9,
                        height: size.height * 0.06,
                        margin: EdgeInsets.only(top: size.height * 0.02),
                        child: RaisedButton(
                          onPressed: () {
                            saveProfile();
                          },
                          child: Text(
                            "Save",
                            style: textTheme.subtitle1
                                .copyWith(color: primary_font),
                          ),
                        ),
                      ),
                      isJwt
                          ? Form(
                              key: pformKey,
                              child: Column(
                                children: [
                                  Container(
                                    width: size.width * 0.7,
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.03),
                                    child: Text(
                                      "Change Password",
                                      style: textTheme.headline5.copyWith(
                                          color: themeColor.primaryColor),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.02),
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return getTranslated(
                                              context, "enter_valid_password");
                                        }
                                        return null;
                                      },
                                      controller: passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          filled: true,
                                          fillColor:
                                              text_field_background_color_seller,
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
                                              context, 'password'),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: size.width * 0.04)),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.02),
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return getTranslated(
                                              context, "enter_valid_password");
                                        } else if (value !=
                                            passwordController.text) {
                                          return getTranslated(context,
                                              "both_password_not_match");
                                        }
                                        return null;
                                      },
                                      controller: confirmPasswordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          filled: true,
                                          fillColor:
                                              text_field_background_color_seller,
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
                                    width: size.width * 0.9,
                                    height: size.height * 0.06,
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.02),
                                    child: RaisedButton(
                                      onPressed: () {
                                        changePassword();
                                      },
                                      child: Text(
                                        "Save",
                                        style: textTheme.subtitle1
                                            .copyWith(color: primary_font),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
