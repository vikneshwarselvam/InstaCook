import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../dummy_data.dart';

Future sleep1() {
  return new Future.delayed(const Duration(seconds: 10), () => "5");
}

class MealDetailScreen extends StatelessWidget {
  static const routeName = '/meal-detail';
  FlutterTts flutterTts;
  final Function toggleFavorite;
  final Function isFavorite;
  //int i=0;
  int count=0;
  // inittts();

  MealDetailScreen(this.toggleFavorite, this.isFavorite);

  Widget buildSectionTitle(BuildContext context, String text) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.title,
      ),
    );
  }

  Future<dynamic> _read(String text) async {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.3);
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(1.0);

    await flutterTts.stop();
    if (text != null && text.isNotEmpty) {
      await flutterTts.speak(text.toLowerCase());
    }
  }

  Widget buildContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      height: 150,
      width: 300,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mealId = ModalRoute.of(context).settings.arguments as String;
    final selectedMeal = DUMMY_MEALS.firstWhere((meal) => meal.id == mealId);
    return Scaffold(
        appBar: AppBar(
          title: Text('${selectedMeal.title}'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 300,
                width: double.infinity,
                child: Image.network(
                  selectedMeal.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              buildSectionTitle(context, 'Ingredients'),
              buildContainer(
                ListView.builder(
                  itemBuilder: (ctx, index) => Card(
                    color: Theme.of(context).accentColor,
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: Text(selectedMeal.ingredients[index])),
                  ),
                  itemCount: selectedMeal.ingredients.length,
                ),
              ),
              buildSectionTitle(context, 'Steps'),
              buildContainer(
                ListView.builder(
                  itemBuilder: (ctx, index) => Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          child: Text('# ${(index + 1)}'),
                        ),
                        title: Text(
                          selectedMeal.steps[index],
                        ),
                      ),
                      Divider()
                    ],
                  ),
                  itemCount: selectedMeal.steps.length,
                ),
              ),
            ],
          ),
        ),
        //  floatingActionButton: FloatingActionButton(
        //  child: Icon(
        //  isFavorite(mealId) ? Icons.star : Icons.star_border,
        //),
        //onPressed: () => toggleFavorite(mealId),
        //),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              
              FloatingActionButton(
                onPressed: () {
                  count = count -2;
                  _read(selectedMeal.steps[count]);
                },
                backgroundColor: Colors.blue,
                child: Icon(Icons.chevron_left),
                heroTag: null,
              ),
              FloatingActionButton(
                onPressed: () {
                  
                  _read(selectedMeal.steps[count]);
                  count = count +1;
                },
                backgroundColor: Colors.blue,
                child: Icon(Icons.chevron_right),
                heroTag: null,
              )
            ],
          ),
        ));
  }
}
