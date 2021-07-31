import 'package:shared_preferences/shared_preferences.dart';

void setUserToken(String token) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.setString("USER_TOKEN", token);
}

Future<String> getUserToken() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String token = _prefs.getString("USER_TOKEN");
  return token;
}

void setUser(String userData) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.setString("USER", userData);
}

Future<String> getUser() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String user = _prefs.getString("USER");
  return user;
}

void setDeviceToken(String token) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.setString("DEVICE_TOKEN", token);
}

Future<String> getDeviceToken() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String token = _prefs.getString("DEVICE_TOKEN");
  return token;
}

Future<String> getNotificationData() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String notification = _prefs.getString("NOTIFICATION");
  return notification;
}

void setNotificationData(String notification) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.setString("NOTIFICATION", notification);
}

void clearNotificationData() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.remove("NOTIFICATION");
}

Future<String> getAppTheme() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String userType = _prefs.getString("USER_TYPE") ?? "buyer";
  return userType;
}

Future<String> setAppTheme(String userType) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.setString("USER_TYPE", userType);
  return userType;
}

Future<String> getWalletBalance() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String balance = _prefs.getString("BALANCE") ?? "0.00";
  return balance;
}

void setWalletBalance(String balance) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.setString("BALANCE", balance);
}

void clearPreferences() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.remove("USER_TOKEN");
  _prefs.remove("USER");
  _prefs.remove("NOTIFICATION");
  _prefs.remove("USER_TYPE");
  _prefs.remove("BALANCE");
}
