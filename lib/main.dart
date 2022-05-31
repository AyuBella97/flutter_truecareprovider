import 'package:TrueCare2u_flutter/chat/provider/imageuploadprovider.dart';
import 'package:TrueCare2u_flutter/videocall/provider/callprovider.dart';
import 'package:TrueCare2u_flutter/widgetsGloabal/animatedsplashscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'appointment/appointment.dart';
import 'appointment/appointment_details.dart';
import 'index/indexpage.dart';
import 'location/locationPage.dart';
import 'loginsignup/login.dart';
import 'loginsignup/loginregister.dart';
import 'loginsignup/register.dart';
import 'healthConditionInfoPage/healthConditionInfoPage.dart';
import 'videocall/call.dart';
import 'firebasemessaging/firebasemessaging.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

Route _generateRoute(RouteSettings settings) {
          switch (settings.name) {
            case '/':
              return CupertinoPageRoute(
                  builder: (_) => LoginSignupPage(), settings: settings);
            case '/LOGIN_PAGE':
              return CupertinoPageRoute(
                  builder: (_) => LoginPage(), settings: settings);
            case '/REGISTER_PAGE':
              return CupertinoPageRoute(
                  builder: (_) => RegisterPage(), settings: settings);
            case '/MAIN_UI':
              return CupertinoPageRoute(
                  builder: (_) => LoginSignupPage(), settings: settings);
            case '/INDEX':
              return CupertinoPageRoute(
                  builder: (_) => IndexPage(0), settings: settings);   
            case '/LOCATION_PAGE':
              return CupertinoPageRoute(
                  builder: (_) => LocationPage(), settings: settings);   
            case '/MEDICALCHECKUP':
              return CupertinoPageRoute(
                  builder: (_) => HealthConditionInfoPage(), settings: settings);  
            case '/ALL_APPOINTMENT':
              return CupertinoPageRoute(
                  builder: (_) => AppointmentPage(index: 0), settings: settings);
            case '/CURRENT_APPOINTMENT':
              return CupertinoPageRoute(
                  builder: (_) => AppointmentDetailPage(id: '',), settings: settings);
            case '/CALL_PAGE':
              return CupertinoPageRoute(
                  builder: (_) => CallPage(channelid: 0, channelName: '', role: '', appointmentId: '', isCalling: true && false, leftTimer: 0, patientname: '', id: '', endTime: ''), settings: settings);
            case '/TEST_MESSAGING':
              return CupertinoPageRoute(
                  builder: (_) => FirebaseMessagingTest(), settings: settings);         
            default:  
              return CupertinoPageRoute(
                  builder: (_) => AnimatedSplashScreen(), settings: settings);                      
          }
        }
        
class MyApp extends StatelessWidget {
  var _deeppurple = const Color(0xFF512c7c);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        ChangeNotifierProvider(create: (_) => CallProvider()),
      ],
      child:MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'truecare2uprovider',
      theme: ThemeData(
        primaryColor:  _deeppurple,
      ),
      home: AnimatedSplashScreen(),
      // home: MyHomePage(title: 'truecare2u',),
      onGenerateRoute: _generateRoute,
    ),
    );
  }
}
