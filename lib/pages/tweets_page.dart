import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitter_flutter_app/add_tweet.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:twitter_flutter_app/comment.dart';

class TweetsPage extends StatefulWidget {
  @override
  _TweetsPageState createState() => _TweetsPageState();
}

class _TweetsPageState extends State<TweetsPage> {
  FirebaseUser _currentUser;

  void likePost(String tweetID) async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot tweetDoc =
        await Firestore.instance.collection('tweets').document(tweetID).get();
    if (tweetDoc['likes'].contains(currentUser.uid)) {
      Firestore.instance.collection('tweets').document(tweetID).updateData({
        'likes': FieldValue.arrayRemove([currentUser.uid])
      });
    } else {
      Firestore.instance.collection('tweets').document(tweetID).updateData({
        'likes': FieldValue.arrayUnion([currentUser.uid])
      });
    }
  }

  void sharePost(String tweetID, String tweet) async {
    Share.text('Flitter', tweet, 'text/plain');
    DocumentSnapshot tweetDoc =
        await Firestore.instance.collection('tweets').document(tweetID).get();
    Firestore.instance.collection('tweets').document(tweetID).updateData(
      {'shares': tweetDoc['shares'] + 1},
    );
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 2),
            Image.asset('assets/twitter1.jpg', height: 38, width: 38),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('tweets').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                itemBuilder: (ctx, index) {
                  final tweetData = snapshot.data.documents[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(tweetData[
                            'profilepic']), //AssetImage('assets/user.jpg'),
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          tweetData['username'],
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      subtitle: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (tweetData['type'] == 1) Text(tweetData['tweet']),
                          if (tweetData['type'] == 2)
                            Image.network(tweetData['image']),
                          if (tweetData['type'] == 3)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  child: Text(
                                    tweetData['tweet'],
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 17,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                SizedBox(height: 15),
                                Container(
                                  width: 250,
                                  height: 300,
                                  child: Image.network(
                                    tweetData['image'],
                                    fit: BoxFit.cover,
                                  ),
                                )
                              ],
                            ),
                          SizedBox(height: 30),
                          Row(
                            children: [
                              InkWell(
                                child: Icon(Icons.message,
                                    color: Colors.lightBlue),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CommentPage(tweetData['id']),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(tweetData['commentcount'].toString()),
                              SizedBox(width: 60),
                              InkWell(
                                child: tweetData['likes']
                                        .contains(_currentUser.uid)
                                    ? Icon(Icons.favorite,
                                        color: Colors.lightBlue)
                                    : Icon(Icons.favorite_border,
                                        color: Colors.lightBlue),
                                onTap: () => likePost(tweetData['id']),
                              ),
                              SizedBox(width: 10),
                              Text(tweetData['likes'].length.toString()),
                              SizedBox(width: 60),
                              InkWell(
                                child:
                                    Icon(Icons.share, color: Colors.lightBlue),
                                onTap: () => sharePost(
                                    tweetData['id'], tweetData['tweet']),
                              ),
                              SizedBox(width: 10),
                              Text(tweetData['shares'].toString()),
                            ],
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: snapshot.data.documents.length,
              );
            }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => AddTweet(),
          ),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
