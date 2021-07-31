import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/screen/worker_profile/worker_profile.dart';
import 'package:home_services/src/widget/common.dart';

class ProfessionalList extends StatelessWidget {
  final List professionals;

  ProfessionalList({this.professionals});

  navigateToWorkersScreen(context, professional) {
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: professionals.length,
        itemBuilder: (BuildContext context, int index) {
          var professional = professionals[index];
          return GestureDetector(
            onTap: () {
              navigateToWorkersScreen(context, professional);
            },
            child: Card(
              elevation: 0,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              margin: EdgeInsets.only(right: size.width * 0.05),
              child: Column(
                children: [
                  Container(
                    height: size.height * 0.18,
                    width: size.width * 0.36,
                    child: CachedNetworkImage(
                      imageUrl: Constant.STORAGE_PATH + professional['avatar'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        professional['name'],
                        style: textTheme.subtitle2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
