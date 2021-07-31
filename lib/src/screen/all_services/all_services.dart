import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:home_services/src/widget/seller_drawer.dart';
import 'package:home_services/src/widget/service_grid_card.dart';

class AllServices extends StatefulWidget {
  final serviceTitle, userType, parentCategoryId;

  AllServices({this.serviceTitle, this.parentCategoryId, this.userType});

  @override
  _AllServicesState createState() => _AllServicesState();
}

class _AllServicesState extends State<AllServices> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  TextEditingController searchController = TextEditingController();
  List categoryList = [], searchList = [];
  String userType, serviceTitle;
  int parentId;
  bool isSearched = false, isLoading = true;

  @override
  void initState() {
    super.initState();
    parentId = widget.parentCategoryId;
    serviceTitle = widget.serviceTitle;
    userType = widget.userType;
    getChildCategory();
  }

  getChildCategory() {
    UserApiProvider.allSubCategories(parentId).then((value) {
      setState(() {
        isLoading = false;
      });
      if (value['result']) {
        categoryList = value['categories'];
      }
    });
  }

  searchQuery(query) {
    if (query.toString().length > 1) {
      var filterData = categoryList
          .where((e) => e['name'].toString().toLowerCase().contains(query))
          .toList();
      setState(() {
        isSearched = true;
        searchList = filterData;
      });
    } else if (query.toString().length == 0) {
      setState(() {
        isSearched = false;
        searchList = [];
      });
    }
  }

  listData(context, dataList) {
    return Expanded(
      child: isSearched && searchList.length == 0
          ? noDataFound(context)
          : GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: dataList.length,
              itemBuilder: (BuildContext context, int index) {
                return ServiceCard(dataList[index], userType);
              }),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      key: key,
      appBar: primaryAppBar(context, serviceTitle, key),
      extendBodyBehindAppBar: isLoading,
      drawer: userType == "buyer" ? BuyerDrawer() : SellerDrawer(),
      body: isLoading
          ? loadingData(context)
          : categoryList.length == 0
              ? noDataFound(context)
              : Container(
                  padding: EdgeInsets.only(
                      left: size.width * 0.04,
                      right: size.width * 0.04,
                      top: size.height * 0.03,
                      bottom: size.height * 0.01),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: size.height * 0.02),
                        width: size.width * 0.92,
                        child: TextFormField(
                          controller: searchController,
                          keyboardType: TextInputType.text,
                          onChanged: (text) => searchQuery(text),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: userType == "buyer"
                                  ? text_field_background_color
                                  : text_field_background_color_seller,
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
                      isSearched
                          ? listData(context, searchList)
                          : listData(context, categoryList)
                    ],
                  ),
                ),
    );
  }
}
