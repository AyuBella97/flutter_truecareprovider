import '../helper/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as User;
import '../services/database.dart';
import '../helper/helperfunctions.dart';
import '../index/indexpage.dart';
import '../services/auth.dart';
import '../models/shared_configs.dart';
import 'dart:convert'; 
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseUser;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage();

  // final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => new _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  var userid = null;
  TextEditingController usernameEditingController = new TextEditingController();
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  TextEditingController passwordconfrimEditingController =
      new TextEditingController();
  final formKey = GlobalKey<FormState>();
  Auth authService = new Auth();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  SharedConfigs configs = SharedConfigs();
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  singUp() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService.signUpWithEmailAndPassword(
              emailEditingController.text, passwordEditingController.text)
          .then((result) async {
          if (result != null && result != "exist") {
            var password = passwordEditingController.text;
            var bytes = utf8.encode(password); // data being hashed

            var hashpassword = sha1.convert(bytes);
            var getcurrentuserid = await authService.getuserid();
            
            var cp = getcurrentuserid.docs[0].data['cpCode'];
            var code = cp.substring(0, 2);
            var currrentnumber = cp.substring(3, 9);
            var toint = int.tryParse(currrentnumber);
            toint = toint! + 1;
            var x = toint.toString().padLeft(7, '0');
            var id = code+(x); 
            Map<String, dynamic> userDataMap = {
            "cpCode" : id,
            "uid": result.uid,
            "userEmail": emailEditingController.text,
            "name":usernameEditingController.text,
            "profilePhoto":null,
            "userName": usernameEditingController.text,
            "status":0,
            "state":null,
            "password": hashpassword.toString(),
          };
          print('userdata map == $userDataMap');
          databaseMethods.addUserInfo(id,userDataMap);

          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserIdSharedPreference(id);
          HelperFunctions.saveUserNameSharedPreference(
              usernameEditingController.text);
          HelperFunctions.saveUserEmailSharedPreference(
              emailEditingController.text);

          Navigator.pushNamed(context, '/INDEX');
        }
        else{
          _showErroVideoDialog();
        }
      });
    }
  }

  Future<void> _showErroVideoDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Email already registered'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              // Container(alignment: Alignment.center,child:Text('',),),
              // Container(alignment: Alignment.center,child:Text('Please Contact admin for further assistance',),),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  // facebookLogin() async {
  //   setState(() {
  //     _errorMessage = "";
  //     _isLoading = true;
  //   });
  //   FirebaseUser user = await authService.signInFB();
  //   if (user != null) {
  //             authenticateUser(user);
  //             saveUser(user);
  //   }
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  void googleLogin() async {
  
    setState(() {
      _isLoading = true;
    });

    // FirebaseUser user = await authService.signInGoogle();

    // if (user != null) {
    //   authenticateUser(user);
    //   saveUser(user);
    // }
    // setState(() {
    //   _isLoading = false;
    // });
  }

  void saveUser(firebaseUser.User user){
    
      HelperFunctions.saveUserLoggedInSharedPreference(true);
      Constants.myName = user.displayName!;
      HelperFunctions.saveUserIdSharedPreference(user.uid);
      HelperFunctions.saveUserNameSharedPreference(
          user.displayName.toString());
      HelperFunctions.saveUserEmailSharedPreference(
          user.email.toString());
      HelperFunctions.saveNameSharedPreference(user.displayName.toString());
      HelperFunctions.saveImageSharedPreference(user.photoURL.toString());
      Navigator.pushNamed(context, "/INDEX");
      
  }

  // ignore: missing_return
  Future<void> authenticateUser(firebaseUser.User user) async {
    authService.authenticateUser(user).then((isNewUser) {
      setState(() {
        _isLoading = false;
      });

      if (isNewUser) {
        authService.addDataToDbFacebookorGoogle(user).then((value) {
          // Navigator.pushNamed(context, '/INDEX');
          setState(() {
            _isLoading = false;
          });
        });
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final usernameField = TextFormField(
      obscureText: false,
      validator: (val) {
        return val!.isEmpty || val.length < 3
            ? "Enter Username 3+ characters"
            : null;
      },
      controller: usernameEditingController,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Username",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final emailField = TextFormField(
      controller: emailEditingController,
      validator: (val) {
        return RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(val!)
            ? null
            : "Enter correct email";
      },
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final passwordField = TextFormField(
      controller: passwordEditingController,
      validator: (val) {
        return val!.length < 6 ? "Enter Password 6+ characters" : null;
      },
      obscureText: true,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final confirmpasswordField = TextFormField(
      controller: passwordconfrimEditingController,
      validator: (val) {
        return val != passwordEditingController.text
            ? "Re-enter the same password"
            : null;
      },
      obscureText: true,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Confirm Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          singUp();
        },
        child: Text("Sign Up",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    Widget showFacebookLogin() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        // mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: SizedBox(
                height: 50.0,
                child: new FlatButton(
                  // elevation: 5.0,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(25.0)),
                  // rgb(57, 68, 153)rgb(51, 126, 185)
                  onPressed: () {  },
                  child: Ink(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(80.0)),
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color.fromRGBO(57, 68, 153, 1),
                              Color.fromRGBO(51, 126, 185, 1),
                            ])),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 50,
                          // height: 50,
                          child: new IconButton(
                              icon: FaIcon(FontAwesomeIcons.facebook),
                              onPressed: googleLogin,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      );
    }

    Widget showGoogleLogin() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        // mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: SizedBox(
                height: 50.0,
                child: new FlatButton(
                  // elevation: 5.0,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(25.0)),
                  // rgb(57, 68, 153)rgb(51, 126, 185)
                  onPressed: () {  },
                  child: Ink(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(80.0)),
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color.fromRGBO(255, 255, 153, 1),
                              Color.fromRGBO(255, 255, 185, 1),
                            ])),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 50,
                          // height: 50,
                          child: new IconButton(
                              icon: FaIcon(FontAwesomeIcons.google),
                              onPressed: googleLogin,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      );
    }

    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text("Register"),
        // backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(child: Container(
        child: Center(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 155.0,
                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Text("Care Provider",style: TextStyle(fontSize:30,fontWeight:FontWeight.bold),), 
                  SizedBox(height: 45.0),
                  Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        
                        _isLoading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Container(),
                        usernameField,
                        SizedBox(height: 25.0),
                        emailField,
                        SizedBox(height: 25.0),
                        passwordField,
                        SizedBox(
                          height: 35.0,
                        ),
                        confirmpasswordField,
                        SizedBox(
                          height: 35.0,
                        ),
                        loginButon,
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: <Widget>[
                  //   showGoogleLogin(),
                  //   showFacebookLogin(),
                  // ],),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}
