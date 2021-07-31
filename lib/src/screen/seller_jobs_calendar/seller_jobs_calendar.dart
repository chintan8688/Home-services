import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/network/api_provider.dart';
import 'package:home_services/src/screen/order_completed_seller/order_completed_seller.dart';
import 'package:home_services/src/screen/order_summary_seller/order_summary_seller.dart';
import 'package:home_services/src/screen/work_in_progress/work_in_progress.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/widget/common.dart';
import 'package:home_services/src/widget/seller_drawer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/standalone.dart' as tz;

class SellerJobsCalendar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SellerJobsCalendarState();
  }
}

class SellerJobsCalendarState extends State<SellerJobsCalendar>
    with RouteAware {
  GlobalKey<ScaffoldState> key = GlobalKey();
  CalendarController controller = CalendarController();
  Map<DateTime, List> events = {};
  List selectedEvents = [], jobList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getJobList();
  }

  getJobList() {
    var jamaica = tz.getLocation('America/Jamaica');
    var jamaicaCurrentTime = tz.TZDateTime.now(jamaica);
    UserApiProvider.professionalJobs().then((value) {
      if (value['result']) {
        List data = value['professional_jobs'] as List;
        List dates =
            data.map((e) => e['work_date'].toString()).toSet().toList();
        for (var i = 0; i < dates.length; i++) {
          List dataList = [];
          for (var j = 0; j < data.length; j++) {
            if (dates[i] == data[j]['work_date'].toString()) {
              dataList.add(data[j]);
            }
          }
          events[DateTime.parse(dates[i].toString())] = dataList;
        }
        setState(() {
          jobList = value['professional_jobs'];
          selectedEvents = events[jamaicaCurrentTime] ?? [];
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  void didPushNext() {
    super.didPushNext();
    controller?.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    controller?.dispose();
  }

  void onDaySelected(DateTime day, List events, List holidays) {
    setState(() {
      selectedEvents = events;
    });
  }

  navigateToJobScreen(status, job) {
    if (status == "Completed") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OrderCompletedSeller(
                  consumerId: job['consumer_id'],
                  jobId: job['job_id'],
                  fromJobs: true)));
    } else if (status == "Incomplete") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OrderSummarySeller(
                    consumerId: job['consumer_id'],
                    jobId: job['job_id'],
                  )));
    } else if (status == "In progress") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WorkInProgress(
                    consumerId: job['consumer_id'],
                    jobId: job['job_id'],
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    return Scaffold(
      key: key,
      appBar: primaryAppBar(context, "Your Calendar", key),
      drawer: SellerDrawer(),
      extendBodyBehindAppBar: isLoading,
      body: isLoading
          ? loadingData(context)
          : Column(
              children: [
                TableCalendar(
                  events: events,
                  calendarController: controller,
                  onDaySelected: onDaySelected,
                  rowHeight: 50,
                  availableCalendarFormats: {
                    CalendarFormat.month: '',
                  },
                  headerStyle: HeaderStyle(
                      centerHeaderTitle: true,
                      formatButtonVisible: true,
                      headerPadding: EdgeInsets.symmetric(vertical: 5),
                      headerMargin: EdgeInsets.only(top: 5)),
                  builders: CalendarBuilders(
                    selectedDayBuilder: (context, date, _) {
                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        color: themeColor.accentColor,
                        width: 100,
                        height: 100,
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: textTheme.subtitle2
                                .copyWith(color: primary_font),
                          ),
                        ),
                      );
                    },
                    todayDayBuilder: (context, date, _) {
                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        color: themeColor.primaryColor,
                        width: 100,
                        height: 100,
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: textTheme.subtitle2
                                .copyWith(color: primary_font),
                          ),
                        ),
                      );
                    },
                    markersBuilder: (context, date, events, holidays) {
                      final children = <Widget>[];

                      if (events.isNotEmpty) {
                        children.add(
                          Positioned(
                            right: 1,
                            bottom: 1,
                            child: _buildEventsMarker(date, events),
                          ),
                        );
                      }

                      return children;
                    },
                  ),
                ),
                SizedBox(height: 5.0),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: Divider(
                    thickness: 5.0,
                  ),
                ),
                Expanded(child: _buildEventList()),
              ],
            ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: controller.isSelected(date)
            ? Colors.brown[500]
            : controller.isToday(date)
                ? Colors.brown[300]
                : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var themeColor = Theme.of(context);
    return ListView(
      children: selectedEvents
          .map((job) => Container(
                margin: EdgeInsets.only(bottom: size.height * 0.01),
                child: GestureDetector(
                  onTap: () {
                    navigateToJobScreen(job['status'], job);
                  },
                  child: Card(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.015),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: size.width * 0.8,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                      width: size.width * 0.6,
                                      padding: EdgeInsets.only(
                                          left: size.width * 0.025),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: size.height * 0.01),
                                            child: Text(
                                              job['name'],
                                              style: textTheme.subtitle2
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: themeColor.primaryColor,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0))),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 3),
                                              child: Text(
                                                "JMD${job['package_price']} ${job['package_name']}",
                                                style: textTheme.caption
                                                    .copyWith(
                                                        color: primary_font),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                padding:
                                    EdgeInsets.only(right: size.width * 0.03),
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
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.008),
                            child: Divider(),
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: size.width * 0.2,
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.005),
                                    child: Text(
                                      "Category",
                                      style: textTheme.caption.copyWith(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Container(
                                    width: size.width * 0.2,
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.005),
                                    child: Text(
                                      job['category'],
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
                                      "Order Type",
                                      style: textTheme.caption.copyWith(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Container(
                                    width: size.width * 0.2,
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.005),
                                    child: Text(
                                      job['type'] == "direct"
                                          ? "Requested Now"
                                          : "Schedule",
                                      style: textTheme.caption.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: themeColor.primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: size.width * 0.2,
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.005),
                                    child: Text(
                                      "Status",
                                      style: textTheme.caption.copyWith(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Container(
                                    width: size.width * 0.2,
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.005),
                                    child: Text(
                                      job['status'],
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
                                      "Order Date",
                                      style: textTheme.caption.copyWith(
                                          fontWeight: FontWeight.w500),
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
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
