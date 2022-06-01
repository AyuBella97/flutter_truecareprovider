import 'package:TrueCare2u_flutter/pdf/pdfviewer.dart';
import 'package:TrueCare2u_flutter/services/api_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helper/constants.dart';
import './register.dart';
import '../services/database.dart';
import '../helper/helperfunctions.dart';
import '../index/indexpage.dart';
import '../services/auth.dart';
import '../models/shared_configs.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:TrueCare2u_flutter/main.dart';

class LoginPage extends StatefulWidget {
  LoginPage();

  // final VoidCallback loginCallback;
  
  @override
  State<StatefulWidget> createState() => new _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginPage> {
  late bool isUserLoggedIn;
  var _height;
  var _width;
  var _deeppurple = const Color(0xFF512c7c);
  bool _passwordVisible = false;
  final _firebaseMessaging = FirebaseMessaging.instance;

  SharedConfigs configs = SharedConfigs();
  Auth authService = new Auth();

  final formKey = GlobalKey<FormState>();
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0,color: Colors.white);
  bool _isLoading = false;
  String? _errorMessage;
  bool iserror = false;
  var token;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getToken();
  }

  Future<String?> _getToken() async{
    _firebaseMessaging.getToken().then((devicetoken){
      print('Device token : $devicetoken');
      token =  devicetoken;
    });
    return token;
  } 

  void signIn() async {
    if (formKey.currentState != null) {
      formKey.currentState?.validate();
      setState(() {
        _isLoading = true;
      });

      // await authService
      //     .signInWithEmailAndPassword(
      //         emailEditingController.text, passwordEditingController.text)
      //     .then((result) async {
        // if (result != null)  {
          var bytes = utf8.encode("${passwordEditingController.text}"); // data being hashed
          var digest = sha1.convert(bytes);
          print("Digest as bytes: ${digest.bytes}");
          print("Digest toString string: ${digest.toString()}");
           QuerySnapshot userInfoSnapshot =
              await DatabaseMethods().getUserLogin(emailEditingController.text,digest.toString());
              print("length is ${userInfoSnapshot.docs.length}");
          if (userInfoSnapshot.docs.length != 0)  {
          if(userInfoSnapshot.docs[0]["isActive"] == 1){
          await HelperFunctions.saveUserLoggedInSharedPreference(true);
          await HelperFunctions.saveUserIdSharedPreference(userInfoSnapshot.docs[0]["cpCode"]);
          await HelperFunctions.saveUserisStaff(userInfoSnapshot.docs[0]["isStaff"]);
          await HelperFunctions.saveUserNameSharedPreference(userInfoSnapshot.docs[0]["userName"]);
          await HelperFunctions.saveUserEmailSharedPreference(userInfoSnapshot.docs[0]["email"]);
          await HelperFunctions.saveImageSharedPreference(userInfoSnapshot.docs[0]["profileImage"]);
          await HelperFunctions.saveUserPhoneNoPreference(userInfoSnapshot.docs[0]["telNo"]);
          
          Map<String, dynamic> userDataMap = {
              "deviceToken": token,
          };
          Map<String,dynamic> devicetokentoApi = {
            "Code":userInfoSnapshot.docs[0]["cpCode"],
            "deviceToken":token,
          };
          print("LALU SINI $devicetokentoApi");
          await ApiService().updateCareProvider(devicetokentoApi);

          await DatabaseMethods().updateDeviceToken(userInfoSnapshot.docs[0]["cpCode"],userDataMap).then((_){
            HelperFunctions.saveUserDeviceTokenPreference(token);
            print("devicetoken is $token");

              // Navigator.pushNamed(context, '/INDEX');
              Navigator.of(context)
          .pushNamedAndRemoveUntil("/INDEX",(Route<dynamic> route) => true);

            // Navigator.pushNamed(context, '/INDEX');
          });
          }
          else {
            setState((){
              _isLoading = false;
            });
            showerror("Your account have been suspended");
          }
        } 
        else {
          setState(() {
            _isLoading = false;
            iserror = true;
            // _showErroLogin(context);
            showerror("Invalid email or password");
            print("wrong password/email");
            //show snackbar
            
          });
          
            
        }
      // });
    }
  }

  showerror(message){
        return showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(20.0)), //this right here
                          child: Container(
                            height: 200,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    child: Text('$message',style: TextStyle(fontSize: 18),),
                                  ),
                                  SizedBox(height: 10,),
                                  SizedBox(
                                    width: 150.0,
                                    child: RaisedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        "OK",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: _deeppurple,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      });

            }

  Future<void> _showErroLogin(context) async {
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Email/Password Incorrect !!'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Container(alignment: Alignment.center,child:Text('please check for any mispelled words/white space',),),
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

  @override
  Widget build(BuildContext context) {
  _height = MediaQuery.of(context).size.height;
  _width = MediaQuery.of(context).size.width;

  final emailField = TextFormField(
          controller: emailEditingController,
          obscureText: false,
          style: style,
          validator: (val) {
            return RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val!) ? null : "Please Enter Correct Email";
          },
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(   
	          borderSide: BorderSide(color: Colors.grey), ),
            contentPadding: EdgeInsets.only(top: 20), // add padding to adjust text
          isDense: true,
          prefixIcon: Padding(
            padding: EdgeInsets.only(top: 10), // add padding to adjust icon
            child: Icon(Icons.email,color: Colors.grey,),
          ),
              hintText: "Email",
              hintStyle: TextStyle(color: Colors.grey),
                ),
        );

        final passwordField = TextFormField(
          controller: passwordEditingController,
          obscureText: _passwordVisible ?false:true,
          style: style,
          //   },
          decoration: InputDecoration(
              suffixIcon: IconButton(
              icon: Icon(
                // Based on passwordVisible state choose the icon
                _passwordVisible
                ? Icons.visibility
                : Icons.visibility_off,
                color: Colors.grey,
                ),
              onPressed: () {
                // Update the state i.e. toogle the state of passwordVisible variable
                setState(() {
                    _passwordVisible = _passwordVisible;
                });
              },
              ),
              enabledBorder: UnderlineInputBorder(   
              borderSide: BorderSide(color: Colors.grey), ),
              isDense: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(top: 10), // add padding to adjust icon
                child: Icon(Icons.lock,color: Colors.grey,),
              ),
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: "Password",
              hintStyle: TextStyle(color: Colors.grey),),
        );

        final loginButon = Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30.0),
          color: Colors.white,
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: () {
              signIn();
              print("COME ON");
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Text("Login",
                textAlign: TextAlign.center,
                style: style.copyWith(
                    color: _deeppurple, fontWeight: FontWeight.bold)),
              SizedBox(width: 10,),      
              Icon(Icons.arrow_forward,color: _deeppurple,)      
            ],),
            
          ),
        );

        // Widget showFacebookLogin() {
        //   return Row(
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     // mainAxisSize: MainAxisSize.min,
        //     children: <Widget>[
        //       new Padding(
        //           padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        //           child: SizedBox(
        //             height: 50.0,
        //             child: new FlatButton(
        //               // elevation: 5.0,
        //               shape: new RoundedRectangleBorder(
        //                   borderRadius: new BorderRadius.circular(25.0)),
        //               // rgb(57, 68, 153)rgb(51, 126, 185)
        //               child: Ink(
        //                 decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.all(Radius.circular(80.0)),
        //                     gradient: LinearGradient(
        //                         begin: Alignment.centerLeft,
        //                         end: Alignment.centerRight,
        //                         colors: [
        //                           Color.fromRGBO(57, 68, 153, 1),
        //                           Color.fromRGBO(51, 126, 185, 1),
        //                         ])),
        //                 child: Column(
        //                   mainAxisAlignment: MainAxisAlignment.center,
        //                   children: <Widget>[
        //                     Container(
        //                       width: 50,
        //                       // height: 50,
        //                       child: new IconButton(
        //                           icon:FaIcon(FontAwesomeIcons.facebook), 
        //                           onPressed: facebookLogin,
        //                           color: Colors.white),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             ),
        //           )),
        //     ],
        //   );
        // }
        
    //     Widget showGoogleLogin() {
    //     return Row(
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     // mainAxisSize: MainAxisSize.min,
    //     children: <Widget>[
    //       new Padding(
    //           padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
    //           child: SizedBox(
    //             height: 50.0,
    //             child: new FlatButton(
    //               // elevation: 5.0,
    //               shape: new RoundedRectangleBorder(
    //                   borderRadius: new BorderRadius.circular(25.0)),
    //               // rgb(57, 68, 153)rgb(51, 126, 185)
    //               child: Ink(
    //                 decoration: BoxDecoration(
    //                     borderRadius: BorderRadius.all(Radius.circular(80.0)),
    //                     gradient: LinearGradient(
    //                         begin: Alignment.centerLeft,
    //                         end: Alignment.centerRight,
    //                         colors: [
    //                           Color.fromRGBO(255, 255, 153, 1),
    //                           Color.fromRGBO(255, 255, 185, 1),
    //                         ])),
    //                 child: Column(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: <Widget>[
    //                     Container(
    //                       width: 50,
    //                       // height: 50,
    //                       child: new IconButton(
    //                           icon: FaIcon(FontAwesomeIcons.google),
    //                           onPressed: googleLogin,
    //                           color: Colors.white),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           )),
    //     ],
    //   );
    // }
        
        return Scaffold(
          backgroundColor: _deeppurple,
          // appBar: new AppBar(
          //   centerTitle: true,
          //   title: new Text("Login"),
          //   // backgroundColor: Colors.black,
          //   ),
          body: SingleChildScrollView(
            child: Container(
              // color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(36.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: _height*0.15),
                      child:
                    SizedBox(
                      height: 155.0,
                      child: Image.asset(
                        "assets/images/logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),),
                    // SizedBox(height: 10,),
                    // Text("Care Provider",style: TextStyle(fontSize:30,fontWeight:FontWeight.bold,color: Colors.white),),
                    SizedBox(height: 45.0),
                    Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        loading(),
                        emailField,
                        SizedBox(height: 25.0),
                        passwordField,
                        SizedBox(height: 35.0,),
                        loginButon,
                        SizedBox(height: 15.0,),
                        
                      ],

                    ),
                    ),
                    tnc(),
                    SizedBox(height: _height*0.02,),
                    registerbutton(),
                  //   Row(
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
        );
      }

      Widget tnc(){
        return Container(
          width: _width,
          padding: EdgeInsets.only(top:10,left: 20,right: 20),
          margin: EdgeInsets.only(bottom: _height*0.05),
          child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Text('By registering you are agreeing to our',style: TextStyle(color: Colors.grey)),
          SizedBox(width:2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            InkWell(
              onTap:()=> launchUrl("assets/tnc/TC2U-Terms-of-Use.pdf","Terms of Use"),
              child: Text("Terms of Use ",style: TextStyle(color: Colors.white,fontSize: 14),),
            ),
          ],),
        ],));

      }

      Widget registerbutton(){
        return InkWell(
                onTap: () {
                    // Navigator.pushNamed(context, '/REGISTER_PAGE');
                    openUrl();
                },
                child:Row(
                  mainAxisAlignment:MainAxisAlignment.center,
                  children: [
                  Text("REGISTER",style: TextStyle(fontSize: 16,color: Colors.white),),
                  SizedBox(width: 5,),
                  Icon(Icons.arrow_forward,color: Colors.white,),
                ],),
                  
                );
      }  
      Widget loading(){
        if(_isLoading){
           return Center(
            child: CircularProgressIndicator(),
          ); 
        }
        else{
          return Container();
        }
      }

      openUrl() async{
        var registerlink = "https://docs.google.com/forms/d/e/1FAIpQLSel4JG1n9GzFWmnEg2i_bcqTqh3r4Jlu9-bIf9SGB40qiOP3Q/viewform";
                    if(await canLaunch("$registerlink")){
                      await launch("$registerlink");   
                    } 
      }

      launchUrl(selectedUrl,title) async{
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Pdfviewer1(
            title: title,
          url: selectedUrl,
        ),
        ),
      );
  }
}
