import 'dart:core';

import 'package:flutter/material.dart';
import './Constant/Constant.dart';
import './Screens/SplashScreen.dart';
import './Screens/ChatScreen.dart';


class ChatBotMain extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<ChatBotMain> {
    @override
  initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return new MaterialApp(
    title: 'Cooking Chatbot',
    debugShowCheckedModeBanner: false,
    theme: new ThemeData(
      accentColor: Colors.blue,
      primaryColor: Colors.white,
      primaryColorDark: Colors.white,
      fontFamily: 'Gamja Flower',
    ),
    home: new SplashScreen(),
    routes: <String, WidgetBuilder>{
      ANIMATED_SPLASH: (BuildContext context) => new SplashScreen(),
      CHAT_SCREEN: (BuildContext context) => new MyChatScreen()
    },
    );
  }
}