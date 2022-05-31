import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../index/indexpage.dart';
import '../../models/shared_configs.dart';
import '../../services/database.dart';
import 'package:flutter/material.dart';
import '../../helper/constants.dart';
import '../../helper/helperfunctions.dart';
import '../../services/auth.dart';
import 'package:badges/badges.dart';
import 'package:TrueCare2u_flutter/services/api_services.dart';
class ProfilePage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<ProfilePage> {
  var _height;
  var _width;
  var _deeppurple = const Color(0xFF512c7c);

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var textControllerName = new TextEditingController();
  var textControllerType = new TextEditingController();
  var textControllerPhone = new TextEditingController();
  var textControllerEmail = new TextEditingController();
  var textControllerBankAccNo = new TextEditingController();

  String? _name;
  String? _type;
  String? _phone;
  String? _email;
  String? _telNo;
  String? _bankacc;
  String? _bankName;

  String? _selectedBank;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedBank = bankName[0];
    getUserDetails();
    setData();
   
  }

  getUserDetails() async{
    await DatabaseMethods().getCareProvider(Constants.myId).then((value) {
      if(value.docs.length > 0){
        _type = value.docus[0].data['careType'];
        _telNo = value.docs[0].data['telNo'];
        _email = value.docs[0].data['email'];
        _bankacc = value.docs[0].data['bankAccNo'];
        _bankName = value.docs[0].data['bankName'];
        // HelperFunctions.saveUserbillingAddressPreference(value.documents[0].data['billingaddress']);
        // HelperFunctions.saveUserbirthdayPreference(value.documents[0].data['birthday']);
        // HelperFunctions.saveUserFullNamePreference(value.documents[0].data['fullname']);
        // HelperFunctions.saveUserIcNoPreference(value.documents[0].data['icNo']);
        // HelperFunctions.saveUserPhoneNoPreference(value.documents[0].data['phoneNo']);
        // HelperFunctions.saveUserWeightPreference(value.documents[0].data['weight']);
        // HelperFunctions.saveUserOccupationPreference(value.documents[0].data['occupation']);
      }
      

      
    });
    await setData();
  }

  setData() async{
    Constants.myName = (await HelperFunctions.getUserNameSharedPreference())!;
    Constants.myDeviceToken = (await HelperFunctions.getUserDeviceTokenPreference())!;
    
    textControllerName.text = Constants.myName;
    textControllerEmail.text = _email!;
    textControllerPhone.text = _telNo!;
    textControllerType.text = _type??"";
    textControllerBankAccNo.text = _bankacc??"";
    print("_bankName $_bankName");
    if(_bankName != null && _bankName != ""){
        var a = bankName.indexOf((_bankName.toString()));
        setState(() {
        _selectedBank = bankName[a];
      });
    }

    if(_bankName == null || _bankName == ""){
      setState(() {
        _selectedBank = bankName[0];
      });
    }
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
          title: Text("Profile",
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
                

                  
                Text("Full Name"),
                _buildName(),
                SizedBox(height: 15,),
                Text("Type"),
                _buildType(),
                SizedBox(height: 15,),
                Text("Phone No."),
                _buildPhone(),
                SizedBox(height: 15,),
                Text("Email"),
                _buildEmail(),
                SizedBox(height: 15,),
                Text("Bank Name"),
                _buildBankAccList(),
                SizedBox(height: 15,),
                Text("Bank Account No."),
                _buildBankAccNo(),
                // Text("Birthday"),
                // _buildBirthday(),
                SizedBox(height: 25,),
                checkboxaddon(),
                // Text("Billing Address"),
                // _buildAddress(),
                // Text("Welcome Back,",style: TextStyle(color: Colors.white),),
                
              
          ],),
          ),
        );
  }

  _buildName() {
    return Row(
            children: <Widget>[
              Flexible(
                flex: 1,
                child: TextFormField(
                  enabled: false,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 14.0),
                  decoration: InputDecoration(
                      // contentPadding: new EdgeInsets.symmetric(vertical: 0.0),
                      enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                      hintText: 'Full Name',
                      // labelText: 'Name',
                      hintStyle: TextStyle(fontSize: 11.0)),
                  controller: textControllerName,
                  validator: (String? value) {
                    if (value != null && value.isEmpty) {
                      return 'Name is Required';
                    }

                    return null;
                  },
                  onSaved: (String? value) {
                    setState(() {
                        _name = value;
                    });
                  },    
                ),),
            ],
        );
  }

  _buildType() {
    return Row(
            children: <Widget>[
              Flexible(
                flex: 2,
                child: TextFormField(
                  enabled: false,
                  // inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 14.0),
                  decoration: InputDecoration(
                      // contentPadding: new EdgeInsets.symmetric(vertical: 0.0),
                      enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                      hintText: 'Type',
                      // labelText: 'Name',
                      hintStyle: TextStyle(fontSize: 11.0)),
                  controller: textControllerType,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Type is Required ';
                    }

                    return null;
                  },
                  onSaved: (String? value) {
                    setState(() {
                        _type = value;
                    });
                  },    
                ),),
            ],
        );
  }

  _buildPhone() {
    return Row(
            children: <Widget>[
              Flexible(
                flex: 1,
                child: TextFormField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 14.0),
                  decoration: InputDecoration(
                      // contentPadding: new EdgeInsets.symmetric(vertical: 0.0),
                      enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                      hintText: 'Phone No.',
                      // labelText: 'Name',
                      hintStyle: TextStyle(fontSize: 11.0)),
                  controller: textControllerPhone,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Phone is Required ';
                    }
                    else if(value.length < 10){
                        return 'Phone must be valid';
                      }

                    return null;
                  },
                  onSaved: (String? value) {
                    setState(() {
                        _phone = value;
                    });
                  },    
                ),),
            ],
        );
  }


  

  _buildEmail() {
    return Row(
            children: <Widget>[
              Flexible(
                flex: 1,
                child: TextFormField(
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 14.0),
                  enabled: false,
                  decoration: InputDecoration(
                      // contentPadding: new EdgeInsets.symmetric(vertical: 0.0),
                      enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                      hintText: 'Email',
                      // labelText: 'Name',
                      hintStyle: TextStyle(fontSize: 11.0)),
                  controller: textControllerEmail,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Email is Required ';
                    }
                    else if(!RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)){
                        return 'Email must be valid';
                      }

                    return null;
                  },
                  onSaved: (String? value) {
                    setState(() {
                        _email = value;
                    });
                  },    
                ),),
            ],
        );
  } 

  List<String> bankName = ['Please choose a bank',
  'Affin Bank', 
  'Agro Bank',
  'Alliance Bank',
  'AmBank',
  'Bank Muamalat',
  'CIMB',
  'Exim Bank',
  'Hong Leong Bank',
  'HSBC Bank',
  'Maybank',
  'OCBC Bank',
  'Public Bank',  
  'RHB',
  'Standard Chartered Bank',
  'UOB',
  ];
  
  _buildBankAccList() {
    
    return Column(
            children: <Widget>[
                new DropdownButton<String>(
                // underline: SizedBox(),
                // dropdownColor: const Color(0xff442569),
                isExpanded: true,
                value: _selectedBank,
                style: TextStyle(fontSize: 14.0,color: Colors.black),
                items: bankName.map((val) {
                  return new DropdownMenuItem<String>(
                    value: val,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: new Text(
                            val,
                            // style: TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? val) {
                    setState(() {
                      _selectedBank = val;
                      _bankName = _selectedBank;
                    });
                    print("_selectedBank $_selectedBank");
                },
              )
            ],
        );
  }

  _buildBankAccNo() {
    return Row(
            children: <Widget>[
              Flexible(
                flex: 1,
                child: TextFormField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 14.0),
                  decoration: InputDecoration(
                      // contentPadding: new EdgeInsets.symmetric(vertical: 0.0),
                      enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                      hintText: 'Bank Account No.',
                      // labelText: 'Name',
                      hintStyle: TextStyle(fontSize: 11.0)),
                  controller: textControllerBankAccNo,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Bank No is Required ';
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    setState(() {
                        _bankacc = value;
                    });
                  },    
                ),),
            ],
        );
  }

  addonchanges(data){
    setState(() {
      savebuttonEnabled = data;
    });
  }
  bool savebuttonEnabled = false;
  Widget checkboxaddon(){
    return InkWell(
        onTap: () {
            addonchanges(!savebuttonEnabled);
        },
        child:Container(
            // height:  _height/2.8,
            width: _width,
            padding: EdgeInsets.only(left: 0,right: 0,top: 1,bottom: 1),
              
            child:Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
              mainAxisAlignment:MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    // width: _width*0.1,
                  padding: EdgeInsets.all(10),
                  child:new Container(
                  height: 20.0,
                  width: 20.0,
                    child:  Icon(Icons.check,color: savebuttonEnabled ? Colors.white:Colors.transparent,size: 12,),
                  decoration: new BoxDecoration(
                    color: savebuttonEnabled
                        ? _deeppurple
                        : Colors.white,
                    border: new Border.all(
                        width: 1.0,
                        color: savebuttonEnabled
                            ? _deeppurple
                            : Colors.grey),
                    borderRadius: const BorderRadius.all(const Radius.circular(50)),
                  ),
                ),),
                Container(
                  width: _width*0.8,
                  // padding: EdgeInsets.only(left:_width*0.1),
                  child:Text('I hereby acknowledge that the above information is correct',maxLines:3,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16,color: _deeppurple,fontWeight: FontWeight.bold),),),
                
              ],  ),
                
            ],)
             
        ),
        );
  }

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(content: Text('saving...'));
    _scaffoldKey.currentState?.showSnackBar(snackBar);
  }

  submitButton(){
    return GestureDetector(
        onTap: (){
        if(savebuttonEnabled){
          if(_formKey.currentState!.validate()) {
              _formKey.currentState?.save();
              _displaySnackBar(context);
              onSubmit();
            }
          }
        },
      child:Container(
      margin: EdgeInsets.only(left:15,right: 15,top: 5),
      padding: EdgeInsets.only(left:_width*0.02,right: _width*0.02),
      width: _width,
      height: _height*0.07,
      decoration: BoxDecoration(color:savebuttonEnabled ? _deeppurple:Colors.grey,borderRadius: BorderRadius.circular(50),
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
      margin: EdgeInsets.only(left:15,right: 15,top: 5,bottom: 15),
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
    
      Map<String,dynamic> mapData = {
        "phoneNo":_phone,
        "bankName":_bankName,
        "bankAccNo":_bankacc,
      };
        await  DatabaseMethods().updateCareProvider(Constants.myId, mapData);
          Map<String,dynamic> sendtoApi = {
            "Code":Constants.myId,
            "bankName":_bankName,
            "bankAccNo":_bankacc,
            "dateConfirmBankAcc":DateTime.now(),
          };
          print("asdasdasd $sendtoApi");
          await ApiService().updateCareProvider(sendtoApi);
      
      // HelperFunctions.saveUserbillingAddressPreference(_address);
      // HelperFunctions.saveUserbirthdayPreference(_birthday);
      // HelperFunctions.saveUserFullNamePreference(_name);
      HelperFunctions.saveUserNameSharedPreference(_name!);
      // HelperFunctions.saveUserIcNoPreference(_ic);
      // HelperFunctions.saveUserPhoneNoPreference(_phone);
      HelperFunctions.saveUserEmailSharedPreference(_email!);
      // setData();

      Future.delayed(
      Duration(seconds: 1),
      () =>  Navigator.pop(context,true));
  } 
}
