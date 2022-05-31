import 'package:TrueCare2u_flutter/services/auth.dart';
import 'package:TrueCare2u_flutter/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/database.dart';

import '../../helper/helperfunctions.dart';
import 'package:TrueCare2u_flutter/index/tabPage/widgets/profiletile.dart';
import 'package:flutter/material.dart';
import '../../models/shared_configs.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingPage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<SettingPage> {
  var _height;
  var _width;
  var _deeppurple = const Color(0xFF512c7c);

  Size? deviceSize;
  // var data;
  HelperFunctions helper = HelperFunctions();
  SharedConfigs configs = SharedConfigs();
  var image;
  var username;
  var email;
  @override
  void initState() {
    // getData();
    getUser();
    // TODO: implement initState
    super.initState();
  }

  Future<void> getUser() async {
    var thisemail = await HelperFunctions.getUserEmailSharedPreference();
    var thisname = await HelperFunctions.getNameSharedPreference();
    var thisimage = await HelperFunctions.getImageSharedPreference();
    var thisusername = await HelperFunctions.getUserNameSharedPreference();
    // List<DocumentSnapshot> docs = await DatabaseMethods().getUserInfo(email).documents;
      // var userinfo = await DatabaseMethods().getUserInfo(email);
      // print('userinfo ====   ${userinfo.documents}');
      // List<DocumentSnapshot> docs = userinfo.documents;
     setState(() {
        email = thisemail;
        username = thisusername??thisname;
        image = thisimage;
     }); 
     print("$email $username $image $thisname");
      
  }
  
  Future<void> facebookLogout() async {
     Auth().signOut();
     await helper.deleteAll();
     Navigator.of(context)
          .pushNamedAndRemoveUntil("/MAIN_UI",(Route<dynamic> route) => false);
  }

  // Future<void> getData() async {
  //   await configs.readAll().then((_data){
  //     setState(() {
  //       print('this data is == $_data');
  //       image = _data['img_url'];
  //       username = _data['username'];
  //       email  = _data['email'];
  //     });
  //    });
     
  // }

  Widget profileHeader() => Container(
        height: deviceSize!.height / 5,
        width: deviceSize!.width,
        color: Colors.blue,
        child: Card(
            clipBehavior: Clip.antiAlias,
            color: Colors.blue,
            child: FittedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                        border: Border.all(width: 2.0, color: Colors.white)),
                    child: CircleAvatar(
                      radius: 40.0,
                      backgroundImage: NetworkImage(
                          image??""),
                    ),
                  ),
                  Text(
                   username??"",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                  Text(
                    email??"",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ),
      );
  Widget imagesCard() => Container(
        height: deviceSize!.height / 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Photos",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
                ),
              ),
              Expanded(
                child: Card(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                              "https://cdn.pixabay.com/photo/2016/10/31/18/14/ice-1786311_960_720.jpg"),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  bool enterIsSend = HelperFunctions.defaultEnterIsSend;
  onChangedValueActive(bool value)  {
       setState(() {
          HelperFunctions.defaultEnterIsSend = value;
          enterIsSend = HelperFunctions.defaultEnterIsSend;
          HelperFunctions.enterIsSend = value;
        });
  }

  Widget toggleStateSend(){
    return SwitchListTile(
            value: enterIsSend,
            onChanged: onChangedValueActive,
            activeColor: _deeppurple,
            secondary: new Icon(Icons.local_activity,color: enterIsSend?_deeppurple:Colors.grey,),
            title: enterIsSend ? new Text('Active',style: new TextStyle(fontSize: 23.0),) : new Text('Deactivate',style: new TextStyle(fontSize: 23.0),),
            subtitle: enterIsSend ? new Text('Enter key will send message') : new Text('Enter key will not send message'),
          );
    }
  Widget logoutbutton(){
    return GestureDetector(
      onTap: (){
        print('logout');
        facebookLogout();
      },child:Container(
          color: Colors.redAccent,
          padding: const EdgeInsets.all(8),
        child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Padding(
          //   padding: const EdgeInsets.all(4.0),
          //   child: new IconButton(
          //                         icon:FaIcon(FontAwesomeIcons.facebook), 
          //                         // onPressed: ,
          //                         color: Colors.white),
          // ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
    // return Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: <Widget>[
    //       new IconButton(
    //         icon:FaIcon(FontAwesomeIcons.facebook), 
    //         onPressed: () {  }, 
    //         ),
    //       Text("Logout"),
    //     ],
    //   );
    // return FlatButton(
    //   color: Colors.blue,
    //   textColor: Colors.white,
    //   disabledColor: Colors.grey,
    //   disabledTextColor: Colors.black,
    //   padding: EdgeInsets.all(8.0),
    //   splashColor: Colors.blueAccent,
    //   onPressed: () {
    //     /*...*/
    //   },
    //   child: new IconButton(
    //         icon:FaIcon(FontAwesomeIcons.facebook), 
    //         onPressed: () {  }, 
    //   ),
    // );
    );
  }    

  Widget bodyData() => SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // followColumn(deviceSize),
            // imagesCard(),
             toggleStateSend(),
             SizedBox(height: 10,),
            // postCard(),
           
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      // appTitle: "Profile",
      appBar: AppBar(
        centerTitle: true,
          title: Text("Settings",
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
      body: bodyData(),
      // elevation: 0.0,
    );
  }
}

Widget followColumn(Size deviceSize) => Container(
      height: deviceSize.height * 0.13,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ProfileTile(
            title: "1.5K",
            subtitle: "Posts",
          ),
          ProfileTile(
            title: "2.5K",
            subtitle: "Followers",
          ),
          ProfileTile(
            title: "10K",
            subtitle: "Comments",
          ),
          ProfileTile(
            title: "1.2K",
            subtitle: "Following",
          )
        ],
      ),
    );
  
