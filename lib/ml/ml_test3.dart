import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(MyApp3());

class MyApp3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Food Detector'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  bool predictionStarted = false;
  bool predictionComplete = false;
  var predictionResult = 'Please wait....';
  static const _CLASSIFIER_CHANNEL = const MethodChannel('classifier');
  static const _START_CLASSIFY = 'startClassification';
  static const _DONE_CLASSIFY = 'doneClassification';

  void _takeImage() async {
    final File imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    _startClassify(imageFile);
  }
  void _startClassify(final File imageFile) {
    _CLASSIFIER_CHANNEL.invokeMethod(_START_CLASSIFY, {
      'imageBytes': imageFile.readAsBytesSync()
    });
    _CLASSIFIER_CHANNEL.setMethodCallHandler(_onClassifyComplete);
  }

  /// Choose an image from the device's gallery
  void _pickImage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    _startClassify(imageFile);
  }

// Classification result sorted by confidence
  final SplayTreeMap _classificationResult = SplayTreeMap((a, b) => b.compareTo(a));
  /// Complete classification callback
  Future<dynamic> _onClassifyComplete(MethodCall methodCall) {

    // Classification failed
    if(methodCall.method != _DONE_CLASSIFY || methodCall.arguments.toString() == '{}') {
      setState(() {
        // TODO Handle failed classification
      });
    }

    // Success, format & display results
    else {
      final List<String> classifications = methodCall.arguments.toString()
          .replaceAll('{', '')
          .replaceAll('}', '')
          .replaceAll(' ', '')
          .split(',');

      // Clear previous classification results
      _classificationResult.clear();

      // Map labels to confidence values
      for (int i = 0; i < classifications.length; i++) {

        // Get label and confidence
        final List<String> parts = classifications[i].split(':');
        final String label = parts[0];
        final String confidence = parts[1];

        // Parse to int so tree map can use it as a key
        final int conf = int.parse((double.parse(confidence) * 100).toStringAsFixed(0));
        _classificationResult[conf] = label;
      }

      setState(() {
        // TODO Display classification results

        int numResultsDisplaying = 0;

        for (MapEntry entry in _classificationResult.entries) {
          final String cParsed = entry.key.toString();
          final String confidence = cParsed.substring(0, 2) + '.' + cParsed.substring(2, cParsed.length) + '%';
         // items.add(Text(entry.value));
          //items.add(Text(confidence + '\n'));

          // Show only up to 3 results
          numResultsDisplaying++;
          if (numResultsDisplaying == 3) {
            break;
          }
        }
      });
    }
  }

  Future getImage() async {
    setState(() {
      predictionStarted = false;
      predictionComplete = false;
    });

    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
      predictionStarted = true;
    });

    //post image
    List<int> imageBytes = image.readAsBytesSync();
    String base64Image = base64.encode(imageBytes);

    print(base64Image);

    Map<String, String> headers = {"Accept": "application/json"};
    Map body = {"image": base64Image};

    var response = await http.post('http://104.198.180.232/food_predict.php',
        body: body, headers: headers);

    setState(() {
      predictionResult = response.body;
      predictionComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Text(
              'Push the camera button',
              textAlign: TextAlign.center,
            ),
            RaisedButton(
              onPressed: getImage,
              child: Text('Camera'),
            ),
            (_image != null)
                ? Image.file(
                    _image,
                    scale: 20,
                  )
                : Text('No Image Picked'),
            predictionBody()
          ],
        ),
      ),
    );
  }

  Widget predictionBody() {
    var predictionText = (predictionComplete) ? 'Result' : 'Prediction started';
    if (predictionStarted) {
      return Column(
        children: <Widget>[
          Divider(),
          Text(predictionText),
          Text(predictionResult)
        ],
      );
    } else {
      return Container();
    }
  }
}
