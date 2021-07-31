import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_services/main.dart';
import 'package:home_services/src/screen/splash/splash_screen.dart';
import 'package:home_services/src/theme/theme.dart';
import 'package:home_services/src/utills/app_prefrences.dart';
import 'package:home_services/src/utills/language.dart';
import 'package:home_services/src/utills/localizations.dart';
import 'package:overlay_support/overlay_support.dart';

class HomeServices extends StatefulWidget {
  static void setLocale(BuildContext context, Locale locale) {
    HomeServicesAppState state =
        context.findAncestorStateOfType<HomeServicesAppState>();
    state.setLocale(locale);
  }

  static void setAppTheme(BuildContext context, String userType) {
    HomeServicesAppState state =
        context.findAncestorStateOfType<HomeServicesAppState>();
    state.setAppTheme(userType);
  }

  ThemeData _buildBuyerTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      accentColor: accent_color,
      primaryColor: primary_color,
      scaffoldBackgroundColor: primary_background_color,
      appBarTheme: AppBarTheme(
        color: primary_color,
        centerTitle: true,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: primary_font),
        textTheme: textTheme.copyWith(
            headline6: GoogleFonts.roboto(
                fontSize: 20,
                color: primary_font,
                fontWeight: FontWeight.bold)),
      ),
      buttonTheme: buttonThemeDataBuyer,
      buttonBarTheme: base.buttonBarTheme.copyWith(
        buttonTextTheme: ButtonTextTheme.accent,
      ),
      textTheme: getTextTheme(base.primaryTextTheme),
      primaryTextTheme: getTextTheme(base.primaryTextTheme).apply(
        bodyColor: primary_font,
        displayColor: primary_font,
      ),
      accentTextTheme: textTheme,
      textSelectionColor: primary_color.withOpacity(0.4),
      errorColor: error_color,
      cardTheme: CardTheme(
          color: primary_background_color,
          elevation: 3,
          shadowColor: shadow_color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
    );
  }

  ThemeData _buildSellerTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      accentColor: accent_color_seller,
      primaryColor: primary_color_seller,
      scaffoldBackgroundColor: primary_background_color_seller,
      appBarTheme: AppBarTheme(
        color: primary_color_seller,
        centerTitle: true,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: primary_font_seller),
        textTheme: textTheme.copyWith(
            headline6: GoogleFonts.roboto(
                fontSize: 20,
                color: primary_font_seller,
                fontWeight: FontWeight.bold)),
      ),
      buttonTheme: buttonThemeDataSeller,
      buttonBarTheme: base.buttonBarTheme.copyWith(
        buttonTextTheme: ButtonTextTheme.accent,
      ),
      textTheme: getTextTheme(base.primaryTextTheme),
      primaryTextTheme: getTextTheme(base.primaryTextTheme).apply(
        bodyColor: primary_font_seller,
        displayColor: primary_font_seller,
      ),
      accentTextTheme: textTheme,
      textSelectionColor: primary_color.withOpacity(0.4),
      errorColor: error_color_seller,
      cardTheme: CardTheme(
          color: primary_background_color_seller,
          elevation: 3,
          shadowColor: shadow_color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return HomeServicesAppState();
  }
}

class HomeServicesAppState extends State<HomeServices> {
  Locale _locale;
  ThemeData _themeData;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  setAppTheme(String userType) {
    setState(() {
      if (userType == "buyer") {
        _themeData = widget._buildBuyerTheme();
      } else {
        _themeData = widget._buildSellerTheme();
      }
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    getAppTheme().then((theme) {
      if (theme == "buyer") {
        setState(() {
          this._themeData = widget._buildBuyerTheme();
        });
      } else {
        this._themeData = widget._buildSellerTheme();
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Click Away',
        theme: _themeData,
        locale: _locale,
        supportedLocales: [const Locale('en', 'US'), const Locale('ar', 'SA')],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          for (var locale in supportedLocales) {
            if (locale.languageCode == deviceLocale.languageCode &&
                locale.countryCode == deviceLocale.countryCode) {
              return deviceLocale;
            }
          }
          return supportedLocales.first;
        },
        navigatorObservers: [routeObserver],
        navigatorKey: navigatorKey,
        home: SplashScreen(),
      ),
    );
  }
}
