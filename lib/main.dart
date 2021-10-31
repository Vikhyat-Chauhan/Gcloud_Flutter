import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'gcloud.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        title: 'Upload to Google Cloud',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final picker = ImagePicker();
  GcloudApi gcloud = new GcloudApi();
  late List<XFile> _imagesfile = [];

  bool isUploaded = false;
  bool loading = false;
  bool displayimage = true;

  @override
  void initState() {
    super.initState();
    gcloud.spawnclient();
  }

  void _getImage() async {
    final List<XFile>? images = await ImagePicker().pickMultiImage();
    images!.forEach((element) {
      _imagesfile.add(element);
    });
    setState(() {
      if (_imagesfile.length > 0) {
        isUploaded = false;
        displayimage = false;
      } else {
        print('No image selected.');
      }
    });
  }

  void _saveImage() async {
    setState(() {
      loading = true;
    });

    // Upload to Google cloud
    if (_imagesfile != null) {
      await gcloud.saveMany(_imagesfile);
      setState(() {
        _imagesfile.clear();
        loading = false;
        isUploaded = true;
      });
    }
  }

  void _displayImages() async {
    _imagesfile = await gcloud.readSave(
      'Wedding Ceremony/',
    );
    setState(() {
      displayimage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            //Image(image: Image.memory(x),),
            Center(
                child: (displayimage)
                    ? Text('No image selected.')
                    : Stack(
                        children: [
                          Column(
                            children: [
                              for (int i = 0; i < _imagesfile.length; i++)
                                Image.memory(File(_imagesfile[i].path)
                                    .readAsBytesSync()),
                            ],
                          ),
                          if (loading)
                            Center(
                              child: CircularProgressIndicator(),
                            ),
                          isUploaded
                              ? Center(
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.green,
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 60,
                                    ),
                                  ),
                                )
                              : Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FlatButton(
                                    color: Colors.blueAccent,
                                    textColor: Colors.white,
                                    onPressed: _saveImage,
                                    child: Text('Save to cloud'),
                                  ),
                                )
                        ],
                      )),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: _getImage,
                  tooltip: 'Upload images',
                  child: Icon(Icons.cloud_upload),
                ),
                FloatingActionButton(
                  onPressed: _displayImages,
                  tooltip: 'View image',
                  child: Icon(Icons.cloud_download),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
