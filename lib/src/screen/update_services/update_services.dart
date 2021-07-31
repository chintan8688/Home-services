import 'package:flutter/material.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:home_services/src/network/api_provider.dart';

import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:home_services/src/widget/seller_drawer.dart';

class UpdateServices extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UpdateServicesState();
  }
}

class UpdateServicesState extends State<UpdateServices> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  GlobalKey<FormState> formKey = GlobalKey();
  List selectedServices = [], services = [], selectedData = [];
  bool isLoading = true, isUpdate = false;
  @override
  void initState() {
    super.initState();
    getServices();
  }

  getServices() {
    UserApiProvider.professionalServices().then((value) {
      if (value['result']) {
        setState(() {
          selectedServices = value['professional_services']
              .map((e) => {"id": e["id"], "name": e["name"]})
              .toList();
          services = value['categories']
              .map((e) => {"id": e["id"], "name": e["name"]})
              .toList();
          isLoading = false;
        });
      }
    });
  }

  updateServices() {
    if (formKey.currentState.validate()) {
      setState(() {
        isUpdate = true;
      });
      formKey.currentState.save();
      UserApiProvider.updateServices(selectedData).then((value) {
        setState(() {
          isUpdate = false;
        });
        if (value['result']) {
          showMessage(context, "Service Update Successfully");
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
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      key: key,
      drawer: SellerDrawer(),
      appBar: primaryAppBar(context, "Update Services", key),
      extendBodyBehindAppBar: isLoading,
      body: isLoading
          ? loadingData(context)
          : SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            left: size.width * 0.03,
                            right: size.width * 0.03,
                            top: size.height * 0.05),
                        child: MultiSelect(
                            autovalidate: false,
                            titleText: "Services",
                            validator: (value) {
                              if (value == null) {
                                return 'Please select one or more option(s)';
                              }
                            },
                            errorText: 'Please select one or more option(s)',
                            dataSource: services,
                            textField: 'name',
                            valueField: 'id',
                            clearButtonColor: themeColor.accentColor,
                            clearButtonTextColor: primary_font,
                            filterable: true,
                            required: true,
                            initialValue:
                                selectedServices.map((e) => e['id']).toList(),
                            onSaved: (value) {
                              setState(() {
                                selectedData = value
                                    .map((e) => {"category_id": e})
                                    .toList();
                              });
                            }),
                      ),
                      Container(
                          width: size.width * 0.6,
                          height: size.height * 0.06,
                          margin: EdgeInsets.only(top: size.height * 0.025),
                          child: RaisedButton(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Update Services",
                                  ),
                                  Visibility(
                                      child: isUpdate
                                          ? Container(
                                              padding: EdgeInsets.only(
                                                  left: size.width * 0.03),
                                              child: SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          Colors.white),
                                                ),
                                              ),
                                            )
                                          : Container())
                                ],
                              ),
                              textColor: primary_font,
                              onPressed: () {
                                updateServices();
                              }))
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
