import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/screen/all_services/all_services.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:home_services/src/widget/seller_drawer.dart';

class AllCategories extends StatefulWidget {
  final userType, services;

  AllCategories({this.services, this.userType});

  @override
  _AllCategoriesState createState() => _AllCategoriesState();
}

class _AllCategoriesState extends State<AllCategories> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  TextEditingController searchController = TextEditingController();
  List serviceList = [], searchList = [];
  String userType;

  bool isSearched = false;

  @override
  void initState() {
    super.initState();
    serviceList = widget.services;
    userType = widget.userType;
  }

  searchQuery(query) {
    if (query.toString().length > 1) {
      var filterData = serviceList
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

  navigateToChildCategories(context, category) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AllServices(
                  parentCategoryId: category['id'],
                  serviceTitle: category['name'],
                  userType: userType,
                )));
  }

  listData(context, dataList) {
    var size = MediaQuery.of(context).size;
    return Expanded(
      child: isSearched && searchList.length == 0
          ? noDataFound(context)
          : ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                var category = dataList[index];
                return Container(
                  margin: EdgeInsets.only(bottom: size.height * 0.01),
                  child: GestureDetector(
                    onTap: () {
                      navigateToChildCategories(context, category);
                    },
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.all(size.height * 0.009),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            category["icon"] == null
                                ? Container(
                                    width: size.width * 0.15,
                                    height: size.width * 0.15,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      category["name"],
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : Container(
                                    width: size.width * 0.15,
                                    height: size.width * 0.15,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: ImageIcon(
                                      NetworkImage(Constant.STORAGE_PATH +
                                          category["icon"]),
                                      color: userType == "seller"
                                          ? accent_color_seller
                                          : button_secondary,
                                    ),
                                  ),
                            Container(
                                width: size.width * 0.65,
                                padding:
                                    EdgeInsets.only(left: size.width * 0.015),
                                child: Text(category['name'])),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      key: key,
      appBar: primaryAppBar(context, "Services", key),
      drawer: userType == "buyer" ? BuyerDrawer() : SellerDrawer(),
      body: Container(
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
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    hintText: "Search...",
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.04)),
              ),
            ),
            isSearched
                ? listData(context, searchList)
                : listData(context, serviceList)
          ],
        ),
      ),
    );
  }
}
