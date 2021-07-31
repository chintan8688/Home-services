import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/job_bid/job_bid.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:home_services/src/widget/seller_drawer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FindJobs extends StatefulWidget {
  final category;

  FindJobs({this.category});

  @override
  State<StatefulWidget> createState() {
    return FindJobsState();
  }
}

class FindJobsState extends State<FindJobs> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  TextEditingController searchController = TextEditingController();
  List jobList = [], searchList = [];
  bool isLoading = true, isSearched = false;
  var category;

  @override
  void initState() {
    super.initState();
    category = widget.category;
    findJobs();
  }

  findJobs() {
    getLocationPermission().then((position) {
      UserApiProvider.findJobs(
              position.latitude, position.longitude, category['id'], 15)
          .then((value) {
        if (mounted) {
          setState(() {
            jobList = value['jobs'];
            isLoading = false;
          });
        }
      });
    });
  }

  searchQuery(query) {
    if (query.toString().length > 2) {
      var filterData = jobList
          .where((e) =>
              e['name'].toString().toLowerCase().contains(query) ||
              e['title'].toString().toLowerCase().contains(query) ||
              e['description'].toString().toLowerCase().contains(query) ||
              e['work_date'].toString().toLowerCase().contains(query) ||
              e['work_time'].toString().toLowerCase().contains(query) ||
              e['price'].toString().contains(query))
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

  filterData(type) {
    if (type == "new") {
      setState(() {
        jobList.sort((a, b) {
          DateTime adate = DateTime.parse(a['work_date']);
          DateTime bdate = DateTime.parse(b['work_date']);
          return bdate.compareTo(adate);
        });
      });
    } else {
      setState(() {
        jobList.sort((a, b) {
          DateTime adate = DateTime.parse(a['work_date']);
          DateTime bdate = DateTime.parse(b['work_date']);
          return adate.compareTo(bdate);
        });
      });
    }
  }

  listData(context, result) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    return ListView.builder(
        itemCount: result.length,
        itemBuilder: (context, index) {
          var job = result[index];
          return Container(
            margin: EdgeInsets.only(bottom: size.height * 0.01),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            JobBid(job: job, category: category)));
              },
              child: Card(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.03),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: size.width * 0.8,
                              child: Row(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl:
                                        Constant.STORAGE_PATH + job['avatar'],
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
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.05),
                                    width: size.width * 0.64,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                              bottom: size.height * 0.01),
                                          child: Text(
                                            '${job["name"]}',
                                            style: textTheme.subtitle2.copyWith(
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            job['title'],
                                            style: textTheme.subtitle2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
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
                                  category['name'],
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
                                  job['work_date'],
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
                                  job['price'].toString(),
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
                                  job['work_time'],
                                  style: textTheme.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: themeColor.primaryColor),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.02),
                                margin: EdgeInsets.only(
                                  right: size.width * 0.05,
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.03,
                                      vertical: size.height * 0.007),
                                  decoration: BoxDecoration(
                                      color: themeColor.primaryColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0))),
                                  child: Text(
                                    "Place Bid",
                                    style: textTheme.caption
                                        .copyWith(color: primary_font),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
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
        appBar: primaryAppBar(context, "Jobs near you", key),
        drawer: SellerDrawer(),
        extendBodyBehindAppBar: isLoading,
        body: isLoading
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
                                  fillColor: text_field_background_color_seller,
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
                        Container(
                          width: size.width,
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.01),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              PopupMenuButton(
                                child: Container(
                                    child: Row(
                                  children: [
                                    Text(
                                      "Sort",
                                      style: textTheme.subtitle2,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * 0.03),
                                      child: Image.asset(
                                          "assets/icons/icon-sort.png",
                                          width: size.width * 0.06),
                                    )
                                  ],
                                )),
                                onSelected: (result) {
                                  filterData(result);
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry>[
                                  PopupMenuItem(
                                    value: "new",
                                    child: Text('Newest'),
                                  ),
                                  PopupMenuItem(
                                    value: "old",
                                    child: Text('Oldest'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: size.width,
                            color: primary_font,
                            child: !isSearched
                                ? listData(context, jobList)
                                : listData(context, searchList),
                          ),
                        ),
                      ],
                    ),
                  ));
  }
}
