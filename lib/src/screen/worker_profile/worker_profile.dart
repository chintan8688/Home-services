import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:home_services/src/screen/worker_service_detail/worker_service_detail.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/buyer_drawer.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class WorkerProfile extends StatefulWidget {
  final professional,
      category,
      scheduledJob,
      jobId,
      fromFavourite,
      services,
      fromBids;

  WorkerProfile(
      {Key key,
      @required this.professional,
      @required this.category,
      @required this.jobId,
      @required this.scheduledJob,
      @required this.fromFavourite,
      this.services,
      @required this.fromBids})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WorkerProfileState();
  }
}

class WorkerProfileState extends State<WorkerProfile> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  ScrollController _scrollController;
  var titleOpacity = 0.0, professional, badgeIcon;
  List worksData = [];

  navigateToServiceDetail(context, type) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => WorkerServiceDetail(
            professional: professional,
            type: type,
            category: widget.category,
            scheduledJob: widget.scheduledJob,
            jobId: widget.jobId,
            fromFavourite: widget.fromFavourite,
            services: widget.services,
            fromBids: widget.fromBids)));
  }

  @override
  void initState() {
    super.initState();
    getVideoThumbnails();
    professional = widget.professional;
    badgeIcon =
        professional['badge'] != null ? professional['badge']['icon'] : null;
    _scrollController = ScrollController()
      ..addListener(() {
        if (!_isAppBarExpanded) {
          setState(() {
            titleOpacity = 0;
          });
        } else {
          setState(() {
            titleOpacity = 1;
          });
        }
      });
  }

  getVideoThumbnails() async {
    for (var e in widget.professional['work']) {
      if (e['type'] == "video") {
        Uint8List bytes = await VideoThumbnail.thumbnailData(
          video: Constant.STORAGE_PATH + e['media'],
          imageFormat: ImageFormat.JPEG,
          maxWidth: 150,
          quality: 25,
        );
        worksData.add(bytes);
      } else {
        worksData.add(e);
      }
    }
  }

  bool get _isAppBarExpanded {
    return _scrollController.hasClients &&
        _scrollController.offset > (200 - kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    var kef = size.height > 690 ? 2 : 1.6;
    return Scaffold(
        key: key,
        drawer: BuyerDrawer(),
        //appBar: primaryAppBar(context, widget.title, key, Container()),
        body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30))),
                  expandedHeight: (size.height / kef) - 200,
                  floating: false,
                  pinned: true,
                  snap: false,
                  leading: IconButton(
                    icon: Image.asset(
                      "assets/icons/icon-drawer.png",
                      height: 24,
                      width: 24,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      collapseMode: CollapseMode.parallax,
                      title: Opacity(
                        opacity: titleOpacity,
                        child: Text(
                          professional["name"],
                          style: textTheme.headline6.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primary_font),
                        ),
                      ),
                      background: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: CachedNetworkImage(
                              imageUrl: Constant.STORAGE_PATH +
                                  professional['avatar'],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                              bottom: -1,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 20,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30))),
                              ))
                        ],
                      )),
                )
              ];
            },
            body: SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Text(
                                professional['name'],
                                style: textTheme.headline6,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: badgeIcon != null
                                  ? CachedNetworkImage(
                                      imageUrl:
                                          Constant.STORAGE_PATH + badgeIcon,
                                      height: 24,
                                      width: 24,
                                    )
                                  : Image.asset(
                                      "assets/icons/icon-badge.png",
                                      height: 24,
                                      width: 24,
                                    ),
                            ),
                            professional['badge'] != null
                                ? Container(
                                    margin: EdgeInsets.only(left: 10),
                                    decoration: BoxDecoration(
                                        color: themeColor.primaryColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0))),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      child: Text(
                                        professional['badge']['title'],
                                        style: textTheme.caption
                                            .copyWith(color: primary_font),
                                      ),
                                    ),
                                  )
                                : Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Text("-"),
                                  )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: size.height * 0.025),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Reviews",
                                    style: textTheme.subtitle1,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.005),
                                    child: Row(
                                      children: [
                                        GFRating(
                                          value: professional['rating']
                                                      ['average_rating'] !=
                                                  null
                                              ? double.parse(
                                                  professional['rating']
                                                          ['average_rating']
                                                      .toString())
                                              : 0.0,
                                          size: 16.0,
                                          color: themeColor.primaryColor,
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: size.width * 0.01),
                                          child: Text(
                                            '(${professional["rating"]['rating_count'].toString()})',
                                            style: textTheme.subtitle1.copyWith(
                                                color: themeColor.primaryColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getTranslated(context, "languages"),
                                    style: textTheme.subtitle1,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.005),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: professional['languages']
                                          .map<Widget>(
                                            (e) => Text(
                                              e['language'] + " " + e['level'],
                                              style: textTheme.subtitle1
                                                  .copyWith(
                                                      color: themeColor
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.w700),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Level",
                                    style: textTheme.subtitle1,
                                  ),
                                  professional['badge'] != null
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              top: size.height * 0.005),
                                          child: Text(
                                            professional['badge']['level'],
                                            style: textTheme.subtitle1.copyWith(
                                                color: themeColor.primaryColor,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        )
                                      : Container(
                                          margin: EdgeInsets.only(
                                              top: size.height * 0.005),
                                          child: Text(
                                            "-",
                                            style: textTheme.subtitle1.copyWith(
                                                color: themeColor.primaryColor,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        )
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: size.height * 0.01),
                          child: Text(professional["service_description"]),
                        ),
                        Divider(
                          color: secondary_color,
                          thickness: 1,
                        ),
                        Column(
                          children: professional['packages']
                              .map<Widget>(
                                (e) => Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.009),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: size.height * 0.01),
                                              child: RichText(
                                                  text: TextSpan(children: [
                                                TextSpan(
                                                    text: e['name'] == "Basic"
                                                        ? "JMD${e['price']}"
                                                        : e['name'] ==
                                                                'Standard'
                                                            ? "JMD${e['price']}"
                                                            : "JMD${e['price']}",
                                                    style: textTheme.headline6
                                                        .copyWith(
                                                            color: themeColor
                                                                .primaryColor)),
                                                TextSpan(
                                                    text: ' ${e['name']}',
                                                    style: textTheme.headline6),
                                              ])),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: size.height * 0.01),
                                              child: RichText(
                                                  text: TextSpan(children: [
                                                TextSpan(
                                                    text: ">",
                                                    style: textTheme.subtitle1
                                                        .copyWith(
                                                            color:
                                                                button_secondary,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                TextSpan(
                                                    text:
                                                        " Basic package up to 1 hour",
                                                    style: textTheme.subtitle1),
                                              ])),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: size.height * 0.01),
                                              child: RichText(
                                                  text: TextSpan(children: [
                                                TextSpan(
                                                    text: ">",
                                                    style: textTheme.subtitle1
                                                        .copyWith(
                                                            color:
                                                                button_secondary,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                TextSpan(
                                                    text:
                                                        " Additional ${e['additional_price']} JMD/ 1 Hour",
                                                    style: textTheme.subtitle1),
                                              ])),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          navigateToServiceDetail(
                                              context, e['name']);
                                        },
                                        child: Image.asset(
                                          "assets/icons/icon-arrow-button.png",
                                          height: 20,
                                          width: 20,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: size.width * 0.04),
                          child: Text(
                              getTranslated(context, "all_price_with_tax")),
                        ),
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: "Previous",
                              style: textTheme.headline6
                                  .copyWith(color: themeColor.primaryColor)),
                          TextSpan(text: ' Works', style: textTheme.headline6),
                        ])),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: size.height * 0.02),
                          height: size.height * 0.1,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: worksData.length,
                              itemBuilder: (context, int index) {
                                return GestureDetector(
                                  onTap: () async {
                                    await showDialog(
                                        context: key.currentContext,
                                        builder: (_) => ImageDialog(
                                            professional['work'], index));
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.01,
                                    ),
                                    decoration: BoxDecoration(
                                        color: text_field_background_color,
                                        border: Border.all(
                                            color: themeColor.accentColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0))),
                                    height: size.height * 0.1,
                                    width: size.width * 0.2,
                                    child: professional['work'][index]
                                                ['type'] ==
                                            "photo"
                                        ? CachedNetworkImage(
                                            imageUrl: Constant.STORAGE_PATH +
                                                professional['work'][index]
                                                    ['media'],
                                            fit: BoxFit.cover,
                                          )
                                        : Image.memory(
                                            worksData[index],
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                );
                              }),
                        )
                      ])),
            )));
  }
}

class ImageDialog extends StatefulWidget {
  final List work;
  final int index;

  ImageDialog(this.work, this.index);

  @override
  State<StatefulWidget> createState() {
    return ImageDialogState();
  }
}

class ImageDialogState extends State<ImageDialog> with RouteAware {
  List work;
  int index;
  VideoPlayerController videoController;
  ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    work = widget.work;
    index = widget.index;
    if (work[index]['type'] == "video") {
      videoController = VideoPlayerController.network(
          Constant.STORAGE_PATH + work[index]['media'])
        ..initialize().then((_) {
          chewieController = ChewieController(
              videoPlayerController: videoController,
              autoPlay: false,
              looping: false,
              aspectRatio: videoController.value.aspectRatio,
              allowPlaybackSpeedChanging: false,
              allowFullScreen: false);
          if (mounted) {
            setState(() {});
          }
        });
    }
  }

  @override
  void dispose() {
    super.dispose();
    videoController?.dispose();
    chewieController?.dispose();
  }

  setVideoController() {
    if (work[index]['type'] == "video") {
      videoController = VideoPlayerController.network(
          Constant.STORAGE_PATH + work[index]['media'])
        ..initialize().then((_) {
          chewieController = ChewieController(
              videoPlayerController: videoController,
              autoPlay: false,
              looping: false,
              aspectRatio: videoController.value.aspectRatio,
              allowPlaybackSpeedChanging: false,
              allowFullScreen: false);
          if (mounted) {
            setState(() {});
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            work[index]['type'] == "photo"
                ? CachedNetworkImage(
                    imageUrl: Constant.STORAGE_PATH + work[index]['media'],
                    fit: BoxFit.cover)
                : chewieController != null
                    ? Chewie(
                        controller: chewieController,
                      )
                    : Container(),
            Positioned(
              left: 5,
              bottom: MediaQuery.of(context).size.height * 0.3 / 2.5,
              child: GestureDetector(
                onTap: () {
                  if (mounted) {
                    setState(() {
                      if (index != 0) {
                        index--;
                        chewieController?.pause();
                        if (work[index]['type'] == "video") {
                          setVideoController();
                        }
                      } else {
                        index = (work.length - 1);
                        chewieController?.pause();
                        if (work[index]['type'] == "video") {
                          setVideoController();
                        }
                      }
                    });
                  }
                },
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      color: grey_color.withOpacity(0.4),
                      shape: BoxShape.circle),
                  child: Icon(
                    Icons.arrow_back_ios_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 5,
              bottom: MediaQuery.of(context).size.height * 0.3 / 2.5,
              child: GestureDetector(
                onTap: () {
                  if (mounted) {
                    setState(() {
                      if (index == (work.length - 1)) {
                        index = 0;
                        chewieController?.pause();
                        if (work[index]['type'] == "video") {
                          setVideoController();
                        }
                      } else {
                        index++;
                        chewieController?.pause();
                        if (work[index]['type'] == "video") {
                          setVideoController();
                        }
                      }
                    });
                  }
                },
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      color: grey_color.withOpacity(0.4),
                      shape: BoxShape.circle),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
