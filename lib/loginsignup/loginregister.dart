import 'package:TrueCare2u_flutter/loginsignup/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:TrueCare2u_flutter/main.dart';

class LoginSignupPage extends StatefulWidget {
  LoginSignupPage();

  // final VoidCallback loginCallback;
  
  @override
  State<StatefulWidget> createState() => new _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  var _height;
  var _width;
  var _deeppurple = const Color(0xFF512c7c);
  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
      _width = MediaQuery.of(context).size.width;
        final loginButon = Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(10.0),
          color: Color(0xff01A0C7),
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width*0.4,
            padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
            onPressed: () {
              Navigator.pushNamed(context, '/LOGIN_PAGE');
            },
            child: Text("Login",
                textAlign: TextAlign.center,
                style: style.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
        final registerButton = Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(10.0),
          color: Color(0xffffffff),
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width*0.4,
            padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
            onPressed: () {
              Navigator.pushNamed(context, '/REGISTER_PAGE');
            },
            child: Text("Register",
                textAlign: TextAlign.center,
                style: style.copyWith(
                    color: Color(0xff01A0C7), fontWeight: FontWeight.bold)),
          ),
        );

        return Scaffold(
          backgroundColor: _deeppurple,
          body: Center(
            child: Container(
              // color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
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
                    Text("Care Provider",style: TextStyle(fontSize:30,fontWeight:FontWeight.bold,color: Colors.white),), 
                    SizedBox(height: _height/10),
                    Row(
                      mainAxisAlignment:MainAxisAlignment.spaceEvenly ,
                      children: <Widget>[
                        // registerButton,
                        // SizedBox(width: 10.0),
                        loginButon,
                      ],
                    ),
                    
                    SizedBox(
                      height: 15.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
  
}