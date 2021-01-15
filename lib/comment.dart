import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as tAgo;

class CommentPage extends StatefulWidget {
  final String documentID;
  CommentPage(this.documentID);
  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  void addComment() async {
    if (_controller.text.trim() == '') return;
    FirebaseUser _currentUser = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot userData = await Firestore.instance
        .collection('users')
        .document(_currentUser.uid)
        .get();
    await Firestore.instance
        .collection('tweets')
        .document(widget.documentID)
        .collection('comments')
        .document()
        .setData({
      'username': userData['username'],
      'uid': userData['uid'],
      'profilepic': userData['profilepic'],
      'time': DateTime.now(),
      'comment': _controller.text,
    });
    _controller.clear();
    DocumentSnapshot tweetDoc = await Firestore.instance
        .collection('tweets')
        .document(widget.documentID)
        .get();
    await Firestore.instance
        .collection('tweets')
        .document(widget.documentID)
        .updateData({
      'commentcount': tweetDoc['commentcount'] + 1,
    });
  }

  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('tweets')
                    .document(widget.documentID)
                    .collection('comments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot commentDoc =
                          snapshot.data.documents[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            commentDoc['profilepic'],
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              commentDoc['username'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              commentDoc['comment'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          tAgo.format(commentDoc['time'].toDate()).toString(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 5),
          Container(
            height: 60,
            child: ListTile(
              title: TextField(
//                onChanged: (value) {
//                  setState(
//                    () {
//                      enteredMsg = value;
//                    },
//                  );
//                },
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlue),
                  ),
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.send, color: Colors.lightBlue),
                onPressed: () =>
                    addComment(), //enteredMsg.trim().isEmpty ? null : () {},
              ),
            ),
          )
        ],
      ),
    );
  }
}
