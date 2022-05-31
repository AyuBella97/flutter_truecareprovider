import 'package:TrueCare2u_flutter/models/shared_configs.dart';
import 'package:TrueCare2u_flutter/myaccount/pages/changepassword.dart';
import 'package:TrueCare2u_flutter/myaccount/pages/profilesetting.dart';
import 'package:TrueCare2u_flutter/pdf/pdfviewer.dart';
import 'package:TrueCare2u_flutter/services/database.dart';
import 'package:TrueCare2u_flutter/videocall/pickuplayout.dart';
import 'package:freshchat_sdk/freshchat_sdk.dart';
import 'pages/settings.dart';
import 'package:flutter/material.dart';
import '../helper/constants.dart';
import '../helper/helperfunctions.dart';
import '../services/auth.dart';
import 'package:package_info/package_info.dart';
import 'package:freshchat_sdk/freshchat_user.dart';

class MyAccount extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<MyAccount> {
  var _height;
  var _width;
  var _deeppurple = const Color(0xFF512c7c);
  var _orangebutton = const Color(0xFFF47920);
  var email;
  var username ;
  var image;
  var id ;
  var type;
  bool active = HelperFunctions.isActive??HelperFunctions.defaultisActive;


  PackageInfo? packageInfo;
  String? appName ;
  String? packageName ;
  String? version;
  String? buildNumber ;

  getVersionInfo() async {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
          appName = packageInfo.appName;
          packageName = packageInfo.packageName;
          version = packageInfo.version;
          buildNumber = packageInfo.buildNumber;
      });
       
    });
  }

  @override
  void initState() { 
    super.initState();
    getVersionInfo();
    getUser();
  }

  

  Future<void> getUser() async {
    
    var thisemail = await HelperFunctions.getUserEmailSharedPreference();
    var thisname = await HelperFunctions.getNameSharedPreference();
    var thisimage = await HelperFunctions.getImageSharedPreference();
    var thisusername = await HelperFunctions.getUserNameSharedPreference();
    var thisid = await HelperFunctions.getUserIdSharedPreference();
     setState(() {
        email = thisemail;
        username = thisusername??thisname;
        image = thisimage;
        id = thisid;
     }); 
     print("$email $username $image $thisname $id");
     getCareProviderState();
      
  }

  Future<void> getCareProviderState() async{
    DatabaseMethods().getCareProvider(id).then((_data){
       var data = _data.docs[0].data["status"];
       var newimage = _data.docs[0].data["profileImage"];
        // var state = 
        print("data isss $data");
        setState(() {
          Constants.mytype = _data.docs[0].data["careType"];
          image = newimage;
          
        });
        if(data == 1){
          setState(() {
            active = true;
            HelperFunctions.isActive = active;
          });
        }
        else{
          setState(() {
            active = false;
            HelperFunctions.isActive = active;
          });
        }
    });
    await HelperFunctions.saveImageSharedPreference(image);
    Constants.myImage = (await HelperFunctions.getImageSharedPreference())!;
  }

  updateCareproviderStatusBusy() async{
    var updateStatus = {
       "status":0,
     };
     await DatabaseMethods().updateCareProvider(Constants.myId,updateStatus); 
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Your status will be set to offline'),
        actions: <Widget>[
          Row(
          mainAxisAlignment:MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: _width*0.3,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(false);
                },
                child:  Text("Cancel",style: TextStyle(color: Colors.blue),),
              ),
            ),
              Container(
              width: _width*0.38,
              child: RaisedButton(
                color: _orangebutton,
                onPressed: () async{
                  await updateCareproviderStatusBusy();
                  Navigator.of(context).pop(true);
                },
                child: Text("Confirm",style: TextStyle(color: Colors.white)),
              ),
            )
        ],),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: PickupLayout(
      scaffold:Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
          title: Text("Account",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          backgroundColor: _deeppurple,
          elevation: 0.0),
      body: Container(
        height: _height,
        width: _width,
        // padding: EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
            child: mainLayout(),
          ),
      ),
    ),
    ),
    );
  }

  Widget mainLayout() {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 1,
          child: ClipPath(
            child: Container(
              height: _height / 2.5,
              width: _width,
              decoration: BoxDecoration(
                color: const Color(0xFF512c7c),
              ),
            ),
          ),
        ),
        myProfile(),
        settings(),
        versionCode(),
      ],
    );
  }

  Widget myProfile(){
    return Center(child:Container(
          // margin: EdgeInsets.only(left: 10, right: 40, top:   10),
          width: _width,
          // height: _height*0.5,
          // padding: EdgeInsets.only(top: 0,right: 10,left: 10),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(children: [
                
                Center(child:Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: new BorderRadius.all(Radius.circular(10.0)),
                  border: Border.all(width: 1.0, color: const Color(0xFFFFFFFF)),
                  image: DecorationImage(
                    image: image != null && image != "" ? NetworkImage(image):AssetImage('assets/icon/default-profile.png') as ImageProvider,
                    fit: BoxFit.fill
                  ),
                  ),
                  ),),
                  Container(
                      margin: EdgeInsets.only(left: _width*0.6, top: _height / 25),
                      // margin: EdgeInsets.only(left: 50,bottom: 50),
                      width: 30,
                      height: 30,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFe0f2f1)),
                    child: Icon(Icons.verified_user,color: Colors.green,size: 15,)),
              ],
              ),

                
            
                SizedBox(height: 15,),
                // Text("Welcome Back,",style: TextStyle(color: Colors.white),),
                Text("${Constants.myName}",style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Icon(Icons.email,color: Colors.grey,size: 14,),
                  SizedBox(width: 5,),
                  Text("${Constants.myEmail}",style: TextStyle(fontSize: 14,color: Colors.white),)
                ],),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Icon(Icons.verified_user,color: Colors.grey,size: 14,),
                  SizedBox(width: 5,),
                  Constants.mytype != null ? Text("${Constants.mytype.toUpperCase()}""",style: TextStyle(fontSize: 14,color: Colors.white),):Text("")
                ],),
                SizedBox(height: 5,),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //   Icon(Icons.location_on,color: Colors.grey,size: 14,),
                //   // SizedBox(width: 5,),
                //   Constants.billingaddress != null || Constants.billingaddress != "" ? Expanded(child:Text(Constants.billingaddress??"Billing address not set",style: TextStyle(fontSize: 14,color: Colors.white),textAlign: TextAlign.center,))
                //   :Text("Billing address not set",style: TextStyle(fontSize: 14,color: Colors.white),textAlign: TextAlign.center,),
                // ],),
                
              
          ],),
        ));
  }

  Widget settings(){
    return Container(
      height: _height<600?_height/1.5:_height/1.7,
      width: _width,
      margin: EdgeInsets.only(left: _width/18, right: _width/18, top:_height / 3.8,bottom: _height*0.08),
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
      padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
      child: Container(
        
        child:new Column(
          children: <Widget>[
            toggleState(),
            Container(
              padding: EdgeInsets.only(left: _height*0.02,right: _height*0.02,top: _width*0.05),
              child:new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(),
                      ),
                    );
                  },
                  child: Container(
                  padding: EdgeInsets.symmetric(vertical:15),
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width:0.5,color: Colors.black26))),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child:Row(children: [
                            Image.asset("assets/Account/icon-account-profile.png",height: 18,),
                            SizedBox(width: 15,),
                            Text(
                              "Profile",
                              textAlign: TextAlign.start, // has impact
                              style: TextStyle(color: Colors.black),
                            ),
                          ],)),
                          Icon(Icons.arrow_forward_ios,size: 12,color: Colors.grey,) 
                      ],
                      ),     
                ),
                ),

                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordPage(),
                      ),
                    );
                  },
                  child: Container(
                  padding: EdgeInsets.symmetric(vertical:15),
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width:0.5,color: Colors.black26))),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child:Row(children: [
                            Image.asset("assets/Account/icon-account-password.png",height: 18,),
                            SizedBox(width: 15,),
                            Text(
                              "Password",
                              textAlign: TextAlign.start, // has impact
                              style: TextStyle(color: Colors.black),
                            ),
                          ],)),
                          Icon(Icons.arrow_forward_ios,size: 12,color: Colors.grey,) 
                      ],
                      ),     
                ),
                ),

                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingPage(),
                      ),
                    );
                  },
                  child: Container(
                  padding: EdgeInsets.symmetric(vertical:15),
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width:0.5,color: Colors.black26))),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child:Row(children: [
                            Image.asset("assets/Account/icon-account-settings.png",height: 18,),
                            SizedBox(width: 15,),
                            Text(
                              "Settings",
                              textAlign: TextAlign.start, // has impact
                              style: TextStyle(color: Colors.black),
                            ),
                          ],)),
                          Icon(Icons.arrow_forward_ios,size: 12,color: Colors.grey,) 
                      ],
                      ),     
                ),
                ),

                GestureDetector(
                  onTap:()=> launchUrl("assets/tnc/TC2U-Terms-of-Services.pdf","Terms & Conditions"),
                  child: Container(
                  padding: EdgeInsets.symmetric(vertical:15),
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width:0.5,color: Colors.black26))),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child:Row(children: [
                            Image.asset("assets/Account/icon-account-TnC.png",height: 18,),
                            SizedBox(width: 15,),
                            Text(
                              "Terms & Conditions",
                              textAlign: TextAlign.start, // has impact
                              style: TextStyle(color: Colors.black),
                            ),
                          ],)),
                          Icon(Icons.arrow_forward_ios,size: 12,color: Colors.grey,) 
                      ],
                      ),     
                ),
                ),

                

                GestureDetector(
                  onTap:()=> launchUrl("assets/tnc/TC2U-Privacy-Policy.pdf","Privacy Policy"),
                  child: Container(
                  padding: EdgeInsets.symmetric(vertical:15),
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width:0.5,color: Colors.black26))),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child:Row(children: [
                            Image.asset("assets/Account/icon-account-TnC.png",height: 18,),
                            SizedBox(width: 15,),
                            Text(
                              "Privacy Policy",
                              textAlign: TextAlign.start, // has impact
                              style: TextStyle(color: Colors.black),
                            ),
                          ],)),
                          Icon(Icons.arrow_forward_ios,size: 12,color: Colors.grey,) 
                      ],
                      ),     
                ),
                ),

                GestureDetector(
                  onTap: (){
                    logout();
                  },
                  child: Container(
                  padding: EdgeInsets.symmetric(vertical:15),
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width:0.5,color: Colors.black26))),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child:Row(children: [
                            Image.asset("assets/Account/icon-account-logout.png",height: 18,),
                            SizedBox(width: 15,),
                            Text(
                              "Logout",
                              textAlign: TextAlign.start, // has impact
                              style: TextStyle(color: Colors.black),
                            ),
                          ],)),
                          Icon(Icons.arrow_forward_ios,size: 12,color: Colors.grey,) 
                      ],
                      ),     
                ),
                ),

              
                
              ],
            ),),
          ]),
          
    ));
  }

  onChangedValueActive(bool value)  {
       setState(() {
          active = value;
          HelperFunctions.isActive = value;
        });
        updateStatus(value);
  }

  updateStatus(value) async {
    Map<String, dynamic> changeStatus;
    if(value == false){
        changeStatus = {
          "status": 0,
        }; 
      }
      else{
          changeStatus = {
          "status": 1,
        };
      }
       await DatabaseMethods().updateCareProvider(id,changeStatus);
  }

  Widget toggleState(){
    return Container(
      decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width:0.5,color: Colors.black26))),
      child:SwitchListTile(
            value: active,
            onChanged: onChangedValueActive,
            activeColor: _deeppurple,
            secondary: new Icon(Icons.local_activity,color: active? _deeppurple:Colors.grey,),
            title:  new Text('Teleconsultation',style: new TextStyle(fontSize: 16.0,color: active ?_deeppurple:Colors.grey),),
            subtitle: active ? new Text('Online',style: TextStyle(color: Colors.green),) : new Text('Offline',style: TextStyle(color: Colors.red),),
          ));
    }

  launchUrl(selectedUrl,title) async{
    // await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => WebviewScaffold(
    //       url: selectedUrl,
    //       appBar: new AppBar(
    //         centerTitle: true,
    //         title: Text("$title"),
    //       ),
    //       withZoom: true,
    //       withLocalStorage: true,
    //       hidden: true,
    //     ),
    //     ),
    //   );

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

  Widget versionCode(){
    return Positioned(
      bottom: 10,
      left: 10,
      right: 10,
      child: Text("Version $version ",textAlign: TextAlign.center,),
    );
    }
  
  Future<void> logout() async {
     Auth().signOut();
     await HelperFunctions().deleteAll();
     await SharedConfigs().deleteAll();
     Freshchat.resetUser();
     Constants.myId = "";
     Constants.myName = "";
     Constants.myDeviceToken = "";
     Constants.myEmail = "";
     Constants.myImage = "";
     Constants.myPhone = "";
     Constants.myIc = "";
     Constants.billingaddress = "";
     Constants.fullname = "";
     Constants.dateofbirth = "";
     Navigator.of(context)
          .pushNamedAndRemoveUntil("/LOGIN_PAGE",(Route<dynamic> route) => false);
  } 
}


