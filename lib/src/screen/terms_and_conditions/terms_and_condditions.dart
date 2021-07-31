import 'package:flutter/material.dart';
import 'package:home_services/src/screen/otp_verification/otp_verification.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/widget/common.dart';

class TermsAndConditions extends StatefulWidget {
  final email, phone;

  TermsAndConditions({this.email, this.phone});

  @override
  State<StatefulWidget> createState() {
    return TermsAndConditionsState();
  }
}

class TermsAndConditionsState extends State<TermsAndConditions> {
  GlobalKey<ScaffoldState> key = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: primaryAppBar(context, "terms_and_conditions", key),
      body: Container(
        width: size.width,
        height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(size.height * 0.015),
                child: SingleChildScrollView(
                  child: Text(
                      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum. It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like)."),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(size.height * 0.015),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: size.width * 0.45,
                    height: size.height * 0.06,
                    child: RaisedButton(
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.005),
                      child: Text(
                        getTranslated(context, "i_agree"),
                        textAlign: TextAlign.center,
                      ),
                      textColor: primary_font,
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OtpVerification(
                                      email: widget.email,
                                      phone: widget.phone,
                                      fromVerification: false,
                                    )));
                      },
                    ),
                  ),
                  Container(
                    width: size.width * 0.45,
                    height: size.height * 0.06,
                    child: RaisedButton(
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.005),
                      color: primary_color_seller,
                      child: Text(
                        getTranslated(context, "i_disagree"),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
