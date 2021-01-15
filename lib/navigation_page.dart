import 'package:flutter/material.dart';
import 'package:twitter_flutter_app/home_screen.dart';
import 'package:twitter_flutter_app/signup_screen.dart';
import './utils/variables_and_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  bool isLogin = false;
  FirebaseAuth _isAuth = FirebaseAuth.instance;

  void changeIsLogin() {
    setState(() {
      isLogin = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _isAuth.onAuthStateChanged.listen(
      (event) {
        if (event != null) {
          setState(() {
            isLogin = true;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isLogin ? null : Color(0xff00ADEF),
      body: isLogin ? HomeScreen() : LoginScreen(changeIsLogin: changeIsLogin),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final Function changeIsLogin;
  LoginScreen({this.changeIsLogin});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  var _formKey = GlobalKey<FormState>();
  bool isLoginStarted = false;

  String email;
  String password;

  void trySubmit() {
    _formKey.currentState.save();
    setState(() {
      isLoginStarted = true;
    });
    loginUser();
  }

  void loginUser() async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    setState(() {
      isLoginStarted = false;
    });
    widget.changeIsLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 120),
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
                'Welcome to Flitter',
                style: myStyle(30, FontWeight.w500, Colors.white),
              ),
              SizedBox(height: 90),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    UserInputField(
                      hintText: 'e-mail',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      hideEntry: false,
                      onSaved: (value) {
                        email = value;
                      },
                    ),
                    SizedBox(height: 20),
                    UserInputField(
                      hintText: 'password',
                      icon: Icons.lock,
                      keyboardType: TextInputType.visiblePassword,
                      hideEntry: true,
                      onSaved: (value) {
                        password = value;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              isLoginStarted
                  ? CircularProgressIndicator(backgroundColor: Colors.white)
                  : EntryButton(
                      title: 'Login',
                      onTap: () => trySubmit(),
                    ),
              SizedBox(height: 70),
              Text(
                'Don\'t have any account.',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
              ChangeEntryButton(
                title: 'Register',
                onTap: () async {
                  bool val = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => SignUpScreen(),
                    ),
                  );
                  if (val) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 1),
                        content: Text(
                          'You have registerd successfully',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.lightBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        backgroundColor: Colors.white,
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
