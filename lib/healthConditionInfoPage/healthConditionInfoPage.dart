import 'dart:math';

import 'package:TrueCare2u_flutter/helper/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database.dart';
import 'package:flutter/material.dart';
import 'dart:convert' show json;
// import 'package:fluttertoast/fluttertoast.dart';


class HealthConditionInfoPage extends StatefulWidget {

  @override
  HealthConditionInfoPage();
  _HealthConditionInfoPageState createState() => _HealthConditionInfoPageState();
} 

class _HealthConditionInfoPageState extends State<HealthConditionInfoPage> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  bool _isLoading = false;
  var userid;
  var textControllerProblem = new TextEditingController();  
  var textControllerdiagnosed = new TextEditingController();  
  var textControllermedication = new TextEditingController();
  var textControllerallergies = new TextEditingController();
  // List part = ['none','head','body','arms','groin','feet',];
  String dropdownValue = 'others';

  // List partHead = ['eye','nose','ears','mouth','chin'];
  String dropdownValueHead = 'others';
  
  @override
  void initState() {

    super.initState();
    
  }

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    String servicetype = ModalRoute.of(context)?.settings.arguments as String;
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title:Text(servicetype.toUpperCase()),
      ),
      body: Form(
        key: _formKey,
        child:Container(
        color: Colors.grey[200],
        child:SingleChildScrollView(
        padding: EdgeInsets.only(left:8.0,right: 8.0,top: 8.0,bottom: 15.0),
            child:Column(
              children: <Widget>[
                SizedBox(height: 20,),
                bodylist(),
                bodyPart(),
                SizedBox(height: 15,),
                Align(
                alignment: Alignment.centerLeft,
                child:Text("Explain your health problem :")),
                Align(
                  alignment: Alignment.centerLeft,
                  child:Text(
                    "Describe your health problem as detailed as you can, so the doctor can understand your issue and he/she able to give you proper advice.",
                  style: TextStyle(fontSize: 12),
                    )
                  ), 
                SizedBox(height: 15,),
                problem(),
                Text(
                    "(min. 20 characters)",style: TextStyle(fontSize: 12),
                  ),
                SizedBox(height: 10,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: gender(),  
                ),
                SizedBox(height: 10,),
                additional(),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                  RaisedButton(
                      color: Colors.green,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _displaySnackBar(context);
                          submitSurvey();
                        }
                      },
                      child: Text('Submit'),
                    ),
                    SizedBox(width: 10,),
                  RaisedButton(
                      color: Colors.redAccent,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),

                ],),
                SizedBox(height: 60,),
              ],
            ),
            
      ),),),
      );
  }

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(content: Text('Processing...'));
    _scaffoldKey.currentState?.showSnackBar(snackBar);
  }


  Widget bodylist(){
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
      padding: EdgeInsets.only(left:5),
      child:Row(children: <Widget>[
        Text("Body Part :"),
        SizedBox(width: 5,),
          DropdownButton<String>(
              value: dropdownValue,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              items: <String>['others','head','body','arms','groin','feet']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
        ),
      ],)  
      ),);
  }

  Widget bodyPart(){
    if(dropdownValue == 'head'){
          return headPart();
    }
    else{
      // return ;
      return SizedBox(height: 1,);
    }
  }

  headPart(){
    return Align(
          alignment: Alignment.topLeft,
          child: Padding(
          padding: EdgeInsets.only(left:5),  
          child:Row(
            children: <Widget>[
              Text(dropdownValue+' : '),
              SizedBox(width: 5,),
              DropdownButton<String>(
              value: dropdownValueHead,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? newValue2) {
                setState(() {
                  dropdownValueHead = newValue2!;
                });
              },
              items: <String>['eye','nose','ears','mouth','chin','others']
                  .map<DropdownMenuItem<String>>((String value2) {
                return DropdownMenuItem<String>(
                  value: value2,
                  child: Text(value2),
                );
              }).toList(),
            ),
            ],
          )),);
  }

  String problemText = "";
  problem(){
     return Row(
       children: <Widget>[
        new Flexible(
          child:Container(
            color: Colors.white,
            child:TextField(
            controller: textControllerProblem,
            maxLines: 3, 
          obscureText: false,
          onChanged: (newValue) {
          setState(() {
            problemText = newValue;
            print('problem text == $problemText');
          });
          },
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: "ex: i got severe headache for 3 days",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
        ),
        ),
        ),],
     );
  }

  String _gender = 'male';
  int _radioValueGender = -1;
  void _handleRadioValueChangeGender(int? value) {
    setState(() {
      _radioValueGender = value!;

      switch (_radioValueGender) {
        case 0:
          setState(() {
            _gender = "male";
          });
          break;
        case 1:
          setState(() {
            _gender = "female";
          });
          break;
      }
    });
  }

  gender(){
    return Column(children: <Widget>[
                   Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      'Confirm your gender :',
                      style: new TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),),
                    Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Radio(
                          value: 0,
                          groupValue: _radioValueGender,
                          onChanged: _handleRadioValueChangeGender,
                        ),
                        new Text(
                          'Male',
                          style: new TextStyle(fontSize: 16.0),
                        ),
                        new Radio(
                          value: 1,
                          groupValue: _radioValueGender,
                          onChanged: _handleRadioValueChangeGender,
                        ),
                        new Text(
                          'Female',
                          style: new TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    ),
      ],
                    
    );
  }

  bool diagnosed = false;
  int _radioValuediagnosed = -1;
  void _handleRadioValueChangeDiagnosed(int? value) {
    setState(() {
      _radioValuediagnosed = value!;

      switch (value) {
        case 0:
          setState(() {
            diagnosed = false;
          });
          break;
        case 1:
          setState(() {
            diagnosed = true;
          });
          break;
      }
    });
  }

  Widget additional(){
      return Column(children:<Widget>[
          diagnosedAdditional(),
          medicationAdditional(),
          allergiesAdditional(),
        ],
      );
  }

  Widget diagnosedAdditional(){
     return Column(
       children: <Widget>[
                  Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      'Do you have any previously diagnosed conditions?',
                      style: new TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    ),
                  Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Radio(
                          value: 0,
                          groupValue: _radioValuediagnosed,
                          onChanged: _handleRadioValueChangeDiagnosed,
                        ),
                        new Text(
                          'No',
                          style: new TextStyle(fontSize: 16.0),
                        ),
                        new Radio(
                          value: 1,
                          groupValue: _radioValuediagnosed,
                          onChanged: _handleRadioValueChangeDiagnosed,
                        ),
                        new Text(
                          'Yes',
                          style: new TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    ),
                    diagnosedForm(),
      ],
                    
    );
  }
  String diagnosedText ="";
  Widget diagnosedForm(){
    if(diagnosed == true){
    return Container(
            color: Colors.white,
            child:TextField(
              controller: textControllerdiagnosed,
            maxLines: 3, 
          obscureText: false,
          onChanged: (newvalue){
            setState(() {
                diagnosedText = newvalue;
                print('diagnosed text == $diagnosedText');
            });
          },
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: "Additional Information",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
        ),
        );
    }
    else{
      return SizedBox(height: 5,);
    }
  }

    bool medication = false;
    int _radioValuemedication = -1;

    void _handleRadioValueChangeMedication(int? value) {
    setState(() {
      _radioValuemedication = value!;

      switch (value) {
        case 0:
          setState(() {
            medication = false;
          });
          break;
        case 1:
          setState(() {
            medication = true;
          });
          break;
      }
    });
  }
    
    Widget medicationAdditional(){
     return Column(
       children: <Widget>[
                  Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      'Are you taking any Medication?',
                      style: new TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    ),
                  Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Radio(
                          value: 0,
                          groupValue: _radioValuemedication,
                          onChanged: _handleRadioValueChangeMedication,
                        ),
                        new Text(
                          'No',
                          style: new TextStyle(fontSize: 16.0),
                        ),
                        new Radio(
                          value: 1,
                          groupValue: _radioValuemedication,
                          onChanged: _handleRadioValueChangeMedication,
                        ),
                        new Text(
                          'Yes',
                          style: new TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    ),
                    medicationForm(),
      ],
                    
    );
  }

  String medicationText = "";
  Widget medicationForm(){
    if(medication == true){
    return Container(
            color: Colors.white,
            child:TextField(
              controller: textControllermedication,
            maxLines: 3, 
          obscureText: false,
          onChanged: (newvalue){
            setState(() {
              medicationText = newvalue;
              print('medicationText == $medicationText');
            });
          },
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: "Additional Information",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
        ),
        );
    }
    else{
      return SizedBox(height: 5,);
    }

  }

  // allergies form
    bool allergies = false;
    int _radioValueallergies = -1;

    void _handleRadioValueChangeAllergies(int? value) {
    setState(() {
      _radioValueallergies = value!;

      switch (value) {
        case 0:
          setState(() {
            allergies = false;
          });
          break;
        case 1:
          setState(() {
            allergies = true;
          });
          break;
      }
    });
  }
    Widget allergiesAdditional(){
     return Column(
       children: <Widget>[
                  Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      'Do you have any allergies?',
                      style: new TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    ),
                  Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Radio(
                          value: 0,
                          groupValue: _radioValueallergies,
                          onChanged: _handleRadioValueChangeAllergies,
                        ),
                        new Text(
                          'No',
                          style: new TextStyle(fontSize: 16.0),
                        ),
                        new Radio(
                          value: 1,
                          groupValue: _radioValueallergies,
                          onChanged: _handleRadioValueChangeAllergies,
                        ),
                        new Text(
                          'Yes',
                          style: new TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    ),
                    allergiesForm(),
      ],
                    
    );
  }

  String allergiesText = "";
  Widget allergiesForm(){
    if(allergies == true){
    return Container(
            color: Colors.white,
            child:TextField(
            maxLines: 3,
            controller:textControllerallergies, 
          obscureText: false,
          onChanged:(val){
              allergiesText = val;
          },
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: "Additional Information",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
        ),
        );
    }
    else{
      return SizedBox(height: 5,);
    }

  }

   submitSurvey() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
    userid = Constants.myId;
    print('userid is ===== $userid');  
    String users = Constants.myName;
    String surveyId = Constants.myName; //getChatRoomId(Constants.myName,userName);
    var now = DateTime.now();
    print(now);
    surveyId = users+'_$userid';
    print('surveyId $surveyId');
    
    Map<String, dynamic> surveyData = {
      "userId": userid,
      "user": users,
      "surveyId" : surveyId,
      "createdDate" : now,
    };
    checkSurveyData(surveyId,surveyData);

    Object? servicetype = ModalRoute.of(context)?.settings.arguments;
    QuerySnapshot querySnapshot = await databaseMethods.gettransactionId(surveyId);
    var surveyid = querySnapshot.docs.length+01;
    var transid = "TC$surveyid";
    print("transid == $transid");
    Map<String, dynamic> answer = {
      "bodyPart": dropdownValue,
      "partSection": dropdownValueHead,
      "problemText" : problemText,
      "gender" : _gender,
      "diagnosed": diagnosed,
      "diagnosedText":diagnosedText,
      "medication":medication,
      "medicationText":medicationText,
      "allergies":allergies,
      "allergiesText":allergiesText,
      "type":servicetype,
      "createdDate" : now,
      "transactionId" : transid,
      "surveyId":surveyId,
      "status":"pending",
    };
    databaseMethods.addSurveyData(surveyId,answer,transid);
  }
  }

  // ignore: missing_return
  Future<void> checkSurveyData(surveyId,surveyData) async {
    databaseMethods.getUserSurveyExist(surveyId).then((isNewData) {

      if (isNewData) {
        databaseMethods.addSurvey(surveyId,surveyData).then((value) {
          setState(() {
            _isLoading = false;
          });
        });
      } else {}
    });
  }

}