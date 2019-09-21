import 'package:flutter/material.dart';
import 'Presentation/HomeScene/HomeScene.dart';
import 'package:raul_twitch_swift_kotlin/Domain/FlutterRepoChannelC3.dart';

void main() {
  /// Start listener for FlutterRepoChannel from the Native presentation layer
  FlutterRepoChannel().setupNativePresentationRequestsHandler();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twitch Code Test',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: Color(0xff5b5089),
        scaffoldBackgroundColor: Color(0xff252131),
        accentColor: Color(0xff6b6094),
        backgroundColor: Color(0xff252131)
      ),
      home: HomeScene(title: 'Twitch Top Games'),
    );
  }
}