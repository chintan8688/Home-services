import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:home_services/src/widget/seller_drawer.dart';
import 'package:timezone/standalone.dart' as tz;

class WalletDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletDetailsState();
  }
}

class WalletDetailsState extends State<WalletDetails>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> key = GlobalKey();
  GlobalKey<FormState> formKey = GlobalKey();
  TabController _tabController;
  TextEditingController amountController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  List withdrawals = [], transactions = [];
  bool isLoading = true, isRequested = false, dialogLoader = false;
  String balance = "0.00";
  var jamaica;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    jamaica = tz.getLocation('America/Jamaica');
    getTransactions();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  getTransactions() {
    UserApiProvider.professionalTransactions().then((value) {
      if (value['result']) {
        setState(() {
          balance = value['balance'];
          isRequested = value['already_requested'];
          transactions = value['professional_transaction_details'];
          withdrawals = value['professional_withdraw_request'];
          isLoading = false;
        });
      }
    });
  }

  String timeAgo(DateTime d) {
    var jamaicaTime = tz.TZDateTime.now(jamaica)
        .toString()
        .substring(0, tz.TZDateTime.now(jamaica).toString().lastIndexOf("."));
    var requestTime = d.toString().substring(0, d.toString().lastIndexOf("."));
    Duration diff =
        DateTime.parse(jamaicaTime).difference(DateTime.parse(requestTime));

    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    if (diff.inDays > 30)
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    if (diff.inDays > 7)
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    if (diff.inDays > 0)
      return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
    if (diff.inHours > 0)
      return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    return "Just now";
  }

  Future<void> showSuccessDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
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

  Dialog withDrawRequest() {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Form(
            key: formKey,
            child: Container(
              height: size.height * 0.4,
              width: size.width * 0.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: size.width,
                    height: size.height * 0.05,
                    color: themeColor.primaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "WithDraw Request",
                          textAlign: TextAlign.center,
                          style:
                              textTheme.headline6.copyWith(color: primary_font),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.04),
                            child: TextFormField(
                                controller: amountController,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      int.parse(value.trim()) <= 0) {
                                    return "Enter valid withdraw amount";
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: stepper_background,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    hintText: "Enter amount",
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.04))),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.04),
                            child: TextFormField(
                                controller: notesController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: stepper_background,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    hintText: "Enter Notes",
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.04,
                                        vertical: size.height * 0.015))),
                          ),
                          Container(
                            width: size.width * 0.6,
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            child: RaisedButton(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Request Withdraw",
                                  ),
                                  dialogLoader
                                      ? Container(
                                          padding: EdgeInsets.only(left: 5),
                                          child: SizedBox(
                                            height: 15,
                                            width: 15,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                              textColor: primary_font,
                              onPressed: () {
                                if (formKey.currentState.validate()) {
                                  setState(() {
                                    dialogLoader = true;
                                  });
                                  UserApiProvider.withdrawRequest(
                                          amountController.text.trim(),
                                          notesController.text.trim())
                                      .then((value) {
                                    setState(() {
                                      dialogLoader = false;
                                    });
                                    if (value['result']) {
                                      Navigator.of(context).pop();
                                      showSuccessDialog(context,
                                          'Withdraw request sent successfully.');
                                    } else {
                                      Navigator.of(context).pop();
                                      showAlertDialog(
                                          context, value['message']);
                                    }
                                  });
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  listDataWithDrawls(context, result) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    return ListView.builder(
        itemCount: result.length,
        itemBuilder: (context, index) {
          var transaction = result[index];
          return Container(
            margin: EdgeInsets.only(bottom: size.height * 0.01),
            child: Card(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: size.width * 0.6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: size.width * 0.6,
                            padding: EdgeInsets.only(left: size.width * 0.025),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.01),
                                  child: Text(
                                    transaction['amount'].toString() + " JMD",
                                    style: textTheme.subtitle2
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 3),
                                  child: Text(
                                    timeAgo(DateTime.parse(
                                        transaction['created_at'])),
                                    style: textTheme.caption,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: themeColor.primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        child: Text(
                          transaction['status'].toString().toUpperCase(),
                          style:
                              textTheme.caption.copyWith(color: primary_font),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  listDataTransactions(context, result) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    return ListView.builder(
        itemCount: result.length,
        itemBuilder: (context, index) {
          var transaction = result[index];
          return Container(
            margin: EdgeInsets.only(bottom: size.height * 0.01),
            child: Card(
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: size.height * 0.015,
                    horizontal: size.width * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: size.width * 0.58,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CachedNetworkImage(
                            imageUrl: Constant.STORAGE_PATH +
                                transaction['consumer_avatar'],
                            imageBuilder: (context, imageProvider) => Container(
                              width: size.width * 0.15,
                              height: size.width * 0.15,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          Container(
                            width: size.width * 0.4,
                            padding: EdgeInsets.only(left: size.width * 0.025),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.01),
                                  child: Text(
                                    transaction['consumer_name'],
                                    style: textTheme.subtitle2
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 3),
                                  child: Text(
                                    transaction['job_title'],
                                    style: textTheme.caption,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: size.width * 0.3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            child: Text(
                              transaction['amount'].toString() + " JMD",
                              style: textTheme.subtitle2
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 3),
                            child: Text(
                              timeAgo(
                                  DateTime.parse(transaction['created_at'])),
                              style: textTheme.caption,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    return Scaffold(
      key: key,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Wallet"),
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
      ),
      drawer: SellerDrawer(),
      extendBodyBehindAppBar: isLoading,
      body: isLoading
          ? loadingData(context)
          : Container(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02, vertical: size.height * 0.015),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            "My Wallet Balance",
                            style: textTheme.subtitle1,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.01),
                            child: Text(
                              "$balance JMD",
                              style: textTheme.headline5,
                            ),
                          )
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(left: size.width * 0.03),
                        child: RaisedButton(
                          color: isRequested || balance == "0.00"
                              ? Colors.grey
                              : themeColor.primaryColor,
                          child: Text(
                            "Withdraw",
                          ),
                          textColor: primary_font,
                          onPressed: () async {
                            if ((!isRequested && balance != "0.00")) {
                              await showDialog(
                                  context: context,
                                  builder: (_) => withDrawRequest());
                            } else {
                              return null;
                            }
                          },
                        ),
                      )
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                    child: Container(
                      height: size.height * 0.06,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(
                          25.0,
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            25.0,
                          ),
                          color: themeColor.primaryColor,
                        ),
                        labelColor: primary_font,
                        unselectedLabelColor: Colors.black,
                        tabs: [
                          Tab(
                            text: 'Transactions',
                          ),
                          Tab(
                            text: 'Withdrawals',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Container(
                          width: size.width,
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  width: size.width,
                                  color: primary_font,
                                  child: transactions.length != 0
                                      ? listDataTransactions(
                                          context, transactions)
                                      : noDataFound(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: size.width,
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  width: size.width,
                                  color: primary_font,
                                  child: withdrawals.length != 0
                                      ? listDataWithDrawls(context, withdrawals)
                                      : noDataFound(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
