import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:timezone/standalone.dart' as tz;

class JobPost extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return JobPostState();
  }
}

class JobPostState extends State<JobPost> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  List jobs = [], jobCategories = [];
  bool isLoading = true,
      isJobTypeNull = false,
      isJobCategoryNull = false,
      isLocationError = false;
  int jobId, jobCategoryId;
  TextEditingController requestTitleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController videoFileController = TextEditingController();
  TextEditingController audioFileController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  DateTime selectedDate;
  TimeOfDay selectedTime;
  File videoFile, audioFile;
  Position currentPosition;

  @override
  void initState() {
    super.initState();
    getJobCategory();
    checkLocationPermission();
  }

  getJobCategory() {
    UserApiProvider.allCategories().then((value) {
      setState(() {
        jobs = value["categories"];
        isLoading = false;
      });
    });
  }

  checkLocationPermission() {
    getLocationPermission().then((value) async {
      currentPosition = value;
      final coordinates =
          new Coordinates(currentPosition.latitude, currentPosition.longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      locationController.text = '${addresses.first.addressLine}';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    var jamaica = tz.getLocation('America/Jamaica');
    var jamaicaCurrentTime = tz.TZDateTime.now(jamaica);
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: jamaicaCurrentTime,
        firstDate: jamaicaCurrentTime,
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dateController.text = selectedDate.toString().substring(0, 10);
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
        timeController.text = '${selectedTime.hour} : ${selectedTime.minute}';
      });
  }

  getVideoFile() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      videoFile = File(result.files.single.path);
      videoFileController.text = result.files.first.name;
    }
  }

  getAudioFile() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      audioFile = File(result.files.single.path);
      audioFileController.text = result.files.first.name;
    }
  }

  checkIsJobSelected() {
    if (jobId == null &&
            jobCategoryId == null &&
            locationController.text.trim() == "" ||
        locationController.text.isEmpty) {
      setState(() {
        isJobCategoryNull = true;
        isJobTypeNull = true;
        isLocationError = true;
      });
      return false;
    } else if (jobId == null) {
      setState(() {
        isJobTypeNull = true;
      });
      return false;
    } else if (jobCategoryId == null) {
      setState(() {
        isJobCategoryNull = true;
      });
      return false;
    } else if (locationController.text.trim() == "" ||
        locationController.text.isEmpty) {
      setState(() {
        isLocationError = true;
      });
      return false;
    } else {
      return true;
    }
  }

  postJob() {
    if (_formKey.currentState.validate()) {
      if (checkIsJobSelected()) {
        setState(() {
          isJobTypeNull = false;
          isLoading = true;
        });
        var time = DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, selectedTime.hour, selectedTime.minute);
        UserApiProvider.postJob(
                requestTitleController.text,
                descriptionController.text,
                double.parse(priceController.text),
                jobCategoryId,
                currentPosition.latitude,
                currentPosition.longitude,
                locationController.text,
                selectedDate,
                time,
                videoFile,
                audioFile)
            .then((value) {
          setState(() {
            isLoading = false;
          });
          if (value["result"]) {
            showMessage(context, "Job Post Successfully");
          } else {
            showAlertDialog(context, value["error"]);
          }
        });
      }
    } else {
      if (checkIsJobSelected()) {
        setState(() {
          isJobTypeNull = false;
        });
      }
    }
  }

  Future<void> showMessage(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message'),
          content: Container(
            child: Text(message),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  searchAddress(address) async {
    try {
      var addresses = await Geocoder.local.findAddressesFromQuery(address);
      return addresses.map((e) => e.addressLine).toList();
    } catch (e) {
      return List<String>.empty();
    }
  }

  selectSearchedAddress(address) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(address);
    setState(() {
      locationController.text = address;
      currentPosition = Position(
          latitude: addresses.first.coordinates.latitude,
          longitude: addresses.first.coordinates.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      key: key,
      drawer: BuyerDrawer(),
      appBar: primaryAppBar(context, "job_post", key),
      extendBodyBehindAppBar: isLoading,
      body: isLoading
          ? loadingData(context)
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Container(
                  width: size.width,
                  padding: EdgeInsets.only(
                      top: size.height * 0.015,
                      left: size.width * 0.06,
                      right: size.width * 0.06,
                      bottom: size.height * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.02),
                        child: TextFormField(
                            controller: requestTitleController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter request title";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: text_field_background_color,
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                hintText:
                                    getTranslated(context, 'request_title'),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.04))),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.02),
                        child: TextFormField(
                            controller: priceController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter price";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: text_field_background_color,
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                hintText: "Price",
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.04))),
                      ),
                      Container(
                        height: size.height * 0.06,
                        margin: EdgeInsets.only(top: size.height * 0.02),
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.04),
                        decoration: BoxDecoration(
                          color: text_field_background_color,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: grey_color),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            isDense: true,
                            isExpanded: true,
                            hint: Text(getTranslated(context, "job_type")),
                            value: jobId,
                            items: jobs
                                .map((value) => DropdownMenuItem(
                                      child: Text(value["name"]),
                                      value: value["id"],
                                    ))
                                .toList(),
                            onChanged: (newValue) {
                              UserApiProvider.allSubCategories(newValue)
                                  .then((value) {
                                setState(() {
                                  jobCategories = value['categories'];
                                  jobId = newValue;
                                });
                              });
                            },
                          ),
                        ),
                      ),
                      Visibility(
                          visible: isJobTypeNull,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.008,
                                horizontal: size.width * 0.04),
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Select Job",
                              style: textTheme.caption
                                  .copyWith(color: error_color),
                            ),
                          )),
                      Container(
                        height: size.height * 0.06,
                        margin: EdgeInsets.only(top: size.height * 0.02),
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.04),
                        decoration: BoxDecoration(
                          color: text_field_background_color,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: grey_color),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            isDense: true,
                            isExpanded: true,
                            hint: Text("Job Category"),
                            value: jobCategoryId,
                            items: jobCategories
                                .map((value) => DropdownMenuItem(
                                      child: Text(value["name"]),
                                      value: value["id"],
                                    ))
                                .toList(),
                            onChanged: (newValue) {
                              setState(() {
                                jobCategoryId = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      Visibility(
                          visible: isJobCategoryNull,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.008,
                                horizontal: size.width * 0.04),
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Select Job Category",
                              style: textTheme.caption
                                  .copyWith(color: error_color),
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.02),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter description";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: text_field_background_color,
                              suffixIconConstraints:
                                  BoxConstraints(maxHeight: 24, maxWidth: 44),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              hintText: getTranslated(context, 'description'),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04,
                                  vertical: size.height * 0.01)),
                          controller: descriptionController,
                          minLines: 6,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: size.width * 0.43,
                              child: TextFormField(
                                onTap: () {
                                  _selectDate(context);
                                },
                                readOnly: true,
                                controller: dateController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Enter work date";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: text_field_background_color,
                                    prefixIcon: Icon(Icons.date_range_outlined),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    hintText:
                                        getTranslated(context, 'work_date'),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.02)),
                              ),
                            ),
                            Container(
                              width: size.width * 0.43,
                              child: TextFormField(
                                onTap: () {
                                  _selectTime(context);
                                },
                                readOnly: true,
                                controller: timeController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Enter work time";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: text_field_background_color,
                                    prefixIcon:
                                        Icon(Icons.access_time_outlined),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    hintText:
                                        getTranslated(context, 'work_time'),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.02)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.02),
                        child: TextFormField(
                          onTap: () {
                            getVideoFile();
                          },
                          readOnly: true,
                          controller: videoFileController,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: text_field_background_color,
                              suffixIcon: Icon(Icons.ondemand_video_outlined),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              hintText: getTranslated(context, 'upload_video'),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04)),
                        ),
                      ),
                      Container(
                        height: size.height * 0.06,
                        margin: EdgeInsets.only(top: size.height * 0.02),
                        child: TextFormField(
                          onTap: () {
                            getAudioFile();
                          },
                          readOnly: true,
                          controller: audioFileController,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: text_field_background_color,
                              suffixIcon: Icon(Icons.audiotrack_outlined),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              hintText: getTranslated(context, 'upload_audio'),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.02),
                        child: TypeAheadField(
                          noItemsFoundBuilder: (context) {
                            return ListTile(
                              title: Text("No Data Found!"),
                            );
                          },
                          getImmediateSuggestions: true,
                          hideOnEmpty: true,
                          textFieldConfiguration: TextFieldConfiguration(
                              controller: locationController,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: text_field_background_color,
                                  suffixIcon: Icon(Icons.location_on_outlined),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  hintText: getTranslated(
                                      context, 'set_service_location'),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.04))),
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
                        )
                        /* TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter location";
                            }
                            return null;
                          },
                          controller: locationController,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: text_field_background_color,
                              suffixIcon: Icon(Icons.location_on_outlined),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              hintText: getTranslated(
                                  context, 'set_service_location'),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04)),
                        ) */
                        ,
                      ),
                      Visibility(
                          visible: isLocationError,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.008,
                                horizontal: size.width * 0.04),
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Enter Proper Address",
                              style: textTheme.caption
                                  .copyWith(color: error_color),
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.04),
                        width: size.width * 0.9,
                        height: size.height * 0.06,
                        child: RaisedButton(
                          textColor: primary_font,
                          child: Text(
                            getTranslated(context, "post_job"),
                            textAlign: TextAlign.center,
                          ),
                          onPressed: () {
                            postJob();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
