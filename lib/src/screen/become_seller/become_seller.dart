import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/service_menu/service_menu.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';

class BecomeSeller extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BecomeSellerState();
  }
}

class BecomeSellerState extends State<BecomeSeller> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  final _skillForm = GlobalKey<FormState>();
  final _educationForm = GlobalKey<FormState>();
  final _packageForm = GlobalKey<FormState>();
  final _packageDetailForm = GlobalKey<FormState>();
  final _policeRecordForm = GlobalKey<FormState>();
  bool isLoading = true,
      serviceTitleError = false,
      jobTypeError = false,
      jobCategoryError = false,
      lanError = false,
      lanLevelError = false,
      skillExperienceError = false,
      skillLevelError = false,
      eduDegreeError = false,
      isSwitched = false,
      isDocumentNull = false,
      isIdNull = false,
      isFinished = false,
      skillListError = false,
      educationListError = false,
      languageListError = false,
      stepOneCompleted = false,
      stepTwoCompleted = false,
      stepThreeCompleted = false,
      stepFourCompleted = false,
      stepFiveCompleted = false,
      isLocationError = false,
      workImageserror = false;

  File documentPicture, policeRecordProof, billProof;
  int _index = 1, selectedJobTypeId, selectedCategoryId;
  String selectedSkillExperience,
      selectedSkillCategory,
      selectedSkillLevel,
      selectedDegree,
      selectedLanguage,
      selectedLanguageLevel;

  List skills = [],
      educations = [],
      languages = [],
      jobs = [],
      jobCategories = [],
      previousWorkImages = [],
      previousWorkVideos = [],
      videoThumbnails = [];
  Position currentPosition;

  List<String> skillExperienceList = [
    "<2 Years",
    "2.5 - 5 Years",
    ">5 Years",
  ];

  List<String> skillLevelList = [
    "Beginner",
    "Intermediate",
    "Pro",
  ];

  List<String> degreeList = [
    "UG",
    "PG",
  ];

  List<String> languageList = [
    "English",
    "Arabic",
    "Urdu",
  ];
  List<String> languageLevelList = [
    "Native",
    "Basic",
    "Fluent",
  ];

  TextEditingController serviceTitleController = new TextEditingController();
  TextEditingController skillTypeController = new TextEditingController();
  TextEditingController courseTypeController = new TextEditingController();
  TextEditingController passingYearController = new TextEditingController();
  TextEditingController basicDescriptionController =
      new TextEditingController();
  TextEditingController basicPriceController = new TextEditingController();
  TextEditingController basicAdditionalPriceController =
      new TextEditingController();
  TextEditingController standardDescriptionController =
      new TextEditingController();
  TextEditingController standardPriceController = new TextEditingController();
  TextEditingController standardAdditionalPriceController =
      new TextEditingController();
  TextEditingController premiumDescriptionController =
      new TextEditingController();
  TextEditingController premiumPriceController = new TextEditingController();
  TextEditingController premiumAdditionalPriceController =
      new TextEditingController();
  TextEditingController serviceDescriptionController =
      new TextEditingController();
  TextEditingController serviceLocationController = new TextEditingController();
  TextEditingController documentIdController = new TextEditingController();
  TextEditingController justiceOfPeaceController = new TextEditingController();
  TextEditingController personOneController = new TextEditingController();
  TextEditingController personTwoController = new TextEditingController();
  TextEditingController policeRecordIdController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getJobCategory();
  }

  getJobCategory() {
    UserApiProvider.checkBecomeSellerRequest().then((res) {
      if (res['result']) {
        UserApiProvider.allCategories().then((value) {
          setState(() {
            jobs = value["categories"];
            isLoading = false;
          });
        });
      } else {
        showMessage(context, res['message']);
      }
    });
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

  checkLocationPermission() {
    getLocationPermission().then((value) async {
      currentPosition = value;
      final coordinates =
          new Coordinates(currentPosition.latitude, currentPosition.longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      serviceLocationController.text = "";
      serviceLocationController.text = '${addresses.first.addressLine}';
    });
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
      serviceLocationController.text = address;
      currentPosition = Position(
          latitude: addresses.first.coordinates.latitude,
          longitude: addresses.first.coordinates.longitude);
    });
  }

  onSubmitServiceDescription() async {
    if (_packageDetailForm.currentState.validate()) {
      if (serviceLocationController.text.trim() == "" ||
          serviceLocationController.text.isEmpty) {
        setState(() {
          isLocationError = true;
        });
      } else {
        var addresses = await Geocoder.local
            .findAddressesFromQuery(serviceLocationController.text);
        setState(() {
          serviceLocationController.text = "";
          serviceLocationController.text = addresses.first.addressLine;
          currentPosition = Position(
              latitude: addresses.first.coordinates.latitude,
              longitude: addresses.first.coordinates.longitude);
          _index = 4;
          stepThreeCompleted = true;
          isLocationError = false;
        });
      }
    } else {
      if (serviceLocationController.text.trim() == "" ||
          serviceLocationController.text.isEmpty) {
        setState(() {
          isLocationError = true;
        });
      }
    }
  }

  submitUserData() {
    List packages = [
      {
        "name": "Basic",
        "price": double.parse(basicPriceController.text.trim()),
        "additional_price":
            double.parse(basicAdditionalPriceController.text.trim()),
        "description": basicDescriptionController.text.trim(),
        "type": "Hourly"
      },
      {
        "name": "Standard",
        "price": double.parse(standardPriceController.text.trim()),
        "additional_price":
            double.parse(standardAdditionalPriceController.text.trim()),
        "description": standardDescriptionController.text.trim(),
        "type": "Hourly"
      },
      {
        "name": "Premium",
        "price": double.parse(premiumPriceController.text.trim()),
        "additional_price":
            double.parse(premiumAdditionalPriceController.text.trim()),
        "description": premiumDescriptionController.text.trim(),
        "type": "Hourly"
      }
    ];

    setState(() {
      isLoading = true;
    });

    UserApiProvider.becomeSeller(
            serviceTitleController.text.trim(),
            serviceDescriptionController.text.trim(),
            selectedCategoryId,
            documentIdController.text.trim(),
            serviceLocationController.text.trim(),
            currentPosition.latitude,
            currentPosition.longitude,
            documentPicture,
            skills,
            educations,
            languages,
            packages,
            previousWorkImages,
            previousWorkVideos,
            policeRecordIdController.text.trim(),
            policeRecordProof,
            policeRecordProof != null
                ? path.extension(policeRecordProof.path)
                : "",
            billProof,
            billProof != null ? path.extension(billProof.path) : "",
            justiceOfPeaceController.text.trim(),
            personOneController.text.trim(),
            personTwoController.text.trim())
        .then((value) {
      setState(() {
        isLoading = false;
      });
      if (value["result"]) {
        setState(() {
          isFinished = true;
        });
      }
    });
  }

  getPoliceRecordProof(type) async {
    final pickedData = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'pdf', 'doc']);

    if (pickedData != null) {
      if (type == "record") {
        setState(() {
          policeRecordProof = File(pickedData.files.single.path);
        });
      } else {
        setState(() {
          billProof = File(pickedData.files.single.path);
        });
      }
    }
  }

  getWorkImages() async {
    final pickedImages = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);
    if (pickedImages != null) {
      var images = pickedImages.files.map((e) => File(e.path)).toList();
      setState(() {
        previousWorkImages.addAll(images);
      });
    }
  }

  getWorkVideos() async {
    final pickedVideos = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.video);

    if (pickedVideos != null) {
      var videos = pickedVideos.files.map((e) => File(e.path)).toList();
      var data = [];

      for (var i = 0; i < videos.length; i++) {
        Uint8List bytes = await VideoThumbnail.thumbnailData(
          video: videos[i].path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 150,
          quality: 25,
        );
        data.add(bytes);
      }
      setState(() {
        previousWorkVideos.addAll(videos);
        videoThumbnails.addAll(data);
      });
    }
  }

  SimpleDialog selectPictureDialog() {
    return SimpleDialog(
      title: Text(
        getTranslated(context, "select_from"),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline6,
      ),
      children: [
        SimpleDialogOption(
          onPressed: () {
            Navigator.of(context).pop();
            getPictureFromCamera();
          },
          child: Text(
            getTranslated(context, "camera"),
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.of(context).pop();
            getPictureFromGallery();
          },
          child: Text(
            getTranslated(context, "gallery"),
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            getTranslated(context, "cancel"),
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      ],
    );
  }

  getPictureFromCamera() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        documentPicture = File(pickedFile.path);
      });
    }
  }

  getPictureFromGallery() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        documentPicture = File(pickedFile.path);
      });
    }
  }

  Dialog addSkillDialog() {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Form(
            key: _skillForm,
            child: Container(
              height: size.height * 0.4,
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
                          "Add New Skill",
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
                                controller: skillTypeController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Enter Skill";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: stepper_background,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    hintText: "Enter Skill",
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.04))),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.04),
                            child: Container(
                              height: size.height * 0.06,
                              margin: EdgeInsets.only(top: size.height * 0.02),
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04),
                              decoration: BoxDecoration(
                                color: stepper_background,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: grey_color),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  isDense: true,
                                  isExpanded: true,
                                  hint: Text("Select Experience"),
                                  value: selectedSkillExperience,
                                  items: skillExperienceList
                                      .map((value) => DropdownMenuItem(
                                            child: Text(value),
                                            value: value,
                                          ))
                                      .toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedSkillExperience = newValue;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                              visible: skillExperienceError,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.008,
                                    horizontal: size.width * 0.08),
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Select Experience",
                                  style: textTheme.caption
                                      .copyWith(color: error_color),
                                ),
                              )),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.04),
                            child: Container(
                              height: size.height * 0.06,
                              margin: EdgeInsets.only(top: size.height * 0.02),
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04),
                              decoration: BoxDecoration(
                                color: stepper_background,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: grey_color),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  isDense: true,
                                  isExpanded: true,
                                  hint: Text("Select Level"),
                                  value: selectedSkillLevel,
                                  items: skillLevelList
                                      .map((value) => DropdownMenuItem(
                                            child: Text(value),
                                            value: value,
                                          ))
                                      .toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedSkillLevel = newValue;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                              visible: skillLevelError,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.008,
                                    horizontal: size.width * 0.08),
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Select Level",
                                  style: textTheme.caption
                                      .copyWith(color: error_color),
                                ),
                              )),
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            child: RaisedButton(
                              child: Text(
                                "Save Skill",
                              ),
                              textColor: primary_font,
                              onPressed: () {
                                if (_skillForm.currentState.validate()) {
                                  if (selectedSkillLevel == null) {
                                    setState(() {
                                      skillLevelError = true;
                                    });
                                  } else if (selectedSkillExperience == null) {
                                    setState(() {
                                      skillExperienceError = true;
                                    });
                                  } else {
                                    var obj = {
                                      "name": skillTypeController.text,
                                      "experience": selectedSkillExperience,
                                      "level": selectedSkillLevel
                                    };
                                    setState(() {
                                      skillTypeController.text = "";
                                      selectedSkillLevel = null;
                                      selectedSkillExperience = null;
                                      skillExperienceError = false;
                                      skillLevelError = false;
                                    });
                                    Navigator.pop(context, obj);
                                  }
                                } else {
                                  if (selectedSkillLevel == null) {
                                    setState(() {
                                      skillLevelError = true;
                                    });
                                  } else if (selectedSkillExperience == null) {
                                    setState(() {
                                      skillExperienceError = true;
                                    });
                                  }
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

  Dialog addEducationDialog() {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Form(
              key: _educationForm,
              child: Container(
                height: size.height * 0.4,
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
                            "Add New Education",
                            textAlign: TextAlign.center,
                            style: textTheme.headline6
                                .copyWith(color: primary_font),
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
                                  controller: courseTypeController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter course type";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor: stepper_background,
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      hintText: "Course Type",
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: size.width * 0.04))),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04),
                              child: Container(
                                height: size.height * 0.06,
                                margin:
                                    EdgeInsets.only(top: size.height * 0.02),
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.04),
                                decoration: BoxDecoration(
                                  color: stepper_background,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: grey_color),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    isDense: true,
                                    isExpanded: true,
                                    hint: Text("Select Degree"),
                                    value: selectedDegree,
                                    items: degreeList
                                        .map((value) => DropdownMenuItem(
                                              child: Text(value),
                                              value: value,
                                            ))
                                        .toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedDegree = newValue;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                                visible: eduDegreeError,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.008,
                                      horizontal: size.width * 0.08),
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Select Level",
                                    style: textTheme.caption
                                        .copyWith(color: error_color),
                                  ),
                                )),
                            Container(
                              margin: EdgeInsets.only(top: size.height * 0.02),
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04),
                              child: TextFormField(
                                  controller: passingYearController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter passing year";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor: stepper_background,
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      hintText: "Passing Year",
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: size.width * 0.04))),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: size.height * 0.02),
                              child: RaisedButton(
                                child: Text(
                                  "Save Education",
                                ),
                                textColor: primary_font,
                                onPressed: () {
                                  if (_educationForm.currentState.validate()) {
                                    if (selectedDegree == null) {
                                      setState(() {
                                        eduDegreeError = true;
                                      });
                                    } else {
                                      var obj = {
                                        "degree": selectedDegree,
                                        "course": courseTypeController.text,
                                        "passing_year":
                                            passingYearController.text
                                      };
                                      setState(() {
                                        courseTypeController.text = "";
                                        selectedDegree = null;
                                        passingYearController.text = "";
                                        eduDegreeError = false;
                                      });
                                      Navigator.pop(context, obj);
                                    }
                                  } else {
                                    if (selectedDegree == null) {
                                      setState(() {
                                        eduDegreeError = true;
                                      });
                                    }
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
              ));
        },
      ),
    );
  }

  Dialog addLanguagesDialog() {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: size.height * 0.4,
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
                        "Add New Language",
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
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04),
                          child: Container(
                            height: size.height * 0.06,
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.04),
                            decoration: BoxDecoration(
                              color: stepper_background,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: grey_color),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                isDense: true,
                                isExpanded: true,
                                hint: Text("Select Language"),
                                value: selectedLanguage,
                                items: languageList
                                    .map((value) => DropdownMenuItem(
                                          child: Text(value),
                                          value: value,
                                        ))
                                    .toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedLanguage = newValue;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                            visible: lanError,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.008,
                                  horizontal: size.width * 0.08),
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Select Level",
                                style: textTheme.caption
                                    .copyWith(color: error_color),
                              ),
                            )),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04),
                          child: Container(
                            height: size.height * 0.06,
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.04),
                            decoration: BoxDecoration(
                              color: stepper_background,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: grey_color),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                isDense: true,
                                isExpanded: true,
                                hint: Text("Select Level"),
                                value: selectedLanguageLevel,
                                items: languageLevelList
                                    .map((value) => DropdownMenuItem(
                                          child: Text(value),
                                          value: value,
                                        ))
                                    .toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedLanguageLevel = newValue;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                            visible: lanLevelError,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.008,
                                  horizontal: size.width * 0.08),
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Select Level",
                                style: textTheme.caption
                                    .copyWith(color: error_color),
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(top: size.height * 0.02),
                          child: RaisedButton(
                            child: Text(
                              "Save Language",
                            ),
                            textColor: primary_font,
                            onPressed: () {
                              if ((selectedLanguage == null) &&
                                  (selectedLanguageLevel == null)) {
                                setState(() {
                                  lanError = true;
                                  lanLevelError = true;
                                });
                              } else if (selectedLanguage == null) {
                                setState(() {
                                  lanError = true;
                                });
                              } else if (selectedLanguageLevel == null) {
                                setState(() {
                                  lanLevelError = true;
                                });
                              } else {
                                var obj = {
                                  "language": selectedLanguage,
                                  "level": selectedLanguageLevel,
                                };
                                setState(() {
                                  selectedLanguage = null;
                                  selectedLanguageLevel = null;
                                  lanError = false;
                                  lanLevelError = false;
                                });
                                Navigator.pop(context, obj);
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
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
        key: key,
        drawer: BuyerDrawer(),
        appBar: primaryAppBar(context, "become_a_seller", key),
        extendBodyBehindAppBar: true,
        body: isLoading
            ? loadingData(context)
            : Container(
                width: size.width,
                height: size.height,
                margin: EdgeInsets.only(top: size.height * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      color: stepper_background,
                      height: size.height * 0.20,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          margin: EdgeInsets.only(top: size.height * 0.06),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (stepOneCompleted) {
                                    setState(() {
                                      _index = 1;
                                    });
                                  }
                                },
                                child: Container(
                                  width: size.width * 0.15,
                                  child: Column(
                                    children: [
                                      Container(
                                        height: size.width * 0.06,
                                        width: size.width * 0.06,
                                        decoration: BoxDecoration(
                                            color: _index == 1
                                                ? Colors.white
                                                : _index > 1
                                                    ? themeColor.primaryColor
                                                    : stepper_color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                width: size.width * 0.01,
                                                color: _index == 1
                                                    ? themeColor.primaryColor
                                                    : Colors.transparent)),
                                        child: _index > 1
                                            ? Container(
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Container(),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: size.height * 0.009),
                                        child: Text(
                                          "Services OverView",
                                          style: textTheme.bodyText2.copyWith(
                                              fontWeight: _index == 1
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: _index == 1
                                                  ? Colors.black
                                                  : Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.only(top: size.height * 0.005),
                                width: size.width * 0.1,
                                child: Divider(
                                  color: _index > 1
                                      ? themeColor.primaryColor
                                      : stepper_color,
                                  thickness: 3.0,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (stepTwoCompleted) {
                                    setState(() {
                                      _index = 2;
                                    });
                                  }
                                },
                                child: Container(
                                  width: size.width * 0.15,
                                  child: Column(
                                    children: [
                                      Container(
                                        height: size.width * 0.06,
                                        width: size.width * 0.06,
                                        decoration: BoxDecoration(
                                            color: _index == 2
                                                ? Colors.white
                                                : _index > 2
                                                    ? themeColor.primaryColor
                                                    : stepper_color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: _index == 2
                                                    ? themeColor.primaryColor
                                                    : Colors.transparent)),
                                        child: _index > 2
                                            ? Container(
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Container(),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: size.height * 0.009),
                                        child: Text(
                                          "Package Details",
                                          style: textTheme.bodyText2.copyWith(
                                              fontWeight: _index == 2
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: _index == 2
                                                  ? Colors.black
                                                  : Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.only(top: size.height * 0.005),
                                width: size.width * 0.1,
                                child: Divider(
                                  color: _index > 2
                                      ? themeColor.primaryColor
                                      : stepper_color,
                                  thickness: 3.0,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (stepThreeCompleted) {
                                    setState(() {
                                      _index = 3;
                                    });
                                  }
                                },
                                child: Container(
                                  width: size.width * 0.15,
                                  child: Column(
                                    children: [
                                      Container(
                                        height: size.width * 0.06,
                                        width: size.width * 0.06,
                                        decoration: BoxDecoration(
                                            color: _index == 3
                                                ? Colors.white
                                                : _index > 3
                                                    ? themeColor.primaryColor
                                                    : stepper_color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: _index == 3
                                                    ? themeColor.primaryColor
                                                    : Colors.transparent)),
                                        child: _index > 3
                                            ? Container(
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Container(),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: size.height * 0.009),
                                        child: Text(
                                          "Services Description",
                                          style: textTheme.bodyText2.copyWith(
                                              fontWeight: _index == 3
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: _index == 3
                                                  ? Colors.black
                                                  : Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.only(top: size.height * 0.005),
                                width: size.width * 0.1,
                                child: Divider(
                                  color: _index > 3
                                      ? themeColor.primaryColor
                                      : stepper_color,
                                  thickness: 3.0,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (stepFourCompleted) {
                                    setState(() {
                                      _index = 4;
                                    });
                                  }
                                },
                                child: Container(
                                  width: size.width * 0.15,
                                  child: Column(
                                    children: [
                                      Container(
                                        height: size.width * 0.06,
                                        width: size.width * 0.06,
                                        decoration: BoxDecoration(
                                            color: _index == 4
                                                ? Colors.white
                                                : _index > 4
                                                    ? themeColor.primaryColor
                                                    : stepper_color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                width: size.width * 0.01,
                                                color: _index == 4
                                                    ? themeColor.primaryColor
                                                    : Colors.transparent)),
                                        child: _index > 4
                                            ? Container(
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Container(),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: size.height * 0.009),
                                        child: Text(
                                          "Previous Works",
                                          style: textTheme.bodyText2.copyWith(
                                              fontWeight: _index == 4
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: _index == 4
                                                  ? Colors.black
                                                  : Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.only(top: size.height * 0.005),
                                width: size.width * 0.1,
                                child: Divider(
                                  color: _index > 4
                                      ? themeColor.primaryColor
                                      : stepper_color,
                                  thickness: 3.0,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (stepFiveCompleted) {
                                    setState(() {
                                      _index = 5;
                                    });
                                  }
                                },
                                child: Container(
                                  width: size.width * 0.15,
                                  child: Column(
                                    children: [
                                      Container(
                                        height: size.width * 0.06,
                                        width: size.width * 0.06,
                                        decoration: BoxDecoration(
                                            color: _index == 5
                                                ? Colors.white
                                                : _index > 5
                                                    ? themeColor.primaryColor
                                                    : stepper_color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                width: size.width * 0.01,
                                                color: _index == 5
                                                    ? themeColor.primaryColor
                                                    : Colors.transparent)),
                                        child: _index > 5
                                            ? Container(
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Container(),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: size.height * 0.009),
                                        child: Text(
                                          "Police Record Proof",
                                          style: textTheme.bodyText2.copyWith(
                                              fontWeight: _index == 5
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: _index == 5
                                                  ? Colors.black
                                                  : Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.only(top: size.height * 0.005),
                                width: size.width * 0.1,
                                child: Divider(
                                  color: _index > 5
                                      ? themeColor.primaryColor
                                      : stepper_color,
                                  thickness: 3.0,
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                  width: size.width * 0.15,
                                  child: Column(
                                    children: [
                                      Container(
                                        height: size.width * 0.06,
                                        width: size.width * 0.06,
                                        decoration: BoxDecoration(
                                            color: _index == 6 && isFinished
                                                ? themeColor.primaryColor
                                                : _index == 6
                                                    ? Colors.white
                                                    : stepper_color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: _index == 6
                                                    ? themeColor.primaryColor
                                                    : Colors.transparent)),
                                        child: isFinished
                                            ? Container(
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Container(),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: size.height * 0.009),
                                        child: Text(
                                          "Publish",
                                          style: textTheme.bodyText2.copyWith(
                                              fontWeight: _index == 6
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: _index == 6
                                                  ? Colors.black
                                                  : Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _index == 1,
                      child: Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: size.width * 0.06,
                              right: size.width * 0.06,
                              top: size.height * 0.03),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Service Title",
                                  style: textTheme.headline6,
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(top: size.height * 0.02),
                                  child: TextFormField(
                                      controller: serviceTitleController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter service title";
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          filled: true,
                                          fillColor:
                                              text_field_background_color,
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8))),
                                          hintText: "Service title",
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: size.width * 0.04))),
                                ),
                                Visibility(
                                    visible: serviceTitleError,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.008,
                                          horizontal: size.width * 0.04),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Select service title",
                                        style: textTheme.caption
                                            .copyWith(color: error_color),
                                      ),
                                    )),
                                Container(
                                  height: size.height * 0.06,
                                  margin:
                                      EdgeInsets.only(top: size.height * 0.02),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.04),
                                  decoration: BoxDecoration(
                                    color: text_field_background_color,
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(color: grey_color),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      isDense: true,
                                      isExpanded: true,
                                      hint: Text(
                                          getTranslated(context, "job_type")),
                                      value: selectedJobTypeId,
                                      items: jobs
                                          .map((value) => DropdownMenuItem(
                                                child: Text(value["name"]),
                                                value: value["id"],
                                              ))
                                          .toList(),
                                      onChanged: (id) {
                                        UserApiProvider.allSubCategories(id)
                                            .then((value) {
                                          setState(() {
                                            jobCategories = value['categories'];
                                            selectedJobTypeId = id;
                                          });
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Visibility(
                                    visible: jobTypeError,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.008,
                                          horizontal: size.width * 0.04),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Select job type",
                                        style: textTheme.caption
                                            .copyWith(color: error_color),
                                      ),
                                    )),
                                Container(
                                  height: size.height * 0.06,
                                  margin:
                                      EdgeInsets.only(top: size.height * 0.02),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.04),
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
                                      value: selectedCategoryId,
                                      items: jobCategories
                                          .map((value) => DropdownMenuItem(
                                                child: Text(value["name"]),
                                                value: value["id"],
                                              ))
                                          .toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedCategoryId = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Visibility(
                                    visible: jobCategoryError,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.008,
                                          horizontal: size.width * 0.04),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Select job category",
                                        style: textTheme.caption
                                            .copyWith(color: error_color),
                                      ),
                                    )),
                                Container(
                                  margin:
                                      EdgeInsets.only(top: size.height * 0.02),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Skills",
                                        style: textTheme.headline6,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          var data = await showDialog(
                                              context: context,
                                              builder: (_) => addSkillDialog());
                                          if (data != null) {
                                            setState(() {
                                              skills.add(data);
                                            });
                                          }
                                        },
                                        child: Image.asset(
                                          "assets/icons/icon-button-add.png",
                                          height: 20,
                                          width: 20,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Visibility(
                                    visible: skills.isNotEmpty,
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          top: size.height * 0.02),
                                      child: Wrap(
                                        spacing: size.width * 0.02,
                                        runSpacing: size.height * 0.01,
                                        children: skills
                                            .map(
                                              (e) => Container(
                                                padding: EdgeInsets.all(
                                                    size.width * 0.02),
                                                decoration: BoxDecoration(
                                                    color:
                                                        text_field_background_color,
                                                    border: Border.all(
                                                        color: themeColor
                                                            .primaryColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0)),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      e["name"] +
                                                          " " +
                                                          e["level"],
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        var i =
                                                            skills.indexOf(e);
                                                        setState(() {
                                                          skills.removeAt(i);
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 5),
                                                        child: Icon(
                                                          Icons
                                                              .highlight_remove_sharp,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    )),
                                Visibility(
                                    visible: skillListError,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.008,
                                          horizontal: size.width * 0.04),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Add at least one skill",
                                        style: textTheme.caption
                                            .copyWith(color: error_color),
                                      ),
                                    )),
                                Container(
                                  margin:
                                      EdgeInsets.only(top: size.height * 0.02),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Education",
                                        style: textTheme.headline6,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          var data = await showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  addEducationDialog());
                                          if (data != null) {
                                            setState(() {
                                              educations.add(data);
                                            });
                                          }
                                        },
                                        child: Image.asset(
                                          "assets/icons/icon-button-add.png",
                                          height: 20,
                                          width: 20,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Visibility(
                                    visible: educations.isNotEmpty,
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          top: size.height * 0.02),
                                      child: Wrap(
                                        spacing: size.width * 0.02,
                                        runSpacing: size.height * 0.01,
                                        children: educations
                                            .map(
                                              (e) => Container(
                                                padding: EdgeInsets.all(
                                                    size.width * 0.02),
                                                decoration: BoxDecoration(
                                                    color:
                                                        text_field_background_color,
                                                    border: Border.all(
                                                        color: themeColor
                                                            .primaryColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0)),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "(" +
                                                          e['degree'] +
                                                          ")" +
                                                          " " +
                                                          e['course'] +
                                                          " " +
                                                          "(" +
                                                          e['passing_year'] +
                                                          ")",
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        var i = educations
                                                            .indexOf(e);
                                                        setState(() {
                                                          educations
                                                              .removeAt(i);
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 5),
                                                        child: Icon(
                                                          Icons
                                                              .highlight_remove_sharp,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    )),
                                Visibility(
                                    visible: educationListError,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.008,
                                          horizontal: size.width * 0.04),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Add at least one educational detail",
                                        style: textTheme.caption
                                            .copyWith(color: error_color),
                                      ),
                                    )),
                                Container(
                                  margin:
                                      EdgeInsets.only(top: size.height * 0.02),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Languages",
                                        style: textTheme.headline6,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          var data = await showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  addLanguagesDialog());
                                          if (data != null) {
                                            setState(() {
                                              languages.add(data);
                                            });
                                          }
                                        },
                                        child: Image.asset(
                                          "assets/icons/icon-button-add.png",
                                          height: 20,
                                          width: 20,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Visibility(
                                    visible: languages.isNotEmpty,
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          top: size.height * 0.02),
                                      child: Wrap(
                                        spacing: size.width * 0.02,
                                        runSpacing: size.height * 0.01,
                                        children: languages
                                            .map(
                                              (e) => Container(
                                                padding: EdgeInsets.all(
                                                    size.width * 0.02),
                                                decoration: BoxDecoration(
                                                    color:
                                                        text_field_background_color,
                                                    border: Border.all(
                                                        color: themeColor
                                                            .primaryColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0)),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      e['language'] +
                                                          " " +
                                                          e['level'],
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        var i = languages
                                                            .indexOf(e);
                                                        setState(() {
                                                          languages.removeAt(i);
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 5),
                                                        child: Icon(
                                                          Icons
                                                              .highlight_remove_sharp,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    )),
                                Visibility(
                                    visible: languageListError,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.008,
                                          horizontal: size.width * 0.04),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Add atleast one language",
                                        style: textTheme.caption
                                            .copyWith(color: error_color),
                                      ),
                                    )),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.03),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: size.width * 0.42,
                                        height: size.height * 0.06,
                                        child: RaisedButton(
                                          textColor: primary_font,
                                          color: primary_color_seller,
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.height * 0.005),
                                          child: Text(
                                            getTranslated(context, "cancel"),
                                            textAlign: TextAlign.center,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: size.width * 0.42,
                                        height: size.height * 0.06,
                                        child: RaisedButton(
                                          textColor: primary_font,
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.height * 0.005),
                                          child: Text(
                                            "Save & Continue",
                                            textAlign: TextAlign.center,
                                          ),
                                          onPressed: () {
                                            if (serviceTitleController.text
                                                        .trim() ==
                                                    "" &&
                                                selectedJobTypeId == null &&
                                                selectedCategoryId == null &&
                                                skills.isEmpty &&
                                                educations.isEmpty &&
                                                languages.isEmpty) {
                                              setState(() {
                                                serviceTitleError = true;
                                                jobTypeError = true;
                                                jobCategoryError = true;
                                                skillListError = true;
                                                educationListError = true;
                                                languageListError = true;
                                              });
                                            } else if (serviceTitleController
                                                    .text
                                                    .trim() ==
                                                "") {
                                              setState(() {
                                                serviceTitleError = true;
                                              });
                                            } else if (selectedJobTypeId ==
                                                null) {
                                              setState(() {
                                                jobTypeError = true;
                                              });
                                            } else if (selectedCategoryId ==
                                                null) {
                                              setState(() {
                                                jobCategoryError = true;
                                              });
                                            } else if (skills.isEmpty) {
                                              setState(() {
                                                skillListError = true;
                                              });
                                            } else if (educations.isEmpty) {
                                              setState(() {
                                                educationListError = true;
                                              });
                                            } else if (languages.isEmpty) {
                                              setState(() {
                                                languageListError = true;
                                              });
                                            } else {
                                              setState(() {
                                                _index = 2;
                                                stepOneCompleted = true;
                                              });
                                            }
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                        visible: _index == 2,
                        child: Expanded(
                          child: Container(
                            padding: EdgeInsets.only(
                                left: size.width * 0.06,
                                right: size.width * 0.06,
                                top: size.height * 0.03),
                            child: SingleChildScrollView(
                              child: Form(
                                key: _packageForm,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: "Basic",
                                          style: textTheme.headline6.copyWith(
                                              color: themeColor.primaryColor)),
                                      TextSpan(
                                          text: " Package",
                                          style: textTheme.headline6),
                                    ])),
                                    Divider(),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: size.height * 0.02),
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Enter description";
                                          }
                                          return null;
                                        },
                                        controller: basicDescriptionController,
                                        maxLines: 4,
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor:
                                                text_field_background_color,
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8))),
                                            hintText:
                                                "Describe details of your basic service (1h)",
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal:
                                                        size.width * 0.04,
                                                    vertical:
                                                        size.width * 0.04)),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: size.height * 0.02),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: size.width * 0.43,
                                            child: TextFormField(
                                                controller:
                                                    basicPriceController,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Enter price/hr";
                                                  }
                                                  return null;
                                                },
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor:
                                                        text_field_background_color,
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8))),
                                                    hintText: "Price/hr",
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                size.width *
                                                                    0.04))),
                                          ),
                                          Container(
                                            width: size.width * 0.43,
                                            child: TextFormField(
                                                controller:
                                                    basicAdditionalPriceController,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Enter additional price/hr";
                                                  }
                                                  return null;
                                                },
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor:
                                                        text_field_background_color,
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8))),
                                                    hintText:
                                                        "Additional price/hr",
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                size.width *
                                                                    0.04))),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: size.height * 0.03),
                                      child: RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "Standard",
                                            style: textTheme.headline6.copyWith(
                                                color:
                                                    themeColor.primaryColor)),
                                        TextSpan(
                                            text: " Package",
                                            style: textTheme.headline6),
                                      ])),
                                    ),
                                    Divider(),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: size.height * 0.02),
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Enter description";
                                          }
                                          return null;
                                        },
                                        controller:
                                            standardDescriptionController,
                                        maxLines: 4,
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor:
                                                text_field_background_color,
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8))),
                                            hintText:
                                                "Describe details of your standard service (1h)",
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal:
                                                        size.width * 0.04,
                                                    vertical:
                                                        size.width * 0.04)),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: size.height * 0.02),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: size.width * 0.43,
                                            child: TextFormField(
                                                controller:
                                                    standardPriceController,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Enter Price/hr";
                                                  }
                                                  return null;
                                                },
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor:
                                                        text_field_background_color,
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8))),
                                                    hintText: "Price/hr",
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                size.width *
                                                                    0.04))),
                                          ),
                                          Container(
                                            width: size.width * 0.43,
                                            child: TextFormField(
                                                controller:
                                                    standardAdditionalPriceController,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Enter additional price/hr";
                                                  }
                                                  return null;
                                                },
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor:
                                                        text_field_background_color,
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8))),
                                                    hintText:
                                                        "Additional price/hr",
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                size.width *
                                                                    0.04))),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: size.height * 0.03),
                                      child: RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "Premium",
                                            style: textTheme.headline6.copyWith(
                                                color:
                                                    themeColor.primaryColor)),
                                        TextSpan(
                                            text: " Package",
                                            style: textTheme.headline6),
                                      ])),
                                    ),
                                    Divider(),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: size.height * 0.02),
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Enter description";
                                          }
                                          return null;
                                        },
                                        controller:
                                            premiumDescriptionController,
                                        maxLines: 4,
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor:
                                                text_field_background_color,
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8))),
                                            hintText:
                                                "Describe details of your standard service (1h)",
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal:
                                                        size.width * 0.04,
                                                    vertical:
                                                        size.width * 0.04)),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: size.height * 0.02),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: size.width * 0.43,
                                            child: TextFormField(
                                                controller:
                                                    premiumPriceController,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Enter Price/hr";
                                                  }
                                                  return null;
                                                },
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor:
                                                        text_field_background_color,
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8))),
                                                    hintText: "Price/hr",
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                size.width *
                                                                    0.04))),
                                          ),
                                          Container(
                                            width: size.width * 0.43,
                                            child: TextFormField(
                                                controller:
                                                    premiumAdditionalPriceController,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Enter additional price/hr";
                                                  }
                                                  return null;
                                                },
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor:
                                                        text_field_background_color,
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8))),
                                                    hintText:
                                                        "Additional price/hr",
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                size.width *
                                                                    0.04))),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: size.width * 0.9,
                                      height: size.height * 0.06,
                                      margin: EdgeInsets.symmetric(
                                          vertical: size.height * 0.03),
                                      child: RaisedButton(
                                        textColor: primary_font,
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.005),
                                        child: Text(
                                          "Save & Continue",
                                          textAlign: TextAlign.center,
                                        ),
                                        onPressed: () {
                                          if (_packageForm.currentState
                                              .validate()) {
                                            setState(() {
                                              _index = 3;
                                              stepTwoCompleted = true;
                                            });
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )),
                    Visibility(
                      visible: _index == 3,
                      child: Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: size.width * 0.06,
                              right: size.width * 0.06,
                              top: size.height * 0.03),
                          child: SingleChildScrollView(
                            child: Form(
                              key: _packageDetailForm,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text: "Service",
                                        style: textTheme.headline6.copyWith(
                                            color: themeColor.primaryColor)),
                                    TextSpan(
                                        text: " Package",
                                        style: textTheme.headline6),
                                  ])),
                                  Divider(),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.02),
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter description";
                                        }
                                        return null;
                                      },
                                      controller: serviceDescriptionController,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                          filled: true,
                                          fillColor:
                                              text_field_background_color,
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8))),
                                          hintText:
                                              "Briefly describe your service",
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: size.width * 0.04,
                                              vertical: size.width * 0.04)),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.02),
                                    child: TypeAheadField(
                                      noItemsFoundBuilder: (context) {
                                        return ListTile(
                                          title: Text("No Data Found!"),
                                        );
                                      },
                                      getImmediateSuggestions: true,
                                      hideOnEmpty: true,
                                      textFieldConfiguration:
                                          TextFieldConfiguration(
                                              controller:
                                                  serviceLocationController,
                                              decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor:
                                                      text_field_background_color,
                                                  suffixIconConstraints:
                                                      BoxConstraints(
                                                          maxHeight: 24,
                                                          maxWidth: 44),
                                                  suffixIcon: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10),
                                                    child: Image.asset(
                                                      "assets/icons/icon-location.png",
                                                    ),
                                                  ),
                                                  border: OutlineInputBorder(
                                                      borderRadius: BorderRadius
                                                          .all(Radius.circular(
                                                              8))),
                                                  hintText: "Service Location",
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal:
                                                              size.width * 0.04,
                                                          vertical: size.width *
                                                              0.04))),
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
                                  Visibility(
                                      visible: isLocationError,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.008,
                                            horizontal: size.width * 0.04),
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "Enter proper address",
                                          style: textTheme.caption
                                              .copyWith(color: error_color),
                                        ),
                                      )),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.03),
                                    child: Row(
                                      children: [
                                        Switch(
                                          value: isSwitched,
                                          onChanged: (value) {
                                            if (value) {
                                              setState(() {
                                                isSwitched = value;
                                                checkLocationPermission();
                                              });
                                            } else {
                                              setState(() {
                                                isSwitched = value;
                                              });
                                            }
                                          },
                                          activeTrackColor: themeColor
                                              .primaryColor
                                              .withOpacity(0.5),
                                          activeColor: themeColor.primaryColor,
                                        ),
                                        Expanded(
                                            child: Text(
                                          getTranslated(context,
                                              "detect_service_location"),
                                          style: textTheme.subtitle1,
                                        ))
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.02),
                                    child: Divider(),
                                  ),
                                  Container(
                                      alignment: Alignment.center,
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: size.height * 0.02),
                                        child: Image.asset(
                                          "assets/icons/icon-bulb.png",
                                          width: size.width * 0.2,
                                          fit: BoxFit.contain,
                                        ),
                                      )),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: size.height * 0.02),
                                    child: Text(
                                      getTranslated(context, "what_offering"),
                                      style: textTheme.subtitle1,
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: size.height * 0.008),
                                      width: size.width * 0.9,
                                      height: size.height * 0.06,
                                      child: RaisedButton(
                                        textColor: primary_font,
                                        onPressed: () {
                                          onSubmitServiceDescription();
                                        },
                                        child: Text(getTranslated(
                                            context, "save_continue")),
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _index == 4,
                      child: Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: size.width * 0.06,
                              right: size.width * 0.06,
                              top: size.height * 0.03),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.01),
                                  alignment: Alignment.topLeft,
                                  child: RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text: "Upload Previous Works",
                                        style: textTheme.headline6),
                                    TextSpan(
                                        text: " Images:",
                                        style: textTheme.headline6.copyWith(
                                            color: themeColor.primaryColor)),
                                  ])),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.03),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          getWorkImages();
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: size.width * 0.01,
                                          ),
                                          decoration: BoxDecoration(
                                              color:
                                                  text_field_background_color,
                                              border: Border.all(
                                                  color:
                                                      themeColor.accentColor),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0))),
                                          height: size.height * 0.1,
                                          width: size.width * 0.2,
                                          child: Icon(Icons.camera_alt),
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: size.height * 0.1,
                                          child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount:
                                                  previousWorkImages.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Stack(
                                                  children: [
                                                    Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                        horizontal:
                                                            size.width * 0.01,
                                                      ),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              text_field_background_color,
                                                          border: Border.all(
                                                              color: themeColor
                                                                  .accentColor),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          8.0))),
                                                      height: size.height * 0.1,
                                                      width: size.width * 0.2,
                                                      child: Image.file(
                                                        previousWorkImages[
                                                            index],
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      child: Icon(
                                                        Icons
                                                            .highlight_remove_sharp,
                                                        color: Colors.grey,
                                                      ),
                                                      onTap: () {
                                                        setState(() {
                                                          previousWorkImages
                                                              .removeAt(index);
                                                        });
                                                      },
                                                    )
                                                  ],
                                                );
                                              }),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Visibility(
                                    visible: workImageserror &&
                                        previousWorkImages.isEmpty,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.008,
                                          horizontal: size.width * 0.04),
                                      child: Text(
                                        "Upload at least one previous work image",
                                        textAlign: TextAlign.center,
                                        style: textTheme.caption
                                            .copyWith(color: error_color),
                                      ),
                                    )),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.01),
                                  alignment: Alignment.topLeft,
                                  child: RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text: "Upload Previous Works",
                                        style: textTheme.headline6),
                                    TextSpan(
                                        text: " Videos:",
                                        style: textTheme.headline6.copyWith(
                                            color: themeColor.primaryColor)),
                                  ])),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.03),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          getWorkVideos();
                                        },
                                        child: Container(
                                            margin: EdgeInsets.symmetric(
                                              horizontal: size.width * 0.01,
                                            ),
                                            decoration: BoxDecoration(
                                                color:
                                                    text_field_background_color,
                                                border: Border.all(
                                                    color:
                                                        themeColor.accentColor),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0))),
                                            height: size.height * 0.1,
                                            width: size.width * 0.2,
                                            child: Icon(Icons.video_library)),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: size.height * 0.1,
                                          child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: videoThumbnails.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Stack(
                                                  children: [
                                                    Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                        horizontal:
                                                            size.width * 0.01,
                                                      ),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              text_field_background_color,
                                                          border: Border.all(
                                                              color: themeColor
                                                                  .accentColor),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          8.0))),
                                                      height: size.height * 0.1,
                                                      width: size.width * 0.2,
                                                      child: Image.memory(
                                                        videoThumbnails[index],
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      child: Icon(
                                                        Icons
                                                            .highlight_remove_sharp,
                                                        color: Colors.grey,
                                                      ),
                                                      onTap: () {
                                                        setState(() {
                                                          previousWorkVideos
                                                              .removeAt(index);
                                                          videoThumbnails
                                                              .removeAt(index);
                                                        });
                                                      },
                                                    )
                                                  ],
                                                );
                                              }),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: size.height * 0.008),
                                    width: size.width * 0.9,
                                    height: size.height * 0.06,
                                    child: RaisedButton(
                                      textColor: primary_font,
                                      onPressed: () {
                                        if (previousWorkImages.isEmpty) {
                                          setState(() {
                                            workImageserror = true;
                                          });
                                        } else {
                                          setState(() {
                                            stepFourCompleted = true;
                                            _index = 5;
                                          });
                                        }
                                      },
                                      child: Text(getTranslated(
                                          context, "save_continue")),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _index == 5,
                      child: Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: size.width * 0.06,
                              right: size.width * 0.06,
                              top: size.height * 0.03),
                          child: SingleChildScrollView(
                            child: Form(
                              key: _policeRecordForm,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text: "Police",
                                        style: textTheme.headline6.copyWith(
                                            color: themeColor.primaryColor)),
                                    TextSpan(
                                        text: " Record Proof",
                                        style: textTheme.headline6),
                                  ])),
                                  Divider(),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.02),
                                    child: TextFormField(
                                        controller: policeRecordIdController,
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor:
                                                text_field_background_color,
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8))),
                                            hintText: "Id",
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal:
                                                        size.width * 0.04))),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.02),
                                    child: TextFormField(
                                      controller: justiceOfPeaceController,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                          filled: true,
                                          fillColor:
                                              text_field_background_color,
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8))),
                                          hintText:
                                              "Reference from justice of peace",
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: size.width * 0.04,
                                              vertical: size.width * 0.04)),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.02),
                                    child: TextFormField(
                                        controller: personOneController,
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor:
                                                text_field_background_color,
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8))),
                                            hintText: "Person 1",
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal:
                                                        size.width * 0.04))),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.02),
                                    child: TextFormField(
                                        controller: personTwoController,
                                        validator: (value) {
                                          if (personOneController.text.trim() !=
                                              "") {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Enter person 2";
                                            }
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor:
                                                text_field_background_color,
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8))),
                                            hintText: "Person 2",
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal:
                                                        size.width * 0.04))),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.02),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color:
                                                  text_field_background_color,
                                              border: Border.all(
                                                  color:
                                                      themeColor.accentColor),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0))),
                                          height: size.height * 0.1,
                                          width: size.width * 0.2,
                                          child: policeRecordProof != null
                                              ? path.extension(policeRecordProof
                                                              .path) ==
                                                          ".jpg" ||
                                                      path.extension(
                                                              policeRecordProof
                                                                  .path) ==
                                                          ".jpeg"
                                                  ? Image.file(
                                                      policeRecordProof,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : path.extension(
                                                                  policeRecordProof
                                                                      .path) ==
                                                              ".doc" ||
                                                          path.extension(
                                                                  policeRecordProof
                                                                      .path) ==
                                                              ".pdf"
                                                      ? Icon(Icons
                                                          .file_copy_outlined)
                                                      : null
                                              : null,
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: size.width * 0.05),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Police Record",
                                                style: textTheme.subtitle2,
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(top: 10),
                                                height: 20,
                                                child: RaisedButton(
                                                  color: Color(0xFF8cc660),
                                                  textColor: primary_font,
                                                  onPressed: () {
                                                    getPoliceRecordProof(
                                                        "record");
                                                  },
                                                  child: Text("Browse"),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.02,
                                        bottom: size.height * 0.02),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color:
                                                  text_field_background_color,
                                              border: Border.all(
                                                  color:
                                                      themeColor.accentColor),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0))),
                                          height: size.height * 0.1,
                                          width: size.width * 0.2,
                                          child: billProof != null
                                              ? path.extension(
                                                              billProof.path) ==
                                                          ".jpg" ||
                                                      path.extension(
                                                              billProof.path) ==
                                                          ".jpeg"
                                                  ? Image.file(
                                                      billProof,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : path.extension(billProof
                                                                  .path) ==
                                                              ".doc" ||
                                                          path.extension(
                                                                  billProof
                                                                      .path) ==
                                                              ".pdf"
                                                      ? Icon(Icons
                                                          .file_copy_outlined)
                                                      : null
                                              : null,
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: size.width * 0.05),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Bill in name",
                                                style: textTheme.subtitle2,
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(top: 10),
                                                height: 20,
                                                child: RaisedButton(
                                                  color: Color(0xFF8cc660),
                                                  textColor: primary_font,
                                                  onPressed: () {
                                                    getPoliceRecordProof(
                                                        "bills");
                                                  },
                                                  child: Text("Browse"),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(
                                          top: size.height * 0.02,
                                          bottom: size.height * 0.02),
                                      width: size.width * 0.9,
                                      height: size.height * 0.06,
                                      child: RaisedButton(
                                        textColor: primary_font,
                                        onPressed: () {
                                          if (_policeRecordForm.currentState
                                              .validate()) {
                                            setState(() {
                                              stepFiveCompleted = true;
                                              _index = 6;
                                            });
                                          }
                                        },
                                        child: Text(getTranslated(
                                            context, "save_continue")),
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _index == 6,
                      child: Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: size.width * 0.06,
                              right: size.width * 0.06,
                              top: size.height * 0.03),
                          child: SingleChildScrollView(
                            child: !isFinished
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "You are almost",
                                            style: textTheme.headline6),
                                        TextSpan(
                                            text: " Finished.",
                                            style: textTheme.headline6.copyWith(
                                                color:
                                                    themeColor.primaryColor)),
                                      ])),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: size.height * 0.02),
                                        child: Text(
                                          getTranslated(
                                              context, "publish_service"),
                                          style: textTheme.subtitle1,
                                        ),
                                      ),
                                      Divider(),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: size.height * 0.02),
                                        child: Text(
                                          getTranslated(
                                              context, "personal_information"),
                                          style: textTheme.headline6,
                                        ),
                                      ),
                                      Container(
                                          child: TextFormField(
                                              controller: documentIdController,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Enter id";
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor:
                                                      text_field_background_color,
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8))),
                                                  hintText: "ID#",
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal:
                                                              size.width *
                                                                  0.04)))),
                                      Visibility(
                                          visible: isIdNull,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: size.height * 0.008,
                                                horizontal: size.width * 0.04),
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              "Enter document number",
                                              style: textTheme.caption
                                                  .copyWith(color: error_color),
                                            ),
                                          )),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: size.height * 0.02),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color:
                                                      text_field_background_color,
                                                  border: Border.all(
                                                      color: themeColor
                                                          .accentColor),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              8.0))),
                                              height: size.height * 0.1,
                                              width: size.width * 0.2,
                                              child: documentPicture != null
                                                  ? Image.file(
                                                      documentPicture,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: size.width * 0.05),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "ID Scan",
                                                    style: textTheme.subtitle2,
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10),
                                                    height: 20,
                                                    child: RaisedButton(
                                                      color: Color(0xFF8cc660),
                                                      textColor: primary_font,
                                                      onPressed: () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                    context) =>
                                                                selectPictureDialog());
                                                      },
                                                      child: Text("Browse"),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                          visible: isDocumentNull,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: size.height * 0.008,
                                                horizontal: size.width * 0.04),
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              "Upload Document Picture",
                                              style: textTheme.caption
                                                  .copyWith(color: error_color),
                                            ),
                                          )),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.03),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: size.width * 0.42,
                                              height: size.height * 0.06,
                                              child: RaisedButton(
                                                textColor: primary_font,
                                                color: primary_color_seller,
                                                padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        size.height * 0.005),
                                                child: Text(
                                                  getTranslated(
                                                      context, "cancel"),
                                                  textAlign: TextAlign.center,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ServiceMenu()));
                                                },
                                              ),
                                            ),
                                            Container(
                                              width: size.width * 0.42,
                                              height: size.height * 0.06,
                                              child: RaisedButton(
                                                textColor: primary_font,
                                                padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        size.height * 0.005),
                                                child: Text(
                                                  "Publish",
                                                  textAlign: TextAlign.center,
                                                ),
                                                onPressed: () {
                                                  if (documentIdController.text
                                                              .trim() ==
                                                          "" &&
                                                      documentPicture == null) {
                                                    setState(() {
                                                      isDocumentNull = true;
                                                      isIdNull = true;
                                                    });
                                                  } else if (documentIdController
                                                          .text
                                                          .trim() ==
                                                      "") {
                                                    setState(() {
                                                      isIdNull = true;
                                                    });
                                                  } else if (documentPicture ==
                                                      null) {
                                                    setState(() {
                                                      isDocumentNull = true;
                                                    });
                                                  } else {
                                                    submitUserData();
                                                  }
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : Container(
                                    width: size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: size.height * 0.005),
                                          child: Image.asset(
                                            "assets/icons/icon-profile-finished.png",
                                            width: size.width * 0.6,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: size.height * 0.05),
                                          child: Text(
                                            "Congratulations !",
                                            textAlign: TextAlign.center,
                                            style: textTheme.headline6,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ));
  }
}
