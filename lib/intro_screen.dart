import 'package:flutter/cupertino.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';


class IntroScreen extends StatefulWidget {
  @override
  IntroScreenState createState() => new IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "MEALS CATEGORY",
        description: "You can select the cuisine of the food and you can click food detector and chatbot from here",
        pathImage: "assets/meals_screen.jpg",
        backgroundColor: Color(0xff4D00FF),
      ),
    );
    slides.add(
      new Slide(
        title: "FOOD DETECTOR",
        description: "You can either use camera or gallery to compare your results with original food",
        pathImage: "assets/food_detector.jpg",
        backgroundColor: Color(0xffEC00FF),
      ),
    );
    slides.add(
      new Slide(
        title: "CHATBOT",
        description:
        "You can chat with the chatbot and find recipes and ask your doubts to it",
        pathImage: "assets/chatbot.jpg",
        backgroundColor: Color(0xffFF0083),
      ),
    );
  }

   void onDonePress() {
    // Do what you want
    Navigator.of(context).pushNamed('/tab_screen');
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      slides: this.slides,
      onDonePress: onDonePress,
    );
  }
}
