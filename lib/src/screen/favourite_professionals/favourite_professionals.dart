import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/worker_profile/worker_profile.dart';
import 'package:home_services/src/screen/worker_service_detail/worker_service_detail.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';

class FavouriteWorkersList extends StatefulWidget {
  /* final headerTitle, category;

  FavouriteWorkersList(
      {Key key, @required this.headerTitle, @required this.category})
      : super(key: key); */

  @override
  State<StatefulWidget> createState() {
    return FavouriteWorkersListState();
  }
}

class FavouriteWorkersListState extends State<FavouriteWorkersList> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  TextEditingController searchController = TextEditingController();
  List professionals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getFavourites();
  }

  getFavourites() {
    UserApiProvider.favouriteProfessionals().then((value) {
      if (value['result']) {
        setState(() {
          professionals = value['favorite_professionals'];
          isLoading = false;
        });
      }
    });
  }

  removeFavourite(id) {
    UserApiProvider.removeFavourite(id);
  }

  navigateToProfile(context, professional) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WorkerProfile(
                  professional: professional,
                  category: professional['services'][0]['category'],
                  scheduledJob: false,
                  jobId: 0,
                  fromFavourite: true,
                  services: professional['services'],
                  fromBids: false,
                )));
  }

  navigateToServiceDetail(context, professional, type) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WorkerServiceDetail(
                  professional: professional,
                  type: type,
                  category: professional['services'][0]['category'],
                  scheduledJob: false,
                  jobId: 0,
                  fromFavourite: true,
                  services: professional['services'],
                  fromBids: false,
                )));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    return Scaffold(
      key: key,
      drawer: BuyerDrawer(),
      appBar: primaryAppBar(context, "Favourite Professionals", key),
      extendBodyBehindAppBar: isLoading,
      body: Center(
        child: isLoading
            ? loadingData(context)
            : professionals.length == 0
                ? noDataFound(context)
                : Container(
                    width: size.width,
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.02),
                    child: Column(
                      children: [
                        Expanded(
                            child: Container(
                          width: size.width,
                          color: primary_font,
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.02),
                          child: ListView.builder(
                              itemCount: professionals.length,
                              itemBuilder: (context, index) {
                                var data = professionals[index];

                                return Container(
                                  margin: EdgeInsets.only(
                                      bottom: size.height * 0.01),
                                  child: Card(
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(size.height * 0.009),
                                      child: GestureDetector(
                                        onTap: () {
                                          navigateToProfile(context, data);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl: Constant.STORAGE_PATH +
                                                  data['avatar'],
                                              imageBuilder:
                                                  (context, imageProvider) =>
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
                                              width: size.width * 0.74,
                                              padding: EdgeInsets.only(
                                                  left: size.width * 0.015),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                                                data["name"],
                                                                style: textTheme
                                                                    .subtitle1
                                                                    .copyWith(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                              ),
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: size
                                                                              .width *
                                                                          0.02),
                                                              child: GFRating(
                                                                value: data["rating"]
                                                                            [
                                                                            'average_rating'] !=
                                                                        null
                                                                    ? double.parse(data["rating"]
                                                                            [
                                                                            'average_rating']
                                                                        .toString())
                                                                    : 0.0,
                                                                size: 16.0,
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
                                                            removeFavourite(data[
                                                                'professional_id']);
                                                            setState(() {
                                                              professionals
                                                                  .removeAt(
                                                                      index);
                                                            });
                                                          },
                                                          child: Icon(
                                                            Icons.favorite,
                                                            color: themeColor
                                                                .primaryColor,
                                                            size: 14,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical:
                                                                size.height *
                                                                    0.005),
                                                    child: Text(
                                                        data['service_title']),
                                                  ),
                                                  Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical:
                                                                  size.height *
                                                                      0.005),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children:
                                                            data['packages']
                                                                .map<Widget>(
                                                                  (e) =>
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      navigateToServiceDetail(
                                                                          context,
                                                                          data,
                                                                          e['name']);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              2),
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                              text_field_background_color,
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(20))),
                                                                      child:
                                                                          Text(
                                                                        e['name'] ==
                                                                                "Basic"
                                                                            ? "JMD${e['price']} Basic"
                                                                            : e['name'] == 'Standard'
                                                                                ? "JMD${e['price']} Standard"
                                                                                : "JMD${e['price']} Premium",
                                                                        style: textTheme
                                                                            .caption,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                                .toList(),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
