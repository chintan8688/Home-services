import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:timezone/standalone.dart' as tz;

class ConsumerTransactions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ConsumerTransactionsState();
  }
}

class ConsumerTransactionsState extends State<ConsumerTransactions> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController notesController = TextEditingController();

  List transactions = [];
  bool isLoading = true, dialogLoader = false;

  var jamaica;

  @override
  void initState() {
    super.initState();
    jamaica = tz.getLocation('America/Jamaica');
    getTransactions();
  }

  getTransactions() {
    UserApiProvider.consumerTransactions().then((value) {
      if (value['result']) {
        setState(() {
          transactions = value['consumer_payments'];
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

  Dialog disputeRequest(jobId) {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Form(
            key: formKey,
            child: Container(
              height: size.height * 0.3,
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
                          "Dispute Request",
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
                                    "Dispute",
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
                                  UserApiProvider.disputeRequest(
                                          notesController.text.trim(), jobId)
                                      .then((value) {
                                    setState(() {
                                      dialogLoader = false;
                                    });
                                    if (value['result']) {
                                      Navigator.of(context).pop();
                                      showSuccessDialog(context,
                                          'Dispute request sent successfully.');
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
                      width: size.width * 0.65,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CachedNetworkImage(
                            imageUrl: Constant.STORAGE_PATH +
                                transaction['professional_avatar'],
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
                            width: size.width * 0.50,
                            padding: EdgeInsets.only(left: size.width * 0.025),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  /*padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.01),*/
                                  child: Text(
                                    transaction['professional_name'],
                                    style: textTheme.subtitle2
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.01),
                                  child: Text(
                                    transaction['job_title'],
                                    style: textTheme.caption,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (transaction['dispute_status'] == null) {
                                      await showDialog(
                                          context: context,
                                          builder: (_) => disputeRequest(
                                              transaction['job_id']));
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.03,
                                        vertical: size.height * 0.007),
                                    decoration: BoxDecoration(
                                        color: transaction['dispute_status'] ==
                                                null
                                            ? themeColor.primaryColor
                                            : Colors.grey[400],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Text(
                                      "Dispute",
                                      style: textTheme.caption
                                          .copyWith(color: primary_font),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                transaction['dispute_status'] != null
                                    ? Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.01),
                                        child: Text(
                                          transaction['admin_comment'] != null
                                              ? transaction['admin_comment']
                                              : "You have already sent dispute request please contact admin.",
                                          style: textTheme.caption,
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: size.width * 0.22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            /*padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),*/
                            child: Text(
                              transaction['payment_amount'].toString() + " JMD",
                              style: textTheme.subtitle2
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            child: Text(
                              timeAgo(
                                  DateTime.parse(transaction['payment_date'])),
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
      appBar: primaryAppBar(context, "Transactions", key),
      drawer: BuyerDrawer(),
      extendBodyBehindAppBar: isLoading,
      body: isLoading
          ? loadingData(context)
          : Container(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02, vertical: size.height * 0.015),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      child: transactions.length != 0
                          ? listDataTransactions(context, transactions)
                          : noDataFound(context),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
