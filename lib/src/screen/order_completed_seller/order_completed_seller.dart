import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/service_menu/service_menu.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:home_services/src/widget/seller_drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:developer';

class OrderCompletedSeller extends StatefulWidget {
  final jobId, consumerId, fromJobs;

  OrderCompletedSeller(
      {@required this.jobId, @required this.consumerId, this.fromJobs});

  @override
  State<StatefulWidget> createState() {
    return OrderCompletedSellerState();
  }
}

class OrderCompletedSellerState extends State<OrderCompletedSeller> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  GlobalKey<FormState> orderCompleteForm = GlobalKey();
  TextEditingController commentController = TextEditingController();
  TextEditingController consumerCommentController = TextEditingController();
  var jobDetail;
  List jobProofMedia = [];

  double rating = 0.0,
      consumerRating = 0.0,
      punctualityRate = 0.0,
      professionalismRate = 0.0,
      serviceRate = 0.0,
      timingRate = 0.0,
      satisfactionRate = 0.0;
  bool isLoading = false,
      fromJobs = false,
      videoError = false,
      imageError = false;
  int ratingCount = 0;
  List<File> imageFiles = [], videoFiles = [];
  List thumbnails = [];

  @override
  void initState() {
    super.initState();
    fromJobs = widget.fromJobs;
    getJobDetail();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getJobDetail() {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    UserApiProvider.jobDetailForProfessional(widget.jobId).then((value) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      if (value['result']) {
        if (widget.fromJobs) {
          consumerCommentController.text =
              value['job_details']['rating'] == null
                  ? ""
                  : value['job_details']['rating']['comment'];
          jobProofMedia = value['job_proof_media'];
        }
        if (mounted) {
          setState(() {
            jobDetail = value['job_details'];
          });
        }
      }
    });
  }

  postComment() {
    setState(() {
      isLoading = true;
    });
    UserApiProvider.reviewToConsumer(widget.jobId, widget.consumerId, rating,
            commentController.text.toString())
        .then((value) {
      setState(() {
        isLoading = false;
      });
      if (value['result']) {
        showMessage(context, "Review submitted successfully!");
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
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => ServiceMenu()),
                    (Route<dynamic> route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  SimpleDialog selectFileDialog(type) {
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
            if (type == "images") {
              getPictureFromCamera();
            } else {
              getVideoFromCamera();
            }
          },
          child: Text(
            getTranslated(context, "camera"),
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.of(context).pop();
            if (type == "images") {
              getPictureFromGallery();
            } else {
              getVideoFromGallery();
            }
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
    final pickedImage = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedImage != null) {
      setState(() {
        imageFiles.add(File(pickedImage.path));
      });
    }
  }

  getPictureFromGallery() async {
    final pickedImages = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);
    if (pickedImages != null) {
      var images = pickedImages.files.map((e) => File(e.path)).toList();
      setState(() {
        imageFiles.addAll(images);
      });
    }
  }

  getVideoFromGallery() async {
    final pickedVideos = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.video);

    if (pickedVideos != null) {
      var videos = pickedVideos.files.map((e) => File(e.path)).toList();
      var data = [];

      for (var i = 0; i < videos.length; i++) {
        Uint8List bytes;
        bytes = await VideoThumbnail.thumbnailData(
          video: videos[i].path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 150,
          quality: 25,
        );
        data.add(bytes);
      }
      setState(() {
        videoFiles.addAll(videos);
        thumbnails.addAll(data);
      });
    }
  }

  getVideoFromCamera() async {
    final pickedVideo =
        await ImagePicker().getVideo(source: ImageSource.camera);
    if (pickedVideo != null) {
      var data = await VideoThumbnail.thumbnailData(
        video: pickedVideo.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 150,
        quality: 25,
      );
      setState(() {
        videoFiles.add(File(pickedVideo.path));
        thumbnails.add(data);
      });
    }
  }

  uploadDocuments() {
    if (videoFiles.isEmpty && imageFiles.isEmpty) {
      setState(() {
        videoError = true;
        imageError = true;
      });
    } else if (videoFiles.isEmpty) {
      setState(() {
        videoError = true;
      });
    } else if (imageFiles.isEmpty) {
      setState(() {
        videoError = true;
      });
    } else {
      setState(() {
        isLoading = true;
      });
      UserApiProvider.uploadJobProof(widget.jobId, imageFiles, videoFiles)
          .then((value) {
        setState(() {
          isLoading = false;
        });
        if (value['result']) {
          showMessage(context, "Documents Uploaded Successfully!");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    return Scaffold(
        key: key,
        drawer: SellerDrawer(),
        appBar: primaryAppBar(context, "order_completed", key),
        extendBodyBehindAppBar: isLoading,
        body: isLoading
            ? loadingData(context)
            : !fromJobs
                ? SingleChildScrollView(
                    child: Form(
                      key: orderCompleteForm,
                      child: Container(
                        width: size.width,
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(top: size.height * 0.03),
                              child: Text(
                                'Thanks for choosing ClickAway Services',
                                textAlign: TextAlign.center,
                                style: textTheme.headline6,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.008),
                              child: Column(
                                children: [
                                  Divider(),
                                  Container(
                                    height: size.height * 0.1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.height * 0.009),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Order",
                                                style: textTheme.subtitle1,
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        size.height * 0.005),
                                                child: Text(
                                                  "OO-${jobDetail['work_date']}-${jobDetail['id']}",
                                                  style: textTheme.subtitle1
                                                      .copyWith(
                                                          color: themeColor
                                                              .primaryColor,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        VerticalDivider(),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.height * 0.009),
                                          child: Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Order Placed",
                                                    style: textTheme.subtitle1,
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical:
                                                                size.height *
                                                                    0.005),
                                                    child: Text(
                                                      jobDetail['created_at']
                                                          .toString()
                                                          .split(" ")[0],
                                                      style: textTheme.subtitle1
                                                          .copyWith(
                                                              color: themeColor
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider()
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: size.height * 0.02),
                              child: RichText(
                                  text: TextSpan(children: [
                                TextSpan(
                                    text: "Upload",
                                    style: textTheme.headline6.copyWith(
                                        color: themeColor.primaryColor)),
                                TextSpan(
                                    text: " Images",
                                    style: textTheme.headline6),
                              ])),
                            ),
                            Divider(),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            selectFileDialog("images"));
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.01,
                                    ),
                                    decoration: BoxDecoration(
                                        color:
                                            text_field_background_color_seller,
                                        border: Border.all(
                                            color: themeColor.accentColor),
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
                                        itemCount: imageFiles.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Stack(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: size.width * 0.01,
                                                ),
                                                decoration: BoxDecoration(
                                                    color:
                                                        text_field_background_color_seller,
                                                    border: Border.all(
                                                        color: themeColor
                                                            .accentColor),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8.0))),
                                                height: size.height * 0.1,
                                                width: size.width * 0.2,
                                                child: Image.file(
                                                  imageFiles[index],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              GestureDetector(
                                                child: Icon(
                                                  Icons.highlight_remove_sharp,
                                                  color: Colors.grey,
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    imageFiles.removeAt(index);
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
                            Visibility(
                                visible: imageError && imageFiles.isEmpty,
                                child: Container(
                                  alignment: Alignment.topLeft,
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.008,
                                      horizontal: size.width * 0.04),
                                  child: Text(
                                    "Upload atlest one image",
                                    textAlign: TextAlign.center,
                                    style: textTheme.caption
                                        .copyWith(color: error_color),
                                  ),
                                )),
                            Container(
                              margin: EdgeInsets.only(top: size.height * 0.02),
                              child: RichText(
                                  text: TextSpan(children: [
                                TextSpan(
                                    text: "Upload",
                                    style: textTheme.headline6.copyWith(
                                        color: themeColor.primaryColor)),
                                TextSpan(
                                    text: " Video", style: textTheme.headline6),
                              ])),
                            ),
                            Divider(),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            selectFileDialog("videos"));
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.01,
                                    ),
                                    decoration: BoxDecoration(
                                        color:
                                            text_field_background_color_seller,
                                        border: Border.all(
                                            color: themeColor.accentColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0))),
                                    height: size.height * 0.1,
                                    width: size.width * 0.2,
                                    child: Icon(Icons.video_collection),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: size.height * 0.1,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: thumbnails.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Stack(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: size.width * 0.01,
                                                ),
                                                decoration: BoxDecoration(
                                                    color:
                                                        text_field_background_color_seller,
                                                    border: Border.all(
                                                        color: themeColor
                                                            .accentColor),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8.0))),
                                                height: size.height * 0.1,
                                                width: size.width * 0.2,
                                                child: Image.memory(
                                                  thumbnails[index],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              GestureDetector(
                                                child: Icon(
                                                  Icons.highlight_remove_sharp,
                                                  color: Colors.grey,
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    thumbnails.removeAt(index);
                                                    videoFiles.removeAt(index);
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
                            Visibility(
                                visible: imageError && imageFiles.isEmpty,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.008,
                                      horizontal: size.width * 0.04),
                                  child: Text(
                                    "Upload atlest one video",
                                    textAlign: TextAlign.center,
                                    style: textTheme.caption
                                        .copyWith(color: error_color),
                                  ),
                                )),
                            Container(
                              width: size.width * 0.9,
                              height: size.height * 0.06,
                              margin: EdgeInsets.symmetric(
                                  vertical: size.height * 0.02),
                              child: RaisedButton(
                                textColor: primary_font,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.005),
                                child: Text(
                                  "Submit Documents",
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () {
                                  uploadDocuments();
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: size.height * 0.02),
                              child: RichText(
                                  text: TextSpan(children: [
                                TextSpan(
                                    text: "Rate",
                                    style: textTheme.headline6.copyWith(
                                        color: themeColor.primaryColor)),
                                TextSpan(
                                    text: " Buyer", style: textTheme.headline6),
                              ])),
                            ),
                            Divider(),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  )),
                              margin: EdgeInsets.symmetric(
                                  vertical: size.height * 0.02),
                              padding: EdgeInsets.all(size.height * 0.02),
                              child: Row(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: Constant.STORAGE_PATH +
                                        jobDetail['consumer_avatar'],
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
                                    padding: EdgeInsets.only(
                                        left: size.width * 0.03),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.height * 0.005),
                                          child: Text(
                                            jobDetail['consumer_name'],
                                            style: textTheme.subtitle2,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            GFRating(
                                              color: themeColor.accentColor,
                                              value: jobDetail[
                                                          'consumer_rating'] !=
                                                      null
                                                  ? jobDetail['consumer_rating']
                                                              [
                                                              'average_rating'] !=
                                                          null
                                                      ? double.parse(jobDetail[
                                                                  'consumer_rating']
                                                              ['average_rating']
                                                          .toString())
                                                      : 0.0
                                                  : 0.0,
                                              size: 20.0,
                                            ),
                                            Text(
                                                ' (${jobDetail['consumer_rating']['rating_count']})')
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: GFRating(
                                color: themeColor.accentColor,
                                size: 35.0,
                                value: rating,
                                onChanged: (value) {
                                  setState(() {
                                    rating = value;
                                  });
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: size.height * 0.03),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Enter comment";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    hintText: getTranslated(
                                        context, "write_comment_here"),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3.0)))),
                                controller: commentController,
                                minLines: 6,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: size.height * 0.002),
                              width: size.width * 0.9,
                              height: size.height * 0.06,
                              child: RaisedButton(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.005),
                                child: Text(
                                  getTranslated(context, "post_comment"),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () {
                                  if (orderCompleteForm.currentState
                                      .validate()) {
                                    postComment();
                                  }
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: size.height * 0.02),
                              width: size.width * 0.9,
                              height: size.height * 0.06,
                              child: RaisedButton(
                                color: themeColor.accentColor,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.005),
                                child: Text(
                                  getTranslated(context, "no_thanks"),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ServiceMenu()),
                                      (Route<dynamic> route) => false);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Form(
                    key: orderCompleteForm,
                    child: Container(
                      width: size.width,
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.04),
                      child: Column(
                        children: [
                          Container(
                            width: size.width,
                            decoration: BoxDecoration(
                                color: secondary_color,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0))),
                            margin: EdgeInsets.only(top: size.height * 0.03),
                            padding: EdgeInsets.all(size.height * 0.02),
                            child: Text(
                              'Thanks for choosing ClickAway Services',
                              style: textTheme.subtitle2
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.002),
                            decoration: BoxDecoration(
                                color: secondary_color,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0))),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.01,
                                      horizontal: size.height * 0.02),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(
                                                  right: size.width * 0.03),
                                              child: Text(
                                                "Order Id",
                                                style: textTheme.subtitle2
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w700),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "#OO-${jobDetail['work_date']}-${jobDetail['id']}",
                                        style: textTheme.subtitle2,
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.01,
                                            horizontal: size.height * 0.02),
                                        child: Text(
                                          getTranslated(
                                              context, "service_date"),
                                          style: textTheme.subtitle2.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                          width: size.width * 0.6,
                                          height: size.height * 0.048,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      "assets/icons/white-bg-corner-shape-2.png"),
                                                  fit: BoxFit.fill)),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: size.height * 0.01,
                                                horizontal: size.height * 0.02),
                                            child: Container(
                                                alignment: Alignment.topRight,
                                                child: Text(
                                                  "${jobDetail['work_date']}",
                                                  style: textTheme.subtitle2,
                                                )),
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Punctuality",
                                  style: textTheme.subtitle2
                                      .copyWith(fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.left,
                                ),
                                GFRating(
                                  color: themeColor.accentColor,
                                  size: 26.0,
                                  value: jobDetail['rating'] != null
                                      ? jobDetail['rating']['punctuality'] !=
                                              null
                                          ? double.parse(jobDetail['rating']
                                                  ['punctuality']
                                              .toString())
                                          : 0.0
                                      : 0.0,
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Professionalism",
                                  style: textTheme.subtitle2
                                      .copyWith(fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.left,
                                ),
                                GFRating(
                                  color: themeColor.accentColor,
                                  size: 26.0,
                                  value: jobDetail['rating'] != null
                                      ? jobDetail['rating']
                                                  ['professionalism'] !=
                                              null
                                          ? double.parse(jobDetail['rating']
                                                  ['professionalism']
                                              .toString())
                                          : 0.0
                                      : 0.0,
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Customer service",
                                  style: textTheme.subtitle2
                                      .copyWith(fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.left,
                                ),
                                GFRating(
                                  color: themeColor.accentColor,
                                  size: 26.0,
                                  value: jobDetail['rating'] != null
                                      ? jobDetail['rating']
                                                  ['customer_service'] !=
                                              null
                                          ? double.parse(jobDetail['rating']
                                                  ['customer_service']
                                              .toString())
                                          : 0.0
                                      : 0.0,
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Completion time",
                                  style: textTheme.subtitle2
                                      .copyWith(fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.left,
                                ),
                                GFRating(
                                  color: themeColor.accentColor,
                                  size: 26.0,
                                  value: jobDetail['rating'] != null
                                      ? jobDetail['rating']
                                                  ['completion_time'] !=
                                              null
                                          ? double.parse(jobDetail['rating']
                                                  ['completion_time']
                                              .toString())
                                          : 0.0
                                      : 0.0,
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Satisfaction",
                                  style: textTheme.subtitle2
                                      .copyWith(fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.left,
                                ),
                                GFRating(
                                  color: themeColor.accentColor,
                                  size: 26.0,
                                  value: jobDetail['rating'] != null
                                      ? jobDetail['rating']['satisfaction'] !=
                                              null
                                          ? double.parse(jobDetail['rating']
                                                  ['satisfaction']
                                              .toString())
                                          : 0.0
                                      : 0.0,
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: size.width,
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.02),
                            child: Text(
                              "Comment",
                              style: textTheme.subtitle2
                                  .copyWith(fontWeight: FontWeight.w700),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.01),
                            child: TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                  hintText: "No review given by buyer.",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(3.0)))),
                              controller: consumerCommentController,
                              minLines: 6,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                            ),
                          ),
                          jobProofMedia.length == 0
                              ? Column(
                                  children: [
                                    Container(
                                      width: size.width,
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.02),
                                      child: Text(
                                        "Images",
                                        style: textTheme.subtitle2.copyWith(
                                            fontWeight: FontWeight.w700),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext
                                                        context) =>
                                                    selectFileDialog("images"));
                                          },
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                              horizontal: size.width * 0.01,
                                            ),
                                            decoration: BoxDecoration(
                                                color:
                                                    text_field_background_color_seller,
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
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: imageFiles.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return Stack(
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                          horizontal:
                                                              size.width * 0.01,
                                                        ),
                                                        decoration: BoxDecoration(
                                                            color:
                                                                text_field_background_color_seller,
                                                            border: Border.all(
                                                                color: themeColor
                                                                    .accentColor),
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        8.0))),
                                                        height:
                                                            size.height * 0.1,
                                                        width: size.width * 0.2,
                                                        child: Image.file(
                                                          imageFiles[index],
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
                                                            imageFiles.removeAt(
                                                                index);
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
                                    Visibility(
                                        visible:
                                            imageError && imageFiles.isEmpty,
                                        child: Container(
                                          alignment: Alignment.topLeft,
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.height * 0.008,
                                              horizontal: size.width * 0.04),
                                          child: Text(
                                            "Upload atlest one image",
                                            textAlign: TextAlign.center,
                                            style: textTheme.caption
                                                .copyWith(color: error_color),
                                          ),
                                        )),
                                    Container(
                                      width: size.width,
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.02),
                                      child: Text(
                                        "Videos",
                                        style: textTheme.subtitle2.copyWith(
                                            fontWeight: FontWeight.w700),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext
                                                        context) =>
                                                    selectFileDialog("videos"));
                                          },
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                              horizontal: size.width * 0.01,
                                            ),
                                            decoration: BoxDecoration(
                                                color:
                                                    text_field_background_color_seller,
                                                border: Border.all(
                                                    color:
                                                        themeColor.accentColor),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0))),
                                            height: size.height * 0.1,
                                            width: size.width * 0.2,
                                            child: Icon(Icons.video_collection),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: size.height * 0.1,
                                            child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: thumbnails.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return Stack(
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                          horizontal:
                                                              size.width * 0.01,
                                                        ),
                                                        decoration: BoxDecoration(
                                                            color:
                                                                text_field_background_color_seller,
                                                            border: Border.all(
                                                                color: themeColor
                                                                    .accentColor),
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        8.0))),
                                                        height:
                                                            size.height * 0.1,
                                                        width: size.width * 0.2,
                                                        child: Image.memory(
                                                          thumbnails[index],
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
                                                            thumbnails.removeAt(
                                                                index);
                                                            videoFiles.removeAt(
                                                                index);
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
                                    Visibility(
                                        visible:
                                            videoError && videoFiles.isEmpty,
                                        child: Container(
                                          alignment: Alignment.topLeft,
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.height * 0.008,
                                              horizontal: size.width * 0.04),
                                          child: Text(
                                            "Upload atlest one video",
                                            textAlign: TextAlign.center,
                                            style: textTheme.caption
                                                .copyWith(color: error_color),
                                          ),
                                        )),
                                    Container(
                                      width: size.width * 0.9,
                                      height: size.height * 0.06,
                                      margin: EdgeInsets.symmetric(
                                          vertical: size.height * 0.02),
                                      child: RaisedButton(
                                        textColor: primary_font,
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.005),
                                        child: Text(
                                          "Submit Documents",
                                          textAlign: TextAlign.center,
                                        ),
                                        onPressed: () {
                                          uploadDocuments();
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          jobDetail['professional_rating'] == null
                              ? Column(
                                  children: [
                                    Container(
                                      width: size.width,
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.02),
                                      child: Text(
                                        "Give Review To Buyer",
                                        style: textTheme.subtitle2,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      child: GFRating(
                                        color: themeColor.accentColor,
                                        size: 35.0,
                                        value: rating,
                                        onChanged: (value) {
                                          setState(() {
                                            rating = value;
                                          });
                                        },
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: size.height * 0.01),
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Enter comment";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                            hintText: getTranslated(
                                                context, "write_comment_here"),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(3.0)))),
                                        controller: commentController,
                                        minLines: 6,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                      ),
                                    ),
                                    Container(
                                      width: size.width * 0.9,
                                      height: size.height * 0.06,
                                      margin: EdgeInsets.symmetric(
                                          vertical: size.height * 0.02),
                                      child: RaisedButton(
                                        textColor: primary_font,
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.005),
                                        child: Text(
                                          getTranslated(
                                              context, "post_comment"),
                                          textAlign: TextAlign.center,
                                        ),
                                        onPressed: () {
                                          if (orderCompleteForm.currentState
                                              .validate()) {
                                            postComment();
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                )
                              : Container()
                        ],
                      ),
                    ),
                  )));
  }
}
