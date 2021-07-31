import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:permission_handler/permission_handler.dart';

class Constant {
  static const STORAGE_PATH = 'https://clickaway.fanstter.com/storage/';
}

AppBar primaryAppBar(BuildContext context, title, GlobalKey<ScaffoldState> key,
    [image]) {
  return AppBar(
    centerTitle: true,
    title: image == null
        ? Text(
            title.toString().contains("_")
                ? getTranslated(context, title)
                : title,
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ImageIcon(
                NetworkImage(Constant.STORAGE_PATH + image),
                color: primary_font,
                size: 25,
              ),
              Container(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  title.toString().contains("_")
                      ? getTranslated(context, title)
                      : title,
                ),
              )
            ],
          ),
    leading: IconButton(
        icon: Image.asset(
          "assets/icons/icon-drawer.png",
          height: 24,
          width: 24,
        ),
        onPressed: () {
          key.currentState.openDrawer();
        }),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(25),
        bottomRight: Radius.circular(25),
      ),
    ),
  );
}

Future<void> showAlertDialog(BuildContext context, String message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
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

getLocationPermission() async {
  var status = await Permission.location.status;
  if (status.isDenied) {
    await Permission.location
        .request()
        .then((value) => getLocationPermission());
  } else if (status.isPermanentlyDenied) {
    Geolocator.openAppSettings();
  } else if (status.isUndetermined) {
    await Permission.location
        .request()
        .then((value) => getLocationPermission());
  }

  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  return position;
}

Widget noDataFound(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/icons/no-data.png"),
        Container(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.005),
          child: Text(
            "Sorry, No Records Found!",
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: grey_color),
          ),
        )
      ],
    ),
  );
}

Widget loadingData(BuildContext context) {
  return Container(
    color: Colors.black,
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    child: Center(
      child: Image.asset(
        "assets/icons/icon-loading.png",
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.height * 0.2,
      ),
    ),
  );
}
