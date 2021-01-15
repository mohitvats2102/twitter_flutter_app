import 'package:flutter/material.dart';
import './utils/variables_and_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var _formKey = GlobalKey<FormState>();
  bool isSignUpStarted = false;

  String username;
  String email;
  String password;

  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;

  void trySubmitForm() {
    bool isvalid = _formKey.currentState.validate();
    if (!isvalid) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      isSignUpStarted = true;
    });
    signUpUser();
  }

//https://www.flaticon.com/free-icon/avatar_147144
  void signUpUser() async {
    AuthResult createdUser = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await _firestore
        .collection('users')
        .document(createdUser.user.uid)
        .setData({
      'username': username,
      'password': password,
      'email': email,
      'profilepic':
          'https://png.pngtree.com/png-clipart/20200225/original/pngtree-young-service-boy-vector-download-user-icon-vector-avatar-png-image_5257569.jpg',
      'uid': createdUser.user.uid,
    });
    setState(() {
      isSignUpStarted = false;
    });
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff00ADEF),
      body: Container(
        margin: EdgeInsets.only(top: 0),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'twitter',
                  child: Image.asset(
                    'assets/twitter1.jpg',
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Get Started to Flitter',
                  style: myStyle(30, FontWeight.w500, Colors.white),
                ),
                SizedBox(height: 70),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      UserInputField(
                        hintText: 'e-mail',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        hideEntry: false,
                        validate: (value) {
                          if (value.contains('@') && value.contains('.com')) {
                            return null;
                          }
                          return 'please provide valid email';
                        },
                        onSaved: (value) {
                          email = value;
                        },
                      ),
                      SizedBox(height: 20),
                      UserInputField(
                        hintText: 'username',
                        icon: Icons.person,
                        keyboardType: TextInputType.visiblePassword,
                        hideEntry: false,
                        validate: (value) {
                          if (value.length < 5) {
                            return 'username must be atleast 5 char long';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          username = value;
                        },
                      ),
                      SizedBox(height: 20),
                      UserInputField(
                        hintText: 'password',
                        icon: Icons.lock,
                        keyboardType: TextInputType.visiblePassword,
                        hideEntry: true,
                        validate: (value) {
                          if (value.length < 8) {
                            return 'password must be atleast 8 char long';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          password = value;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                isSignUpStarted
                    ? CircularProgressIndicator(backgroundColor: Colors.white)
                    : EntryButton(
                        title: 'Register',
                        onTap: trySubmitForm,
                      ),
                SizedBox(height: 70),
                Text(
                  'Already have an account.',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
                ChangeEntryButton(
                  title: 'Login',
                  onTap: () => Navigator.pop(context),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
