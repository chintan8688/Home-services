import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/job_details/job_details.dart';
import 'package:home_services/src/screen/order_completed/order_completed.dart';
import 'package:home_services/src/screen/order_summary/order_summary.dart';
import 'package:home_services/src/screen/request_summary/request_summary.dart';
import 'package:home_services/src/screen/track_work/track_work.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/app_prefrences.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';

class ConsumerJobs extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ConsumerJobsState();
  }
}

class ConsumerJobsState extends State<ConsumerJobs> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  TextEditingController searchController = TextEditingController();
  List jobList = [], searchList = [];
  bool isLoading = true, isSearched = false;
  var user;

  @override
  void initState() {
    super.initState();
    getJobList();
  }

  getJobList() {
    UserApiProvider.consumerJobs().then((value) {
      if (value['result']) {
        getUser().then((res) {
          setState(() {
            jobList = value['jobs'];
            isLoading = false;
            user = json.decode(res);
          });
        });
      }
    });
  }

  searchQuery(query) {
    if (query.toString().length > 2) {
      var filterData = jobList
          .where((e) =>
              e['title'].toString().toLowerCase().contains(query) ||
              e['description'].toString().toLowerCase().contains(query) ||
              e['name'].toString().toLowerCase().contains(query) ||
              e['work_date'].toString().toLowerCase().contains(query) ||
              e['work_time'].toString().toLowerCase().contains(query) ||
              e['status'].toString().toLowerCase().contains(query))
          .toList();
      setState(() {
        searchList = filterData;
        isSearched = true;
      });
    } else if (query.toString().length == 0) {
      setState(() {
        searchList = [];
        isSearched = false;
      });
    }
  }

  navigateToJobScreen(status, job) {
    if (status == "Completed") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OrderCompleted(
                    jobId: job['id'],
                    consumerId: job['consumer_id'],
                    fromJobs: true,
                  )));
    } else if (status == "Incomplete") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OrderSummary(
                    jobId: job['id'],
                    consumerId: job['consumer_id'],
                  )));
    } else if (status == "In progress") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TrackWork(
                    jobId: job['id'],
                    consumerId: job['consumer_id'],
                  )));
    } else if (status == "Pending") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => JobDetails(
                    job: job,
                  )));
    } else if (status == "Unpaid") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RequestSummary(
                    jobId: job['id'],
                    consumerId: job['consumer_id'],
                  )));
    }
  }

  listData(context, result) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    return ListView.builder(
        itemCount: result.length,
        itemBuilder: (context, index) {
          var data = result[index];
          return Container(
            margin: EdgeInsets.only(bottom: size.height * 0.01),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => JobDetails(
                              job: data,
                            )));
              },
              child: Card(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: size.width * 0.82,
                            padding: EdgeInsets.only(left: size.width * 0.03),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CachedNetworkImage(
                                  imageUrl:
                                      Constant.STORAGE_PATH + user['avatar'],
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: size.width * 0.15,
                                    height: size.width * 0.15,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(left: size.width * 0.03),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.01),
                                        child: Text(
                                          data['title'],
                                          style: textTheme.subtitle2.copyWith(
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      Container(
                                        width: size.width * 0.6,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 3),
                                        child: Text(
                                            data['description']
                                                        .toString()
                                                        .length >
                                                    50
                                                ? data['description']
                                                        .toString()
                                                        .substring(0, 50) +
                                                    "..."
                                                : data['description'],
                                            style: textTheme.subtitle2),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(right: size.width * 0.03),
                            child: GestureDetector(
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: themeColor.primaryColor,
                                size: 24,
                              ),
                            ),
                          )
                        ],
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: size.height * 0.008),
                        child: Divider(),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: size.width * 0.2,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.005),
                                child: Text(
                                  "Category",
                                  style: textTheme.caption
                                      .copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                width: size.width * 0.2,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.005),
                                child: Text(
                                  data['name'],
                                  style: textTheme.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: themeColor.primaryColor),
                                ),
                              ),
                              Container(
                                width: size.width * 0.2,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.005),
                                child: Text(
                                  "Work Date",
                                  style: textTheme.caption
                                      .copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                width: size.width * 0.2,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.005),
                                child: Text(
                                  data['work_date'],
                                  style: textTheme.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: themeColor.primaryColor),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: size.width * 0.2,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.005),
                                child: Text(
                                  "Price",
                                  style: textTheme.caption
                                      .copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                width: size.width * 0.2,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.005),
                                child: Text(
                                  data['price'].toString(),
                                  style: textTheme.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: themeColor.primaryColor),
                                ),
                              ),
                              Container(
                                width: size.width * 0.2,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.005),
                                child: Text(
                                  "Work Time",
                                  style: textTheme.caption
                                      .copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                width: size.width * 0.2,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.005),
                                child: Text(
                                  data['work_time'],
                                  style: textTheme.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: themeColor.primaryColor),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              navigateToJobScreen(data['status'], data);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(left: size.width * 0.03),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: size.width * 0.23,
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.005),
                                    child: Text(
                                      "Status",
                                      style: textTheme.caption.copyWith(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Container(
                                    width: size.width * 0.3,
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.005),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * 0.03,
                                          vertical: size.height * 0.007),
                                      decoration: BoxDecoration(
                                          color: themeColor.primaryColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            data['status'],
                                            style: textTheme.caption
                                                .copyWith(color: primary_font),
                                            textAlign: TextAlign.center,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 5),
                                            child: Icon(
                                              Icons.arrow_forward_ios,
                                              color: primary_font,
                                              size: 14,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
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
      drawer: BuyerDrawer(),
      appBar: primaryAppBar(context, "Your Jobs", key),
      extendBodyBehindAppBar: isLoading,
      body: Center(
        child: isLoading
            ? loadingData(context)
            : jobList.length == 0
                ? noDataFound(context)
                : Container(
                    width: size.width,
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.02),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.02),
                          child: Container(
                            width: size.width * 0.92,
                            child: TextFormField(
                              controller: searchController,
                              keyboardType: TextInputType.text,
                              onChanged: (text) => searchQuery(text),
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: text_field_background_color,
                                  suffixIconConstraints: BoxConstraints(
                                      maxHeight: 24, maxWidth: 44),
                                  suffixIcon: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Image.asset(
                                      "assets/icons/icon-search.png",
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  hintText: "Search...",
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.04)),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Container(
                          width: size.width,
                          color: primary_font,
                          child: !isSearched
                              ? listData(context, jobList)
                              : listData(context, searchList),
                        )),
                      ],
                    ),
                  ),
      ),
    );
  }
}
