import 'dart:convert';

import 'package:TrueCare2u_flutter/index/indexpage.dart';
import 'package:TrueCare2u_flutter/services/database.dart';
import 'package:flutter/material.dart';
import '../../helper/constants.dart';
import '../../helper/helperfunctions.dart';
import '../../services/auth.dart';
import 'package:badges/badges.dart';
import 'package:crypto/src/sha1.dart';
class ChangePasswordPage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<ChangePasswordPage> {
  var _height;
  var _width;
  var _deeppurple = const Color(0xFF512c7c);

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var textControlleroldpassword = new TextEditingController();
  var textControllernewpassword = new TextEditingController();
  var textControllernewpasswordconfirm = new TextEditingController();
  String? _oldpassword;
  String? _oldpasswordhashed;
  String? _newpassword;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserOldPassword();
  }

  getUserOldPassword() async{
    var bytes ; // data being hashed
    var digest ;
    print("myid in changepassword ${Constants.myId}");
    DatabaseMethods().getCareProvider(Constants.myId).then((value) {
      print("data is password ${value.docs[0].data['password']}");
      _oldpassword = value.docs[0].data['password'];
      if(_oldpassword == null){
        _oldpassword = "";
        bytes = utf8.encode("$_oldpassword"); // data being hashed
        digest = sha1.convert(bytes);
        _oldpasswordhashed = digest.toString();
      }
      else{
        _oldpasswordhashed = _oldpassword;
      }
      
      print("digest is hex ${_oldpasswordhashed} $_oldpassword");
    });
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
          title: Text("Change Password",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          backgroundColor: _deeppurple,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white,size: 14,),
            onPressed: () => Navigator.of(context).pop(),
          ),),
      body: Container(
        height: _height,
        width: _width,
        // padding: EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
            child: mainLayout(),
          ),
      ),
    );
  }

  Widget mainLayout() {
    return Column(
      children: <Widget>[
        profileForm(),
        submitButton(),
        cancelButton(),
      ],
    );
  }

  Widget profileForm(){
    return Container(

          // height: _height*0.7,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.white,
              boxShadow: [ 
                                BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 1,
                                offset: new Offset(0.0, 0.0), // changes position of shadow
                            ),
                          ]
          ),
          // margin: EdgeInsets.only(left: 10, right: 40, top:   10),
          width: _width,
          // height: _height*0.5,
          // padding: EdgeInsets.only(top: 0,right: 10,left: 10),
          child:Form(
            key: _formKey,
            child:Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                

                  
                Text("Current Password"),
                _buildOldPassword(),
                SizedBox(height: 15,),
                Text("New Password"),
                _buildNewPassword(),
                SizedBox(height: 15,),
                Text("Confirm Password"),
                _buildConfirmPassword(),
                SizedBox(height: 15,),
                
                // Text("Welcome Back,",style: TextStyle(color: Colors.white),),
                
              
          ],),
          ),
        );
  }

  _buildOldPassword() {
    return Row(
            children: <Widget>[
              Flexible(
                flex: 1,
                child: TextFormField(
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 14.0),
                  obscureText: true,
                  decoration: InputDecoration(
                      // contentPadding: new EdgeInsets.symmetric(vertical: 0.0),
                      enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                      hintText: 'Old Password',
                      // labelText: 'Name',
                      hintStyle: TextStyle(fontSize: 11.0)),
                  controller: textControlleroldpassword,
                  initialValue: null,
                  validator: (String? value) {
                    var bytes = utf8.encode("$value"); // data being hashed
                    var digest = sha1.convert(bytes);
                    var _oldpasswordinput = digest.toString();
                    print("input old password == $_oldpasswordinput");
                      if(_oldpasswordhashed != _oldpasswordinput){
                        return 'Old Password is incorrect!';
                      }
                    return null;
                  },
                  onSaved: (String? value) {
                    setState(() {
                        _oldpassword = value;
                    });
                  },    
                ),),
            ],
        );
  }

  _buildNewPassword() {
    return  Row(
            children: <Widget>[
              Flexible(
                flex: 2,
                child: TextFormField(
                  obscureText: true,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 14.0),
                  decoration: InputDecoration(
                      // contentPadding: new EdgeInsets.symmetric(vertical: 0.0),
                      enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                      hintText: 'New Password',
                      // labelText: 'Name',
                      hintStyle: TextStyle(fontSize: 11.0)),
                  controller: textControllernewpassword,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'New Password Required ';
                      
                    }
                    else if(value.length < 8){
                        return 'Password must be longer than 8';
                      }

                    return null;
                  },
                  onSaved: (String? value) {
                    setState(() {
                        _newpassword = value;
                    });
                  },    
                ),),
            ],
        );
  }

  _buildConfirmPassword() {
    return Row(
            children: <Widget>[
              Flexible(
                flex: 1,
                child: TextFormField(
                  obscureText: true,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 14.0),
                  decoration: InputDecoration(
                      // contentPadding: new EdgeInsets.symmetric(vertical: 0.0),
                      enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                      hintText: 'Confirm Password',
                      // labelText: 'Name',
                      hintStyle: TextStyle(fontSize: 11.0)),
                  controller: textControllernewpasswordconfirm,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Confirm Password is Required ';
                    }
                    else if(textControllernewpasswordconfirm.text != textControllernewpassword.text){
                        return 'Password must be the same as new password';
                      }

                    return null;
                  },
                  onSaved: (String? value) {
                    setState(() {
                        _newpassword = value;
                    });
                  },    
                ),),
            ],
        );
  }

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(content: Text('saving...'));
    _scaffoldKey.currentState?.showSnackBar(snackBar);
  }

  submitButton(){
    return GestureDetector(
        onTap: (){
        if (_formKey.currentState!.validate()) {
          _formKey.currentState?.save();
          _displaySnackBar(context);
          onSubmit();
          }
        },
      child:Container(
      margin: EdgeInsets.only(left:15,right: 15,top: 15),
      padding: EdgeInsets.only(left:_width*0.02,right: _width*0.02),
      width: _width,
      height: _height*0.07,
      decoration: BoxDecoration(color: _deeppurple,borderRadius: BorderRadius.circular(50),
            boxShadow: [ 
                      BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 0.5,
                      blurRadius: 1,
                      offset: new Offset(2.0, 2.0), // changes position of shadow
                  ),
                ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text("Save",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
        // SizedBox(width: 10,),
        // Icon(Icons.arrow_forward,color: Colors.white,size: 14,)
      ],),
      
      ),
      );
  }

  cancelButton(){
    return GestureDetector(
        onTap: (){
        Navigator.pop(context);
        },
      child:Container(
      margin: EdgeInsets.only(left:15,right: 15,top: 5),
      padding: EdgeInsets.only(left:_width*0.02,right: _width*0.02),
      width: _width,
      height: _height*0.07,
      decoration: BoxDecoration(color: Colors.grey[600],borderRadius: BorderRadius.circular(50),
            boxShadow: [ 
                      BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 0.5,
                      blurRadius: 1,
                      offset: new Offset(2.0, 2.0), // changes position of shadow
                  ),
                ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text("Cancel",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
      ],),
      
      ),
      );
  }

  onSubmit() async{
      var bytes = utf8.encode("$_newpassword"); // data being hashed
      var digest = sha1.convert(bytes);
      var _newpasswordhashed = digest.toString();
      Map<String,dynamic> mapData = {
        "password":_newpasswordhashed,
      };
      print("myid is == ${Constants.myId}");
      await DatabaseMethods().updateCareProvider(Constants.myId,mapData).then((_){
        Navigator.push(
          context, MaterialPageRoute(
          builder: (context) => new IndexPage(0)));
      });
      
  } 
}
