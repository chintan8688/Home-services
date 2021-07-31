import 'dart:async';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/job_post/job_post.dart';
import 'package:home_services/src/screen/worker_profile/worker_profile.dart';
import 'package:home_services/src/screen/workers_list/workers_list.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';

class WorkersLocation extends StatefulWidget {
  final headerTitle, category;

  WorkersLocation({Key key, @required this.headerTitle, this.category})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WorkersLocationState();
  }
}

class WorkersLocationState extends State<WorkersLocation> {
  CameraPosition mapcenter = CameraPosition(
    target: LatLng(18.1096, 77.2975),
    zoom: 15.0,
  );
  Completer<GoogleMapController> _controller = Completer();
  Position currentPosition;
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  GlobalKey<ScaffoldState> key = GlobalKey();
  TextEditingController addressController = TextEditingController();

  List professionals = [];
  Set markers;
  BitmapDescriptor markerIcon;

  @override
  void initState() {
    super.initState();
    setMarkerIcon();
    checkLocationPermission();
  }

  @override
  void dispose() {
    super.dispose();
    _customInfoWindowController.dispose();
  }

  setMarkerIcon() async {
    markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1.0),
        "assets/icons/icon-marker-buyer.png");
  }

  checkLocationPermission() {
    getLocationPermission().then((value) {
      setState(() {
        currentPosition = value;
      });
      findWorkers();
    });
  }

  findWorkers() {
    UserApiProvider.findProfessional(currentPosition.latitude,
            currentPosition.longitude, widget.category['id'], 15)
        .then((value) {
      if (value['result']) {
        setState(() {
          professionals = value['professionals'];
        });
        setMapView(value['professionals']);
      }
    });
  }

  setMapView(userData) async {
    try {
      final coordinates =
          new Coordinates(currentPosition.latitude, currentPosition.longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      GoogleMapController controller = await _controller.future;
      controller.moveCamera(CameraUpdate.newLatLngZoom(
          LatLng(coordinates.latitude, coordinates.longitude), 15.0));
      if (mounted) {
        setState(() {
          addressController.text = '${addresses.first.addressLine}';
        });
        loadMarkers(userData);
      }
    } catch (e) {
      print(e);
    }
  }

  loadMarkers(userData) {
    var data = (userData as List)
        .map((e) => Marker(
            markerId: MarkerId(e['id'].toString()),
            position: LatLng(e['latitude'], e['longitude']),
            icon: markerIcon,
            onTap: () {
              _customInfoWindowController.addInfoWindow(
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WorkerProfile(
                                  professional: e,
                                  category: widget.category,
                                  jobId: 0,
                                  scheduledJob: false,
                                  fromFavourite: false,
                                  fromBids: false,
                                )));
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: button_secondary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(e['name'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2
                                            .copyWith(color: primary_font)),
                                    Container(
                                      padding: EdgeInsets.only(left: 5),
                                      child: GFRating(
                                          size: 14,
                                          color: primary_font,
                                          borderColor: primary_font,
                                          value: e['rating']
                                                      ['average_rating'] !=
                                                  null
                                              ? double.parse(e['rating']
                                                      ['average_rating']
                                                  .toString())
                                              : 0.0),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text(
                                          '(${e['rating']['rating_count'].toString()})',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2
                                              .copyWith(color: primary_font)),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 8.0,
                                ),
                                Text(
                                    e['address'].toString().length > 80
                                        ? e['address']
                                                .toString()
                                                .substring(0, 80) +
                                            "..."
                                        : e['address'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        .copyWith(color: primary_font)),
                                SizedBox(
                                  height: 8.0,
                                ),
                                Text("View Details",
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        .copyWith(color: primary_font)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                LatLng(e['latitude'], e['longitude']),
              );
            }))
        .toSet();
    setState(() {
      markers = data;
    });
  }

  searchAddress(address) async {
    try {
      var addresses = await Geocoder.local.findAddressesFromQuery(address);
      return addresses.map((e) => e.addressLine).toList();
    } catch (e) {
      return List<String>.empty();
    }
    /* try {
      var addresses =
          await Geocoder.local.findAddressesFromQuery(addressController.text);
      if (addresses.length > 0) {
        setState(() {
          currentPosition = Position(
              latitude: addresses.first.coordinates.latitude,
              longitude: addresses.first.coordinates.longitude);
        });
        GoogleMapController controller = await _controller.future;
        controller.moveCamera(CameraUpdate.newLatLngZoom(
            LatLng(currentPosition.latitude, currentPosition.longitude), 15.0));
        findWorkers();
      }
    } catch (e) {
      print(e);
    } */
  }

  selectSearchedAddress(address) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(address);
    setState(() {
      addressController.text = address;
      currentPosition = Position(
          latitude: addresses.first.coordinates.latitude,
          longitude: addresses.first.coordinates.longitude);
    });
    GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newLatLngZoom(
        LatLng(currentPosition.latitude, currentPosition.longitude), 15.0));
    findWorkers();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    return Scaffold(
        key: key,
        drawer: BuyerDrawer(),
        appBar: primaryAppBar(context, widget.headerTitle, key),
        extendBodyBehindAppBar: true,
        body: Container(
          height: size.height,
          width: size.width,
          child: Stack(
            children: [
              Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: mapcenter,
                    markers: markers,
                    myLocationEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      _customInfoWindowController.googleMapController =
                          controller;
                    },
                    onTap: (position) {
                      _customInfoWindowController.hideInfoWindow();
                    },
                    onCameraMove: (position) {
                      _customInfoWindowController.onCameraMove();
                    },
                  ),
                  CustomInfoWindow(
                    controller: _customInfoWindowController,
                    height: size.height * 0.15,
                    width: size.width * 0.8,
                    offset: 100,
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(size.height * 0.03),
                    margin: EdgeInsets.only(top: size.height * 0.1),
                    child: Container(
                      child: Material(
                        borderRadius: BorderRadius.all(
                          Radius.circular(35.0),
                        ),
                        shadowColor: Colors.grey,
                        elevation: 8,
                        child: TypeAheadField(
                          noItemsFoundBuilder: (context) {
                            return ListTile(
                              title: Text("No Data Found!"),
                            );
                          },
                          getImmediateSuggestions: true,
                          textFieldConfiguration: TextFieldConfiguration(
                              controller: addressController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(35.0),
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: primary_font,
                                  hintText: getTranslated(
                                      context, "set_up_your_service_location"),
                                  contentPadding:
                                      EdgeInsets.all(size.height * 0.015),
                                  suffixIcon: IconButton(
                                    icon: SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: Image.asset(
                                        "assets/icons/icon-search.png",
                                      ),
                                    ),
                                    onPressed: () {},
                                  ))),
                          suggestionsCallback: (address) async {
                            return await searchAddress(address);
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              dense: true,
                              title: Text(suggestion),
                            );
                          },
                          onSuggestionSelected: (suggestion) async {
                            selectSearchedAddress(suggestion);
                          },
                        ),
                      ),
                    )
                    /* TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(35.0),
                              ),
                            ),
                            filled: true,
                            fillColor: primary_font,
                            hintText: getTranslated(
                                context, "set_up_your_service_location"),
                            contentPadding: EdgeInsets.all(size.height * 0.015),
                            suffixIcon: IconButton(
                                icon: SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: Image.asset(
                                    "assets/icons/icon-search.png",
                                  ),
                                ),
                                onPressed: () {
                                  searchAddress();
                                })),
                      ) */
                    ,
                  ),
                  Padding(
                    padding: EdgeInsets.all(size.height * 0.03),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: size.width * 0.8,
                          height: size.height * 0.06,
                          child: RaisedButton(
                            color: themeColor.primaryColor,
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.005),
                            textColor: primary_font,
                            child: Text(
                              getTranslated(context, "request_service_now"),
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      WorkersList(
                                          headerTitle: widget.headerTitle,
                                          category: widget.category)));
                            },
                          ),
                        ),
                        Container(
                          width: size.width * 0.8,
                          height: size.height * 0.06,
                          margin: EdgeInsets.only(top: size.height * 0.01),
                          child: RaisedButton(
                            color: button_secondary,
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.005),
                            textColor: primary_font,
                            child: Text(
                              getTranslated(context, "schedule_service"),
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      JobPost()));
                            },
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }
}
