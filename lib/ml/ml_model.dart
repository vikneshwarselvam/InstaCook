import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(MyApp4());
}

const String ssd = "SSD MobileNet";
const String yolo = "Tiny YOLOv2";
const String food_model = "Food_model";

class MyApp4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TfliteHome(),
    );
  }
}

class TfliteHome extends StatefulWidget {
  @override
  _TfliteHomeState createState() => _TfliteHomeState();
}

class _TfliteHomeState extends State<TfliteHome> {
  String _model = food_model;
  File _image;

  double _imageWidth;
  double _imageHeight;
  bool _busy = false;
  List _outputs;
  //File _image;
  bool _loading = false;

  List _recognitions;

  @override
  void initState() {
    super.initState();
    _busy = true;

    loadModel().then((val) {
      setState(() {
        _busy = false;
      });
    });
  }

  loadModel() async {
    Tflite.close();
    try {
      String res;
      if (_model == yolo) {
        res = await Tflite.loadModel(
          model: "assets/yolov2_tiny.tflite",
          labels: "assets/yolov2_tiny.txt",
        );
      } else if (_model == ssd) {
        res = await Tflite.loadModel(
          model: "assets/ssd_mobilenet.tflite",
          labels: "assets/ssd_mobilenet.txt",
        );
      }
      else {
        res = await Tflite.loadModel(
          model: "assets/food_model_tflite/model_unquant.tflite",
          labels: "assets/food_model_tflite/labels.txt",
        );
      }
      print(res);
    } on PlatformException {
      print("Failed to load the model");
    }
  }

  selectFromImagePicker() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _busy = true;
    });
    predictImage(image);
  }

  predictImage(File image) async {
    if (image == null) return;

    if (_model == yolo) {
      await yolov2Tiny(image);
    } else {
      await foodModelCustom(image);
    }

    FileImage(image)
        .resolve(ImageConfiguration())
        .addListener((ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageWidth = info.image.width.toDouble();
        _imageHeight = info.image.height.toDouble();
      });
    })));

    setState(() {
      _image = image;
      _busy = false;
    });
  }
  foodModelCustom(File image) async{

    var recognitions = await Tflite.runModelOnImage(
        path: image.path,   // required
        imageMean: 127.5,   // defaults to 117.0
        imageStd: 127.5,  // defaults to 1.0
        numResults: 2,    // defaults to 5
        threshold: 0.2,   // defaults to 0.1
        asynch: true      // defaults to true
    );
    setState(() {
      _recognitions = recognitions;
    });
  }

  Future recognizeImageBinary(File image) async{
    Uint8List imageToByteListFloat32(
        img.Image image, int inputSize, double mean, double std) {
      var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
      var buffer = Float32List.view(convertedBytes.buffer);
      int pixelIndex = 0;
      for (var i = 0; i < inputSize; i++) {
        for (var j = 0; j < inputSize; j++) {
          var pixel = image.getPixel(j, i);
          buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
          buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
          buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
        }
      }
      return convertedBytes.buffer.asUint8List();
    }
    var imageBytes = (await rootBundle.load(image.path)).buffer;
    img.Image oriImage  = img.decodeJpg(imageBytes.asUint8List());
    img.Image resizedImage = img.copyResize(oriImage);
    var recognitions = await Tflite.runModelOnBinary(
        binary: imageToByteListFloat32(resizedImage, 224, 127.5,127.5),
        numResults: 1,
        threshold: 0.05,
    );
    setState(() {
      _recognitions = recognitions;
    });

  }

  foodModel(File image) async{
    try {
      //var imageBytes =
       //   (await rootBundle.load(image.path)).buffer;

     // img.Image image1 = img.decodeJpg(imageBytes);
      img.Image image2 = img.decodeImage(image.readAsBytesSync());
     // image = img.copyResize(image, detector.imageSize, detector.imageSize); //stretch

      // Resize the image to the expected size for your model
     // image = img.copyResize(image, detector.imageSize, detector.imageSize); //stretch

    //  var recognitions = await FlutterTfliteDetector.recognizeImage(image);
      Uint8List imageToByteListFloat32(
          img.Image image, int inputSize, double mean, double std) {
        var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
        var buffer = Float32List.view(convertedBytes.buffer);
        int pixelIndex = 0;
        for (var i = 0; i < inputSize; i++) {
          for (var j = 0; j < inputSize; j++) {
            var pixel = image.getPixel(j, i);
            buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
            buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
            buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
          }
        }
        return convertedBytes.buffer.asUint8List();
      }
     // Image image1 = Image.file(image);
     // img.Image image2 = image1;
      var recognitions = await Tflite.runModelOnBinary(
          binary: imageToByteListFloat32(image2, 224, 127.5, 127.5),// required
          numResults: 6,    // defaults to 5
          threshold: 0.05,  // defaults to 0.1
          asynch: true      // defaults to true
      );



      Uint8List imageToByteListUint8(img.Image image, int inputSize) {
        var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
        var buffer = Uint8List.view(convertedBytes.buffer);
        int pixelIndex = 0;
        for (var i = 0; i < inputSize; i++) {
          for (var j = 0; j < inputSize; j++) {
            var pixel = image.getPixel(j, i);
            buffer[pixelIndex++] = img.getRed(pixel);
            buffer[pixelIndex++] = img.getGreen(pixel);
            buffer[pixelIndex++] = img.getBlue(pixel);
          }
        }
        return convertedBytes.buffer.asUint8List();
      }
      setState(() {
        _recognitions = recognitions;
      });
      return true;

    } on PlatformException {
      debugPrint('Unable to recognize image');
    }
    return false;

  }

  yolov2Tiny(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
        path: image.path,
        model: "YOLO",
        threshold: 0.3,
        imageMean: 0.0,
        imageStd: 255.0,
        numResultsPerClass: 1);

    setState(() {
      _recognitions = recognitions;
    });
  }

  ssdMobileNet(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
        path: image.path, numResultsPerClass: 1);

    setState(() {
      _recognitions = recognitions;
    });
  }

  List<Widget> showResults(){
    if (_recognitions == null) return [];

    return _recognitions.map((re) {
      return Text(
            "${re["label"]} ${(re["confidence"] * 100)
                .toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint(),
              color: Colors.white,
              fontSize: 15,
            ),
      );
    }).toList();
        }


  List<Widget> renderBoxes(Size screen) {
    if (_recognitions == null) return [];
    if (_imageWidth == null || _imageHeight == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight / _imageHeight * screen.width;

    Color blue = Colors.red;

    return _recognitions.map((re) {
      return Positioned(
        left: re["rect"]["x"] * factorX,
        top: re["rect"]["y"] * factorY,
        width: re["rect"]["w"] * factorX,
        height: re["rect"]["h"] * factorY,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                color: blue,
                width: 3,
              )),
          child: Text(
            "${re["detectedClass"]} ${(re["confidenceInClass"] * 100)
                .toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()
                ..color = blue,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;

    List<Widget> stackChildren = [];

    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      child: _image == null ? Text("No Image Selected") : Image.file(_image),
    ));

    stackChildren.addAll(showResults());

    if (_busy) {
      stackChildren.add(Center(
        child: CircularProgressIndicator(),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Food Detector"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.image),
        tooltip: "Pick Image from camera",
        onPressed: selectFromImagePicker,
      ),
      body: _busy
          ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      )
          : Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null ? Container() : Image.file(_image),
            SizedBox(
              height: 20,
            ),
            _recognitions != null
                ? Text(
              "${_recognitions[0]["label"]}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
              ),
            )
                : Container()
          ],
        ),
      ),
    );
  }
}