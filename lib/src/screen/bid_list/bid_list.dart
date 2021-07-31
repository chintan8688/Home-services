import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/worker_profile/worker_profile.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';

class BidList extends StatefulWidget {
  final jobId;

  BidList({this.jobId});

  @override
  State<StatefulWidget> createState() {
    return BidListState();
  }
}

class BidListState extends State<BidList> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  TextEditingController searchController = TextEditingController();
  List bidList = [];
  bool isLoading = true, isFavourite = false;

  @override
  void initState() {
    super.initState();
    getBidList();
  }

  getBidList() {
    UserApiProvider.bidList(widget.jobId).then((value) {
      if (value['result']) {
        setState(() {
          bidList = value['job_bids'];
          bidList.map((e) => {e["is_expanded"] = false}).toList();
          isLoading = false;
        });
      }
    });
  }

  removeFavourite(id) {
    UserApiProvider.removeFavourite(id);
  }

  setFavourite(id) {
    UserApiProvider.setFavourite(id);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    return Scaffold(
      key: key,
      drawer: BuyerDrawer(),
      appBar: primaryAppBar(context, "Bids", key),
      extendBodyBehindAppBar: isLoading,
      body: Center(
        child: isLoading
            ? loadingData(context)
            : bidList.length == 0
                ? noDataFound(context)
                : Container(
                    width: size.width,
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.02),
                    child: Column(
                      children: [
                        /* Container(
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.02),
                      child: Container(
                        width: size.width * 0.92,
                        child: TextFormField(
                          controller: searchController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: text_field_background_color,
                              suffixIconConstraints:
                                  BoxConstraints(maxHeight: 24, maxWidth: 44),
                              suffixIcon: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
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
                    ), */
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.01),
                        ),
                        Expanded(
                            child: Container(
                          width: size.width,
                          color: primary_font,
                          child: ListView.builder(
                              itemCount: bidList.length,
                              itemBuilder: (context, index) {
                                var data = bidList[index];
                                isFavourite =
                                    data['is_favorite'] == 1 ? true : false;
                                return Container(
                                  margin: EdgeInsets.only(
                                      bottom: size.height * 0.01),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  WorkerProfile(
                                                    professional: data,
                                                    category: data['category'],
                                                    scheduledJob: true,
                                                    jobId: data['job_id'],
                                                    fromFavourite: false,
                                                    fromBids: true,
                                                  )));
                                    },
                                    child: Card(
                                      child: Container(
                                          padding: EdgeInsets.all(
                                              size.height * 0.01),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  CachedNetworkImage(
                                                    imageUrl:
                                                        Constant.STORAGE_PATH +
                                                            data['avatar'],
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      width: size.width * 0.15,
                                                      height: size.width * 0.15,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: size.width * 0.74,
                                                    padding: EdgeInsets.only(
                                                        left:
                                                            size.width * 0.015),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    child: Text(
                                                                      data[
                                                                          "name"],
                                                                      style: textTheme
                                                                          .subtitle1
                                                                          .copyWith(
                                                                              fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    padding: EdgeInsets.only(
                                                                        left: size.width *
                                                                            0.02),
                                                                    child:
                                                                        GFRating(
                                                                      value: data["rating"]['average_rating'] !=
                                                                              null
                                                                          ? double.parse(
                                                                              data["rating"]['average_rating'].toString())
                                                                          : 0.0,
                                                                      size:
                                                                          16.0,
                                                                      color:
                                                                          button_secondary,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                      '(${data["rating"]['rating_count'].toString()})')
                                                                ],
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  if (isFavourite) {
                                                                    removeFavourite(
                                                                        data[
                                                                            'professional_id']);
                                                                    setState(
                                                                        () {
                                                                      isFavourite =
                                                                          !isFavourite;
                                                                      data['is_favorite'] =
                                                                          0;
                                                                    });
                                                                  } else {
                                                                    setFavourite(
                                                                        data[
                                                                            'professional_id']);
                                                                    setState(
                                                                        () {
                                                                      isFavourite =
                                                                          !isFavourite;
                                                                      data['is_favorite'] =
                                                                          1;
                                                                    });
                                                                  }
                                                                },
                                                                child:
                                                                    isFavourite
                                                                        ? Icon(
                                                                            Icons.favorite,
                                                                            color:
                                                                                themeColor.primaryColor,
                                                                            size:
                                                                                14,
                                                                          )
                                                                        : Icon(
                                                                            Icons.favorite_border,
                                                                            color:
                                                                                grey_color,
                                                                            size:
                                                                                14,
                                                                          ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          size.height *
                                                                              0.005),
                                                              child: Text(
                                                                "Bid Price:",
                                                                style: textTheme
                                                                    .subtitle2,
                                                              ),
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.symmetric(
                                                                  vertical:
                                                                      size.height *
                                                                          0.005,
                                                                  horizontal:
                                                                      size.width *
                                                                          0.01),
                                                              child: Text(
                                                                data["price"]
                                                                    .toString(),
                                                                style: textTheme
                                                                    .subtitle2
                                                                    .copyWith(
                                                                        color: themeColor
                                                                            .primaryColor),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: size
                                                                          .height *
                                                                      0.005),
                                                          child: Text(
                                                            "Proposal Description:",
                                                            style: textTheme
                                                                .subtitle2,
                                                          ),
                                                        ),
                                                        Container(
                                                          width:
                                                              size.width * 0.7,
                                                          padding: EdgeInsets.only(
                                                              bottom:
                                                                  size.height *
                                                                      0.003),
                                                          child: Text(data[
                                                                  "is_expanded"]
                                                              ? data[
                                                                  "proposal_description"]
                                                              : data['proposal_description']
                                                                          .toString()
                                                                          .length >
                                                                      50
                                                                  ? data["proposal_description"]
                                                                      .toString()
                                                                      .substring(
                                                                          0, 50)
                                                                  : data[
                                                                      'proposal_description']),
                                                        ),
                                                        Visibility(
                                                            visible: data[
                                                                        'proposal_description']
                                                                    .toString()
                                                                    .length >
                                                                50,
                                                            child:
                                                                GestureDetector(
                                                              child: data[
                                                                      "is_expanded"]
                                                                  ? Text(
                                                                      "Show less",
                                                                      style: textTheme
                                                                          .caption
                                                                          .copyWith(
                                                                              color: themeColor.primaryColor),
                                                                    )
                                                                  : Text(
                                                                      "Show more",
                                                                      style: textTheme
                                                                          .caption
                                                                          .copyWith(
                                                                              color: themeColor.primaryColor)),
                                                              onTap: () {
                                                                setState(() {
                                                                  data["is_expanded"] =
                                                                      !data[
                                                                          "is_expanded"];
                                                                });
                                                              },
                                                            ))
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )),
                                    ),
                                  ),
                                );
                              }),
                        )),
                      ],
                    ),
                  ),
      ),
    );
  }
}
