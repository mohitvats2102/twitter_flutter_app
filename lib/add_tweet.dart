import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddTweet extends StatefulWidget {
  @override
  _AddTweetState createState() => _AddTweetState();
}

class _AddTweetState extends State<AddTweet> {
  File pickedImage;
  TextEditingController _controller = TextEditingController();
  bool isUploadingStarted = false;

  void pickImage() {
    showDialog(
      context: context,
      builder: (ctx) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                onWantToTakePic(ImageSource.camera);
              },
              child: Text(
                'Open Camera',
              ),
            ),
            SizedBox(height: 10),
            SimpleDialogOption(
              onPressed: () {
                onWantToTakePic(ImageSource.gallery);
              },
              child: Text(
                'Pick From Gallery',
              ),
            ),
            SizedBox(height: 10),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                FocusScope.of(context).unfocus();
              },
              child: Text(
                'Cancel',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onWantToTakePic(ImageSource imageSource) async {
    final picker = ImagePicker();
    final image =
        await picker.getImage(source: imageSource, imageQuality: null);
    if (image == null) return;
    setState(() {
      pickedImage = File(image.path);
    });
    FocusScope.of(context).unfocus();
    Navigator.pop(context);
  }

  Future<dynamic> getUploadedImageUrl(int length) async {
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('tweeted_images')
        .child('Tweet $length');
    await ref.putFile(pickedImage).onComplete;
    return ref.getDownloadURL();
  }

  void uploadTweet() async {
    setState(() {
      isUploadingStarted = true;
    });
    FirebaseUser _currentUser = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot userData = await Firestore.instance
        .collection('users')
        .document(_currentUser.uid)
        .get();
    CollectionReference tweetsCollection =
        Firestore.instance.collection('tweets');
    QuerySnapshot allDocument = await tweetsCollection.getDocuments();
    int length = allDocument.documents.length;
    if (_controller.text != '' && pickedImage == null) {
      //if user only tweets
      await tweetsCollection.document('Tweet $length').setData({
        'username': userData['username'],
        'profilepic': userData['profilepic'],
        'uid': _currentUser.uid,
        'id': 'Tweet $length',
        'tweet': _controller.text,
        'likes': [],
        'commentcount': 0,
        'shares': 0,
        'type': 1
      });
    }
    if (_controller.text == '' && pickedImage != null) {
      dynamic imageurl = await getUploadedImageUrl(length);
      await tweetsCollection.document('Tweet $length').setData({
        'username': userData['username'],
        'profilepic': userData['profilepic'],
        'uid': _currentUser.uid,
        'id': 'Tweet $length',
        'image': imageurl,
        'likes': [],
        'commentcount': 0,
        'shares': 0,
        'type': 2
      });
    }
    if (_controller.text != '' && pickedImage != null) {
      dynamic imageurl = await getUploadedImageUrl(length);
      await tweetsCollection.document('Tweet $length').setData({
        'username': userData['username'],
        'profilepic': userData['profilepic'],
        'uid': _currentUser.uid,
        'id': 'Tweet $length',
        'image': imageurl,
        'tweet': _controller.text,
        'likes': [],
        'commentcount': 0,
        'shares': 0,
        'type': 3
      });
    }
    setState(() {
      isUploadingStarted = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: () => uploadTweet(),
        child: Icon(
          Icons.file_upload,
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text('Add Tweet'),
        actions: [
          InkWell(
            onTap: () => pickImage(),
            child: Icon(Icons.add_photo_alternate, size: 30),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: isUploadingStarted
          ? Center(
              child: CircularProgressIndicator(
                  semanticsLabel: 'uploading tweet...'),
            )
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'What\'s happening now...',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.black.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                ),
                pickedImage == null
                    ? Container()
                    : MediaQuery.of(context).viewInsets.bottom > 0
                        ? Container()
                        : Image.file(pickedImage, width: 150, height: 150),
              ],
            ),
    );
  }
}
