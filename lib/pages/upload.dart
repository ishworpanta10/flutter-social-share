import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_share/models/user.dart';
import 'package:social_share/pages/home.dart';
import 'package:social_share/widgets/progress.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController _locationController = TextEditingController();
  TextEditingController _captionController = TextEditingController();
  File _image;
  final _picker = ImagePicker();
  bool isUploading = false;
  //for unique post id
  String postId = Uuid().v4();

  Future handleTakePhoto() async {
    Navigator.pop(context);
    try {
      final PickedFile pickedFile = await _picker.getImage(
          source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
      setState(() {
        _image = File(pickedFile.path);
      });
    } catch (e) {
      print(e);
    }
  }

  Future handleTakeFromGallery() async {
    Navigator.pop(context);
    try {
      final PickedFile pickedFile =
          await _picker.getImage(source: ImageSource.gallery);
      setState(() {
        _image = File(pickedFile.path);
      });
    } catch (e) {
      print(e);
    }
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            title: Text("Create Post"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Photo from Camera"),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleTakeFromGallery,
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  Container buildUploadSplash() {
    // final double height = MediaQuery.of(context).size.height;
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: orientation == Orientation.portrait ? 260 : 210.0,
          ),
          SizedBox(
            height: 20.0,
          ),
          RaisedButton(
            splashColor: Colors.teal,
            color: Colors.deepOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              'Upload Image',
              style: TextStyle(color: Colors.white, fontSize: 22.0),
            ),
            onPressed: () => selectImage(context),
          )
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      _image = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imgFile = Im.decodeImage(_image.readAsBytesSync());
    final compressedImage = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imgFile, quality: 82));
    setState(() {
      _image = compressedImage;
    });
  }

  Future<String> uploadImage(File image) async {
    StorageUploadTask uploadTask =
        storageRef.child('post_$postId.jpg').putFile(image);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;

    String downloadURL = await storageSnap.ref.getDownloadURL();

    return downloadURL;
  }

  createPostInFirestore({String mediaURL, String location, String imgCaption}) {
    postsRef
        .document(widget.currentUser.id)
        .collection('userPosts')
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaURL,
      "imageCaption": imgCaption,
      "location": location,
      "timestamp": timestamp,
      "likes": {}
    });
  }

  handleSubmitPost() async {
    //making post btn disable
    setState(() {
      isUploading = true;
    });
    //compressing image
    await compressImage();

    //upload compressed img
    String mediaUrl = await uploadImage(_image);

    //Creating post collection with media url ,location and caption in firestore
    createPostInFirestore(
      mediaURL: mediaUrl,
      location: _locationController.text,
      imgCaption: _captionController.text,
    );
    _captionController.clear();
    _locationController.clear();
    setState(() {
      _image = null;
      isUploading = false;
      //postId will be same and will be overwritten
      //so we shold provide new postId when we we clear out state
      postId = Uuid().v4();
    });
  }


//with geolocator manually need to turn on
  getUserLocation() async {
    Position postion = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(postion.latitude, postion.longitude);
    Placemark placemark = placemarks[0];
    String address =
        '${placemark.locality}, ${placemark.name} - ${placemark.country}';
    print("Address :" + address);
    _locationController.text = address;
  }

  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () => isUploading ? null : handleSubmitPost(),
            child: Text(
              "Post",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          //showig linear progreess when uploading post
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(_image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  hintText: 'Write a Caption',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: "Where was this photo taken ?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            height: 100,
            width: 250.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              onPressed: getUserLocation,
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              label: Text(
                "Use Current Location",
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.blue,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _image == null ? buildUploadSplash() : buildUploadForm();
  }
}
