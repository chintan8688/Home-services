import 'package:audioplayers/audioplayers.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/main.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:home_services/src/widget/seller_drawer.dart';
import 'package:video_player/video_player.dart';

class JobBid extends StatefulWidget {
  final job, category;

  JobBid({this.job, this.category});

  @override
  State<StatefulWidget> createState() {
    return JobBidState();
  }
}

class JobBidState extends State<JobBid> with RouteAware {
  GlobalKey<ScaffoldState> key = GlobalKey();
  GlobalKey<FormState> formKey = GlobalKey();
  var job, category, isLoading = false;
  TextEditingController _priceController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();

  VideoPlayerController videoController;
  ChewieController chewieController;

  AudioPlayer audioPlayer = AudioPlayer();
  Duration duration = new Duration();
  Duration position = new Duration();

  bool isPlaying = false;
  String audioUrl;

  @override
  void initState() {
    super.initState();
    job = widget.job;
    category = widget.category;
    if (job['video'] != null) {
      videoController =
          VideoPlayerController.network(Constant.STORAGE_PATH + job['video'])
            ..initialize().then((_) {
              chewieController = ChewieController(
                  videoPlayerController: videoController,
                  autoPlay: false,
                  looping: false,
                  aspectRatio: videoController.value.aspectRatio,
                  allowPlaybackSpeedChanging: false,
                  allowFullScreen: false);
              setState(() {});
            });
    }
    if (job['audio'] != null) {
      audioUrl = Constant.STORAGE_PATH + job['audio'];
    }
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    videoController?.dispose();
    chewieController?.dispose();
    audioPlayer?.dispose();
    routeObserver.unsubscribe(this);
  }

  @override
  void didPushNext() {
    super.didPushNext();
    chewieController?.pause();
    audioPlayer?.pause();
    videoController?.pause();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    chewieController?.pause();
    audioPlayer?.pause();
    videoController?.pause();
  }

  createBid() {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      UserApiProvider.createBid(double.parse(_priceController.text.trim()),
              job['id'], _descriptionController.text.trim())
          .then((value) {
        setState(() {
          isLoading = false;
        });
        if (value['result'] && value['already_bid'] != 1) {
          showMessage(context, "Bid Placed Successfully");
        } else {
          showMessage(context, "You have already bid on this Job.");
        }
      });
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    return Scaffold(
        key: key,
        drawer: SellerDrawer(),
        appBar: primaryAppBar(context, "Place Job Bid", key),
        extendBodyBehindAppBar: isLoading,
        body: isLoading
            ? loadingData(context)
            : SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: size.height * 0.03),
                          child: RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: "Job",
                                  style: textTheme.headline6.copyWith(
                                      color: themeColor.primaryColor)),
                              TextSpan(
                                  text: " Information",
                                  style: textTheme.headline6)
                            ]),
                          ),
                        ),
                        Divider(
                          thickness: 1.0,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.009),
                          width: size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: size.width * 0.009),
                                  child: Text(
                                    job['name'],
                                    style: textTheme.subtitle1
                                        .copyWith(fontWeight: FontWeight.bold),
                                  )),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: size.width * 0.025),
                                  child: Text("Title:",
                                      style: textTheme.subtitle1)),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: size.width * 0.009),
                                  child: Text(
                                    job['title'],
                                    style: textTheme.caption.copyWith(
                                        color: grey_color,
                                        fontWeight: FontWeight.w700),
                                  )),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: size.width * 0.025),
                                  child: Text("Description:",
                                      style: textTheme.subtitle1)),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: size.width * 0.009),
                                  child: Text(
                                    job['description'],
                                    style: textTheme.caption.copyWith(
                                        color: grey_color,
                                        fontWeight: FontWeight.w700),
                                  )),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: size.width * 0.025),
                                  child: Text("Address:",
                                      style: textTheme.subtitle1)),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: size.width * 0.009),
                                  child: Text(
                                    job['address'],
                                    style: textTheme.caption.copyWith(
                                        color: grey_color,
                                        fontWeight: FontWeight.w700),
                                  )),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: size.width * 0.025),
                                  child: Text("Work Date:",
                                      style: textTheme.subtitle1)),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: size.width * 0.009),
                                  child: Text(
                                    '${job['work_date']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(
                                            color: grey_color,
                                            fontWeight: FontWeight.w700),
                                  )),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: size.width * 0.025),
                                  child: Text("Work Time:",
                                      style: textTheme.subtitle1)),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: size.width * 0.009),
                                  child: Text(
                                    '${job['work_time']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(
                                            color: grey_color,
                                            fontWeight: FontWeight.w700),
                                  )),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: size.width * 0.025),
                                  child: Text("Price:",
                                      style: textTheme.subtitle1)),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: size.width * 0.009),
                                  child: Text(
                                    '${job['price']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(
                                            color: grey_color,
                                            fontWeight: FontWeight.w700),
                                  )),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: size.width * 0.025),
                                  child: Text("Category:",
                                      style: textTheme.subtitle1)),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: size.width * 0.009),
                                  child: Text(
                                    '${category['name']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(
                                            color: grey_color,
                                            fontWeight: FontWeight.w700),
                                  )),
                              Visibility(
                                visible: job['video'] != null ? true : false,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                        top: size.width * 0.025),
                                    child: Text("Video:",
                                        style: textTheme.subtitle1)),
                              ),
                              job['video'] != null
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          top: size.width * 0.025),
                                      child: videoController.value.initialized
                                          ? SizedBox(
                                              height: size.height * 0.3,
                                              width: size.width,
                                              child: Chewie(
                                                controller: chewieController,
                                              ),
                                            )
                                          : Container())
                                  : Container(),
                              Visibility(
                                visible: job['audio'] != null ? true : false,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                        top: size.width * 0.025),
                                    child: Text("Audio:",
                                        style: textTheme.subtitle1)),
                              ),
                              Visibility(
                                visible: (job['audio'] != null ? true : false),
                                child: Container(
                                    padding: EdgeInsets.only(
                                        top: size.width * 0.025),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Slider.adaptive(
                                            activeColor:
                                                themeColor.primaryColor,
                                            min: 0.0,
                                            value:
                                                position.inSeconds.toDouble(),
                                            max: duration.inSeconds.toDouble(),
                                            onChanged: (double value) {
                                              setState(() {
                                                audioPlayer.seek(new Duration(
                                                    seconds: value.toInt()));
                                              });
                                            }),
                                        Container(
                                          child: InkWell(
                                            onTap: () {
                                              getAudio();
                                            },
                                            child: Icon(
                                              isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              size: 30,
                                              color: themeColor.primaryColor,
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.only(top: size.height * 0.025),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Price";
                                    }
                                    return null;
                                  },
                                  controller: _priceController,
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor:
                                          text_field_background_color_seller,
                                      suffixIconConstraints: BoxConstraints(
                                          maxHeight: 24, maxWidth: 44),
                                      suffixIcon: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Image.asset(
                                          "assets/icons/icon-lock.png",
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      hintText: "Bid Price",
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: size.width * 0.04)),
                                ),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.only(top: size.height * 0.02),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Description";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      hintText: "Description",
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)))),
                                  controller: _descriptionController,
                                  maxLines: 6,
                                  keyboardType: TextInputType.multiline,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: size.height * 0.025),
                                width: size.width * 0.9,
                                height: size.height * 0.06,
                                child: RaisedButton(
                                  textColor: primary_font,
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.005),
                                  child: Container(
                                    margin: EdgeInsets.only(left: 8),
                                    child: Text(
                                      "Bid on job",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  onPressed: () {
                                    createBid();
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
  }

  getAudio() async {
    if (isPlaying) {
      var res = await audioPlayer.pause();
      if (res == 1) {
        if (mounted) {
          setState(() {
            isPlaying = false;
          });
        }
      }
    } else {
      var res = await audioPlayer.play(audioUrl);
      if (res == 1) {
        if (mounted) {
          setState(() {
            isPlaying = true;
          });
        }
      }
      audioPlayer.onDurationChanged.listen((Duration dd) {
        if (mounted) {
          setState(() {
            duration = dd;
          });
        }
      });

      audioPlayer.onAudioPositionChanged.listen((Duration dd) {
        if (mounted) {
          setState(() {
            position = dd;
          });
        }
      });
      audioPlayer.onPlayerCompletion.listen((event) {
        if (mounted) {
          setState(() {
            isPlaying = false;
            duration = new Duration();
            position = new Duration();
          });
        }
      });
    }
  }
}
