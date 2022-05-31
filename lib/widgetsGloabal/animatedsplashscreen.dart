import 'dart:async';

import '../helper/helperfunctions.dart';

import '../models/shared_configs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class AnimatedSplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  bool? userIsLoggedIn;
  var _visible = true;

  var _height;
  var _width;
  var _deeppurple = const Color(0xFF512c7c);

  AnimationController? animationController;
  late Animation<double> animation;

  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  getLoggedInState() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value){
      setState(() {
        if (value !=null){
          userIsLoggedIn  = value;
        }
      });
    });
  }
  
  Future<void> navigationPage() async {

    if(userIsLoggedIn == true){
      Navigator.of(context).pushReplacementNamed('/INDEX');
    }
    else
      Navigator.of(context).pushReplacementNamed('/LOGIN_PAGE');
  }

  @override
  void initState() {
    super.initState();
    getLoggedInState();
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 2));
    animation =
    new CurvedAnimation(parent: animationController!, curve: Curves.easeOut);

    animation.addListener(() => this.setState(() {}));
    animationController!.forward();

    setState(() {
      _visible = !_visible;
    });
    startTime();

    // _getLocationPermission();
  }


  // void _getLocationPermission() async {
  //   var location = new Location();
  //   try {
  //     location.requestPermission();
  //   } on Exception catch (_) {
  //     print('There was a problem allowing location access');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deeppurple,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // new Column(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   mainAxisSize: MainAxisSize.min,
          //   children: <Widget>[

          //     Padding(padding: EdgeInsets.only(bottom: 30.0),child:new Image.asset('assets/images/splash_logo.png',height: 25.0,fit: BoxFit.scaleDown,))


          //   ],),
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Image.asset(
                'assets/images/logo.png',
                width: animation.value * 150,
                height: animation.value * 150,
              ),
              // SizedBox(height: 10,),
              // Text("TRUECARE2U PROVIDER",style: TextStyle(fontSize: 30,color: Colors.white),),
            ],
          ),
        ],
      ),
    );
  }
}