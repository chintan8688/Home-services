import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/screen/service_menu/service_menu.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:home_services/src/widget/seller_drawer.dart';
import 'package:home_services/src/network/api_provider.dart';

class BankDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BankDetailsState();
  }
}

class BankDetailsState extends State<BankDetails> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController bankTypeController = TextEditingController();
  TextEditingController bankBranchController = TextEditingController();
  TextEditingController acNumberController = new TextEditingController();
  TextEditingController trnController = new TextEditingController();

  bool isLoading = true;
  int id = 0;

  @override
  void initState() {
    super.initState();
    getBankDetails();
  }

  getBankDetails() {
    UserApiProvider.getBankDetails().then((value) {
      setState(() {
        if (value['bank_detail'] != null) {
          bankTypeController.text = value['bank_detail']['bank_type'];
          bankBranchController.text = value['bank_detail']['branch'];
          acNumberController.text = value['bank_detail']['account_number'];
          trnController.text = value['bank_detail']['trn'];
          id = value['bank_detail']['id'];
        }
        isLoading = false;
      });
    });
  }

  saveDetails() {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      UserApiProvider.addBankDetails(
        id,
        bankTypeController.text.trim(),
        bankBranchController.text.trim(),
        acNumberController.text.trim(),
        trnController.text.trim(),
      ).then((value) {
        setState(() {
          isLoading = false;
        });
        if (value['result']) {
          showMessage(context, "Bank details updated successfully!");
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
      appBar: primaryAppBar(context, "Bank Details", key),
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
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.02),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter valid bank type";
                            }
                            return null;
                          },
                          controller: bankTypeController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: text_field_background_color_seller,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              hintText: "Type of bank",
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.02),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter valid bank branch";
                            }
                            return null;
                          },
                          controller: bankBranchController,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: text_field_background_color_seller,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              hintText: "Bank branch name",
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.02),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter valid account number";
                            }
                            return null;
                          },
                          controller: acNumberController,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: text_field_background_color_seller,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              hintText: "Account number",
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.02),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter valid TRN";
                            }
                            return null;
                          },
                          controller: trnController,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: text_field_background_color_seller,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              hintText: "TRN",
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
                            saveDetails();
                          },
                          child: Text(
                            "Save",
                            style: textTheme.subtitle1
                                .copyWith(color: primary_font),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
