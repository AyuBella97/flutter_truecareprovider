import 'package:TrueCare2u_flutter/services/auth.dart';
import 'package:TrueCare2u_flutter/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/database.dart';

import '../helper/helperfunctions.dart';
import 'package:TrueCare2u_flutter/index/tabPage/widgets/profiletile.dart';
import 'package:flutter/material.dart';
import '../models/shared_configs.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<ProfilePage> {
  late Size deviceSize;
  // var data;
  DatabaseMethods databaseMethods = DatabaseMethods();
  HelperFunctions helper = HelperFunctions();
  SharedConfigs configs = SharedConfigs();
  var image;
  var username;
  var email;
  var id;
  var _isloading = false;
  bool active = true;
  bool enterIsSend = HelperFunctions.defaultEnterIsSend;
  @override
  void initState() {
    // getData();
    getUser();
    // TODO: implement initState
    super.initState();
  }

  Future<void> getUser() async {
    setState(() {
      _isloading = true;
    });
    var thisemail = await HelperFunctions.getUserEmailSharedPreference();
    var thisname = await HelperFunctions.getNameSharedPreference();
    var thisimage = await HelperFunctions.getImageSharedPreference();
    var thisusername = await HelperFunctions.getUserNameSharedPreference();
    var thisid = await HelperFunctions.getUserIdSharedPreference();
     setState(() {
        email = thisemail;
        username = thisusername??thisname;
        image = thisimage;
        _isloading = false;
        id = thisid;
     }); 
     print("$email $username $image $thisname $id");
     getCareProviderState();
      
  }

  Future<void> getCareProviderState() async{
    databaseMethods.getCareProvider(id).then((_data){
       var data = _data.docs[0].data["status"];
        // var state = 
        print("data isss $data");
        if(data == 1){
          setState(() {
            active = true;
          });
        }
        else{
          setState(() {
            active = false;
          });
        }
    });
  }
  
  Future<void> facebookLogout() async {
     Auth().signOut();
     await helper.deleteAll();
     Navigator.pushNamed(context,"/LOGIN_PAGE");
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
        height: deviceSize.height / 5,
        width: deviceSize.width,
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
                      backgroundImage: _isloading ? AssetImage('assets/icon/default-profile.png') : NetworkImage(
                          image??"") as ImageProvider,
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
        height: deviceSize.height / 6,
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

  Widget logoutbutton(){
    return GestureDetector(
      onTap: (){
        print('logout');
        facebookLogout();
      },
      child:Container(
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
                fontSize: 16,
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

  Widget notificationpage(){
    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, '/TEST_MESSAGING');
      },
      child:Container(
          color: Colors.redAccent,
          padding: const EdgeInsets.all(8),
        child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              "Notification",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }       

  Widget profileColumn() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://avatars0.githubusercontent.com/u/12619420?s=460&v=4"),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Pawan Kumar posted a photo",
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    "25 mins ago",
                  )
                ],
              ),
            ))
          ],
        ),
      );

  Widget postCard() => Container(
        width: double.infinity,
        height: deviceSize.height / 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Post",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
                ),
              ),
              profileColumn(),
              Expanded(
                child: Card(
                  elevation: 2.0,
                  child: Image.network(
                    "https://cdn.pixabay.com/photo/2018/06/12/01/04/road-3469810_960_720.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  Widget bodyData() => SingleChildScrollView(
        child: Column(
          children: <Widget>[
            profileHeader(),
            // followColumn(deviceSize),
            // imagesCard(),
            SizedBox(height: 10,),
            toggleState(),
            // postCard(),
            SizedBox(height: 10,),
            toggleStateSend(),
            SizedBox(height: 10,),
            logoutbutton(),
            SizedBox(height: 10,),
            notificationpage(),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      // appTitle: "Profile",
      appBar: AppBar(
        title: Text("PROFILE"),
        centerTitle: true,
        automaticallyImplyLeading: false,),
      body: bodyData(),
      // elevation: 0.0,
    );
  }

  onChangedValueActive(bool value)  {
       setState(() {
          active = value;
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
       await databaseMethods.updateCareProvider(id,changeStatus);
  }

  Widget toggleState(){
    return SwitchListTile(
            value: active,
            onChanged: onChangedValueActive,
            activeColor: Colors.blueAccent,
            secondary: new Icon(Icons.local_activity),
            title: active ? new Text('Active',style: new TextStyle(fontSize: 23.0),) : new Text('Offline',style: new TextStyle(fontSize: 23.0),),
            subtitle: active ? new Text('You are set to active') : new Text('You are set to offline'),
          );
    }

    

  
  onChangedValueEntertoSend(bool value)  {
       setState(() {
          HelperFunctions.defaultEnterIsSend = value;
          enterIsSend = HelperFunctions.defaultEnterIsSend;
          HelperFunctions.enterIsSend = value;
        });
  }

  Widget toggleStateSend(){
    return SwitchListTile(
            value: enterIsSend,
            onChanged: onChangedValueEntertoSend,
            activeColor: Colors.blueAccent,
            secondary: new Icon(Icons.local_activity),
            title: new Text('Enter to send',style: new TextStyle(fontSize: 23.0),),
            subtitle: enterIsSend ? new Text('Enter key will be send message') : new Text('Enter key will not send message'),
          );
    }

}

  
