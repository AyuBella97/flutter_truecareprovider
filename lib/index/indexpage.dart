import 'package:TrueCare2u_flutter/appointment/appointmentindex.dart';
import 'package:TrueCare2u_flutter/freshchat/freschat.dart';
import 'package:TrueCare2u_flutter/myaccount/myaccount.dart';

import '../chat/chatindex.dart';

import '../appointment/appointment.dart';
import '../helper/constants.dart';
import '../helper/helperfunctions.dart';
import '../loginsignup/loginregister.dart';
import '../videocall/videocall.dart';

import '../location/locationPage.dart';
import '../chat/chatroom.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import './tabPage/tabZero.dart';
import './tabPage/tabOne.dart';
import '../profile/profile.dart';
import '../models/shared_configs.dart';

class IndexPage extends StatefulWidget {
  final int index;
  IndexPage(this.index);

  // final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => new _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  double? _height;
  double? _width;

  var purpleactivecolor = const Color(0xFF512c7c);
  var purplenotactivecolor = const Color(0xFF997fbb);

  SharedConfigs configs = SharedConfigs();
  int currentIndex = 0;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  var userid;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  bool? userIsLoggedIn;
  List<Widget> _children = [
    TabZero(),
    // ChatRoom(),
    // AppointmentPage(),
    AppointmentIndex(),
    // TabOne(),
    // VideoCallPage(),
    // ChatRoom(),
    // FreshChat(),
    ChatIndex(),
    LoginSignupPage(),
    // MyHomePage(title: 'Coding with Curry'),
  ];

  @override
  void initState() {
    super.initState();
    // _getLocationPermission();
    getLoggedInState();
    // getData();
    setUserData();
    setCurrentIndex();
  }

  setCurrentIndex() {
    if (widget.index != null) {
      currentIndex = widget.index;
    }
  }

  getLoggedInState() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        userIsLoggedIn = value;
        print("aaaa $userIsLoggedIn");
        if (userIsLoggedIn == true) {
          setState(() {
            _children[3] = MyAccount();
          });
        } else {
          setState(() {
            _children[3] = LoginSignupPage();
          });
        }
      });
    });
  }

  setUserData() async {
    Constants.myName = (await HelperFunctions.getUserNameSharedPreference())!;
    Constants.myId = (await HelperFunctions.getUserIdSharedPreference())!;
    Constants.myEmail = (await HelperFunctions.getUserEmailSharedPreference())!;
    Constants.myImage = (await HelperFunctions.getImageSharedPreference())!;
  }

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //   automaticallyImplyLeading: false,
        //   actions: <Widget>[],
        //   elevation: 0.0,
        //   title: Text("HOME"),
        // ),
        // floatingActionButton: FloatingActionButton(
        //   child: Icon(Icons.add),
        //   onPressed: () {},
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: _children[currentIndex],
        //    bottomNavigationBar: BottomNavigationBar(
        //    onTap: onTabTapped, // new
        //    currentIndex: currentIndex, // new/ this will be set when a new tab is tapped
        //   items: _items,
        // ),
        bottomNavigationBar: BottomAppBar(
          child: aBottomAppBar(0),
        ));
  }

  Widget aBottomAppBar(index) {
    return BottomAppBar(
      // shape: CircularNotchedRectangle(),
      // notchMargin: 10,
      child: Container(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            MaterialButton(
              minWidth: _width! / 5,
              onPressed: () {
                setState(() {
                  currentIndex = index;
                  TabZero(); // if user taps on this dashboard tab will be active
                  currentIndex = 0;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.home,
                    color: currentIndex == 0
                        ? purpleactivecolor
                        : purplenotactivecolor,
                  ),
                  Text(
                    'Home',
                    style: TextStyle(
                      fontSize: _width! < 600 ? 12 : 14,
                      color: currentIndex == 0
                          ? purpleactivecolor
                          : purplenotactivecolor,
                    ),
                  ),
                ],
              ),
            ),
            MaterialButton(
              minWidth: _width! / 5,
              onPressed: () {
                setState(() {
                  currentIndex = 1;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.list,
                    color: currentIndex == 1
                        ? purpleactivecolor
                        : purplenotactivecolor,
                  ),
                  Text(
                    'Appointment',
                    style: TextStyle(
                      fontSize: _width! < 600 ? 12 : 14,
                      color: currentIndex == 1
                          ? purpleactivecolor
                          : purplenotactivecolor,
                    ),
                  ),
                ],
              ),
            ),
            MaterialButton(
              minWidth: _width! / 5,
              onPressed: () {
                setState(() {
                  currentIndex = 2;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.live_help,
                    color: currentIndex == 2
                        ? purpleactivecolor
                        : purplenotactivecolor,
                  ),
                  Text(
                    'Help Center',
                    style: TextStyle(
                      fontSize: _width! < 600 ? 12 : 14,
                      color: currentIndex == 2
                          ? purpleactivecolor
                          : purplenotactivecolor,
                    ),
                  ),
                ],
              ),
            ),
            MaterialButton(
              minWidth: _width! / 5,
              onPressed: () {
                setState(() {
                  // if user taps on this dashboard tab will be active
                  currentIndex = 3;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.supervised_user_circle,
                    color: currentIndex == 3
                        ? purpleactivecolor
                        : purplenotactivecolor,
                  ),
                  Text(
                    'Account',
                    style: TextStyle(
                      fontSize: _width! < 600 ? 12 : 14,
                      color: currentIndex == 3
                          ? purpleactivecolor
                          : purplenotactivecolor,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
