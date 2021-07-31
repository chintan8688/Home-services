import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/accepting_request/accepting_request.dart';
import 'package:home_services/src/screen/all_categories/all_categories.dart';
import 'package:home_services/src/screen/check_in_request/check_in_request.dart';
import 'package:home_services/src/screen/professional_search/professional_search.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/app_prefrences.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:home_services/src/widget/home_categories_list.dart';
import 'package:home_services/src/widget/home_professional_list.dart';
import 'package:home_services/src/widget/seller_drawer.dart';

class ServiceMenu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ServiceMenuState();
  }
}

class ServiceMenuState extends State<ServiceMenu> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  List categoryData = [],
      bannerData = [],
      mostPopularProfessionals = [],
      mostRequestedProfessionals = [];
  String userType;
  var userData;

  @override
  void initState() {
    super.initState();
    getUserDetail();
  }

  getUserDetail() {
    getUser().then((value) async {
      var user = await json.decode(value);
      userData = user;
      loadData(user);
      notifyRequest(user);
    });
  }

  loadData(user) {
    if (user['role_id'] == 3) {
      UserApiProvider.homeCategoryListConsumer().then((value) {
        if (mounted) {
          setState(() {
            categoryData = value["categories"];
            bannerData = value["banners"];
            mostPopularProfessionals = value['popular_professionals'].map((e) {
              e['name'] = e['professional_details']['name'];
              e['avatar'] = e['professional_details']['avatar'];
              e['service_title'] = e['professional_details']['service_title'];
              e['service_description'] =
                  e['professional_details']['service_description'];
              return e;
            }).toList();

            mostRequestedProfessionals =
                value['most_requested_professionals'].map((e) {
              e['name'] = e['professional_details']['name'];
              e['avatar'] = e['professional_details']['avatar'];
              e['service_title'] = e['professional_details']['service_title'];
              e['service_description'] =
                  e['professional_details']['service_description'];
              return e;
            }).toList();

            isLoading = false;
          });
        }
      });
    } else {
      UserApiProvider.homeCategoryListProfessional().then((value) {
        if (mounted) {
          setState(() {
            categoryData = value["categories"];
            bannerData = value["banners"];
            isLoading = false;
          });
        }
      });
    }
    getAppTheme().then((value) {
      if (mounted) {
        setState(() {
          userType = value;
        });
      }
    });
  }

  notifyRequest(user) {
    if (user['role_id'] == 3) {
      FirebaseFirestore.instance
          .collection("jobs")
          .where('consumer_id', isEqualTo: user['id'])
          .snapshots()
          .listen((event) {
        var data = event.docs?.map((e) => e.data())?.toList() ?? [];
        var request = data
                ?.where((e) =>
                    e["check_in_request"] == true &&
                    e["buyer_accepted"] == false &&
                    e["order_completed"] == false)
                ?.toList() ??
            [];

        if (request.length != 0) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => CheckInRequest(
                        jobId: request[0]["job_id"],
                        professionalId: request[0]["professional_id"],
                        consumerId: user['id'],
                        consumerName: user['name'],
                      )));
        }
      });
    } else {
      FirebaseFirestore.instance
          .collection("jobs")
          .where('professional_id', isEqualTo: user['id'])
          .snapshots()
          .listen((event) {
        var data = event.docs?.map((e) => e.data())?.toList() ?? [];

        var request = data
                ?.where((e) =>
                    e["order_completed"] == false &&
                    e['seller_accepted'] == false &&
                    e["seller_rejected"] == false)
                ?.toList() ??
            [];

        if (request.length != 0) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AcceptRequest(
                        jobId: request[0]["job_id"],
                        consumerId: request[0]["consumer_id"],
                      )));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      key: _key,
      drawer: userType == "seller" ? SellerDrawer() : BuyerDrawer(),
      appBar: primaryAppBar(context, "Select Service", _key),
      extendBodyBehindAppBar: true,
      backgroundColor: stepper_background,
      body: isLoading
          ? loadingData(context)
          : SingleChildScrollView(
              child: Container(
                width: size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: GFCarousel(
                        height: size.height * 0.4,
                        pagination: true,
                        autoPlay: true,
                        viewportFraction: 1.0,
                        aspectRatio: 2.0,
                        activeIndicator: themeColor.primaryColor,
                        pagerSize: 12,
                        passiveIndicator: primary_font,
                        items: bannerData.map<Widget>(
                          (data) {
                            return CachedNetworkImage(
                              imageUrl:
                                  Constant.STORAGE_PATH + data['banner_image'],
                              fit: BoxFit.cover,
                            );
                          },
                        ).toList(),
                        onPageChanged: (index) {
                          setState(() {});
                        },
                      ),
                    ),
                    Container(
                      color: stepper_background,
                      child: Column(
                        children: [
                          userData['role_id'] == 3
                              ? Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.04,
                                        vertical: size.height * 0.03,
                                      ),
                                      child: Material(
                                        elevation: 5,
                                        shadowColor: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                        child: TextFormField(
                                          controller: searchController,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                              filled: true,
                                              fillColor: primary_font,
                                              suffixIcon: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20),
                                                child: SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SearchProfessional(
                                                                      searchQuery: searchController
                                                                          .text
                                                                          .toLowerCase()
                                                                          .trim())));
                                                    },
                                                    child: Image.asset(
                                                      "assets/icons/icon-search.png",
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0)),
                                              hintText: "I need to book a...",
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal:
                                                          size.width * 0.05)),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: size.width * 0.04,
                                          bottom: size.height * 0.03),
                                      child: Column(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(
                                                    top: size.height * 0.01,
                                                    bottom: size.height * 0.03),
                                                child: Text(
                                                  "Popular service provider near you",
                                                  style: textTheme.subtitle1
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.w700),
                                                ),
                                              ),
                                              Container(
                                                  height: size.height * 0.22,
                                                  child: ProfessionalList(
                                                    professionals:
                                                        mostPopularProfessionals,
                                                  )),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        size.height * 0.03),
                                                child: Text(
                                                  "Most requested service provider near you",
                                                  style: textTheme.subtitle1
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.w700),
                                                ),
                                              ),
                                              Container(
                                                  height: size.height * 0.22,
                                                  child: ProfessionalList(
                                                    professionals:
                                                        mostRequestedProfessionals,
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              : Container(),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.04,
                                vertical: userData['role_id'] == 3
                                    ? size.height * 0.01
                                    : size.height * 0.03),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                      bottom: size.height * 0.03),
                                  child: Text(
                                    "Services in your locality",
                                    style: textTheme.subtitle1
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                GridView.builder(
                                  padding: EdgeInsets.zero,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 0.95,
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 5),
                                  physics: ScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: categoryData.length > 10
                                      ? 10
                                      : categoryData.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return HomeCategoriesList(
                                        categoryData[index], userType);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: size.width * 0.32,
                            height: size.height * 0.045,
                            margin: EdgeInsets.only(
                                bottom: size.width * 0.03,
                                top: size.width * 0.01),
                            child: GestureDetector(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: themeColor.primaryColor,
                                    borderRadius: BorderRadius.circular(5.0)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "View More",
                                      style: textTheme.subtitle1
                                          .copyWith(color: primary_font),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: size.width * 0.02),
                                      child: Icon(
                                        Icons.arrow_forward,
                                        color: primary_font,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AllCategories(
                                              services: categoryData,
                                              userType: userType,
                                            )));
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
