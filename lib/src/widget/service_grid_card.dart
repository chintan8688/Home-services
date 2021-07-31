import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_services/src/screen/find_jobs/find_jobs.dart';
import 'package:home_services/src/screen/workers_location/workers_location.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/widget/common.dart';

class ServiceCard extends StatelessWidget {
  final category, userType;

  ServiceCard(this.category, this.userType);

  navigateToWorkersScreen(context) {
    if (userType == "buyer") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WorkersLocation(
                    headerTitle: category['name'],
                    category: category,
                  )));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FindJobs(
                    category: category,
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var themeColor = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {
        navigateToWorkersScreen(context);
      },
      child: Card(
        elevation: 10,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
          children: [
            Container(
                height: size.height * 0.11,
                width: size.width * 0.18,
                child: category["icon"] == null
                    ? Text(
                        category["name"],
                        textAlign: TextAlign.center,
                      )
                    : ImageIcon(
                        NetworkImage(Constant.STORAGE_PATH + category["icon"]),
                        color: userType == "seller"
                            ? themeColor.accentColor
                            : button_secondary,
                      )),
            Expanded(
              child: Container(
                color: userType == "seller"
                    ? themeColor.accentColor
                    : button_secondary,
                alignment: Alignment.center,
                child: Container(
                  width: size.width * 0.25,
                  child: Text(
                    category["name"],
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.subtitle2.copyWith(color: primary_font),
                    textAlign: TextAlign.center,
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
