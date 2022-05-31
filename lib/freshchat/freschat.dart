import 'package:TrueCare2u_flutter/helper/constants.dart';
import 'package:TrueCare2u_flutter/helper/helperfunctions.dart';
import 'package:TrueCare2u_flutter/services/database.dart';
import 'package:TrueCare2u_flutter/widgetsGloabal/updateprofile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:localstorage/localstorage.dart';
import 'package:freshchat_sdk/freshchat_sdk.dart';
import 'package:freshchat_sdk/freshchat_user.dart';

class FreshChat extends StatefulWidget {
  @override
  FlutterFreshchat createState() => FlutterFreshchat();
}

class FlutterFreshchat extends State<FreshChat> {

  final LocalStorage storage = LocalStorage('example_storage');
  var _orangebutton = const Color(0xFFF47920);
  var _width;
  var _height;
  @override
  void initState() { 
    super.initState();
    getSharedPreferences();
    setUser();
    initPlatformState();
  }

  getSharedPreferences() async {
      await UpdateProfile().getUserDetails();
  }

  setUser() async{
    Constants.myEmail = (await HelperFunctions.getUserEmailSharedPreference())!;

    //creating a new user
    FreshchatUser user = await Freshchat.getUser;
    user.setEmail("${Constants.myEmail}");
    user.setFirstName("${Constants.myName.split("")[0]}");
    Constants.myName.split(" ").length > 1
        ? user.setLastName("${Constants.myName.split(" ")[1]}")
        : user.setLastName("");
    print("UID ++ ${Constants.fullname} ${Constants.myName} Constants");
    // user.phoneCountryCode = _countryCode;
    user.setPhone("+60", Constants.myPhone);

    Freshchat.setUser(user);
    await Freshchat.updateUserInfo;

    await storage.setItem('uid', Constants.myEmail);
    var x = await storage.getItem('uid');
    print("xxxxx $x");
    String uid = Constants.myEmail;
    print("UID ++ $uid");
    String? restoreId = user.getRestoreId();
    if (restoreId != null) {
      Clipboard.setData(new ClipboardData(text: restoreId));
    } else {
      Freshchat.identifyUser( restoreId: restoreId, externalId: uid);
    }

  }

  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Item> items = [
    // Item(
    //     text: 'Update User Info',
    //     onTap: (context) {
    //       Navigator.push(context,
    //           MaterialPageRoute(builder: (context) => UpdateUserInfoScreen()));
    //     }),
    // Item(
    //     text: 'Identify User',
    //     onTap: (context) async {
    //       LocalStorage storage = LocalStorage('example_storage');
    //       //Navigate to update email ID and name screen
    //       String uid = await storage.getItem('uid');
    //       String restoreId = await storage.getItem('restoreId');
    //       if (uid == null) {
    //         Scaffold.of(context).showSnackBar(
    //             SnackBar(content: Text("Please update the user info")));
    //       } else if (restoreId == null) {
    //         String newRestoreId =
    //             await FlutterFreshchat.identifyUser(externalID: uid);
    //         await storage.setItem('restoreId', newRestoreId);
    //       } else {
    //         await FlutterFreshchat.identifyUser(
    //             externalID: uid, restoreID: restoreId);
    //       }
    //     }),
    Item(
        text: 'Chat Support',
        onTap: (context) async {
          Freshchat.showConversations();
        }),
    // Item(
    //     text: 'Show FAQs',
    //     onTap: (context) async {
    //       await FlutterFreshchat.showFAQs();
    //     }),
    // Item(
    //     text: 'Get Unread Message Count',
    //     onTap: (context) async {
    //       dynamic val = await FlutterFreshchat.getUnreadMsgCount();
    //       Scaffold.of(context)
    //           .showSnackBar(SnackBar(content: Text("Message count $val")));
        // }),
    // Item(
    //     text: 'Setup Notifications',
    //     onTap: () {
    //       //Navigate to update email ID and name screen
    //     }),
    // Item(
    //     text: 'Reset User',
    //     onTap: (context) async {
    //       await FlutterFreshchat.resetUser();
    //     }),
  ];

  void initPlatformState() {
    super.initState();
    Freshchat.init(
      "721bd96b-98fb-4106-97d7-2956d6fd7733",
      "fea468e1-84ef-4bab-b363-d0223cdd62b1",
      "https://msdk.au.freshchat.com",
      cameraEnabled: false,
      gallerySelectionEnabled: true,
      teamMemberInfoVisible: false,
      responseExpectationEnabled: true,
      showNotificationBanner: true,
    );
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
      child:Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Support'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemBuilder: (context, i) {
            return ListItem(
              item: items[i].text.toString(),
              onTap: () => items[i].onTap!(context),
            );
          },
          itemCount: items.length,
        ),
        ),
      );
  }
}

class ListItem extends StatelessWidget {
  final String item;
  final VoidCallback onTap;

  ListItem({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              new CircleAvatar(
                backgroundColor: Color(0xFF512c7c),
                child: Text('TC'),
              ),
              Padding(padding: EdgeInsets.only(right: 10.0)),
              Text(item)
            ],
          ),
        ),
      ),
    );
  }
}

class Item {
  String? text;
  Function? onTap;

  Item({required String text, required Function onTap}) {
    this.text = text;
    this.onTap = onTap;
  }
}