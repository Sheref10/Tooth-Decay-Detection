import 'package:flutter/material.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tooth decay',
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  late File _image;
  late List _output;
  String label_output = '';
  String confidence_output = '';  
  final picker = ImagePicker(); 
  @override
  void initState() {

    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
  path: image.path,
  numResults: 3,
  threshold: 0.05,
  imageMean: 127.5,
  imageStd: 127.5,   

    );
    setState(() {
      _output = output!;
      _loading = false;
      label_output = 'Result : ${_output[0]['label']}';
                          
    });
  }


  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );
  }

  pickGalleryImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
    
  }

  pickCameraImage() async {
    var image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, 
          ),
          title: Text("Tooth Decay Detection", style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.deepOrangeAccent,
          centerTitle: true,
        ),
        
      body: ListView(
        
        children: [
          SizedBox(height: 25,),
          Container(
            child: Container(
              alignment: Alignment.center,


              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
             Container(
              alignment: Alignment.center,
              //  color: Colors.red,
                    height : 35,
                    child: Text('$label_output',style:TextStyle(fontSize:30,color:Colors.green),textAlign:TextAlign.center),
                    ),

          
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: _loading == true
                          ? Container(
                            color: Colors.deepOrangeAccent,
                            height: 350,
                            width : 400,
                            child: Center(child: Text("Select tooth image from :",style: TextStyle(fontSize: 20)),),
                          ) 
                          : Container(
                            padding: EdgeInsets.all(20),
                            height: 350,
                            width : 400,
                                child: ClipRRect(
                                      child: Image.file(
                                        _image,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
                    Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: Container(
                    height: 50,
                    width: 150,
                    color: Colors.redAccent,
                    child: FlatButton.icon(
                      onPressed: (){
                        pickCameraImage();
                      },
                      icon: Icon(Icons.camera_alt, color: Colors.white, size: 30,),
                      color: Colors.redAccent,
                      label: Text(
                        "Camera",style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                  ),
                ),
                Container(
                  height: 50,
                  width: 150,
                  color: Colors.tealAccent,
                  child: FlatButton.icon(
                    onPressed: (){
                      pickGalleryImage();
                    },
                    icon: Icon(Icons.file_upload, color: Colors.white, size: 30,),
                    color: Colors.blueAccent,
                    label: Text(
                      "Gallery",style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
