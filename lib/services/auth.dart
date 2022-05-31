import 'dart:io';
import 'package:TrueCare2u_flutter/models/user.dart';
import 'package:TrueCare2u_flutter/videocall/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseUser;
import 'package:device_info/device_info.dart';
import '../models/user.dart' as User;
import 'api_services.dart';
import '../models/shared_configs.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final facebookLogin = FacebookLogin();
  // GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoggedIn = false;
  late Map userProfile;
  var id;
  var name;
  var email;

  User.User? _userFromFirebaseUser(firebaseUser.User user) {
    if (user != null) {
      return _userFromFirebaseUser(user);
    } else {
      return null;
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential authresult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      firebaseUser.User user = authresult.user!;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential authresult = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      firebaseUser.User user = authresult.user!;
      print("user iss ${_userFromFirebaseUser(user)}");
      return _userFromFirebaseUser(user);
    } catch (e) {
      print('error is ${e.toString()}');
      return "exist";
    }
  }

  Future getuserid() async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('careProvider')
        .orderBy('cpCode', descending: true)
        .limit(1)
        .get();

    return result;
  }

  Future resetPass(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Future<FirebaseUser> signInGoogle() async {
  //   try {
  //     GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
  //     GoogleSignInAuthentication _signInAuthentication =
  //         await _signInAccount.authentication;

  //     final AuthCredential credential = GoogleAuthProvider.getCredential(
  //         accessToken: _signInAuthentication.accessToken,
  //         idToken: _signInAuthentication.idToken);
  //     AuthResult result = await _auth.signInWithCredential(credential);
  //     FirebaseUser user = result.user;
  //     return user;
  //   } catch (e) {
  //     print("Auth methods error");
  //     print(e);
  //     return null;
  //   }
  // }

  // custom

  //facebook login future is here
  // Future<FirebaseUser> signInFB() async {
  //   bool errorLogin = false;
  //   FirebaseUser fbUser;
  //   facebookLogin.loginBehavior = FacebookLoginBehavior.nativeWithFallback;
  //   // facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;

  //   final FacebookLoginResult facebookLoginResult = await facebookLogin.logIn(['email', 'public_profile']);

  //   if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
  //     FacebookAccessToken myToken = facebookLoginResult.accessToken;
  //     AuthCredential credential =
  //         FacebookAuthProvider.getCredential(accessToken: myToken.token);

  //     var result = await _auth.signInWithCredential(credential);
  //     fbUser = result.user;
  //   }
  //   else if (facebookLoginResult.status == FacebookLoginStatus.error) {
  //      facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
  //      FacebookAccessToken myToken = facebookLoginResult.accessToken;
  //      AuthCredential credential =
  //         FacebookAuthProvider.getCredential(accessToken: myToken.token);

  //     var result = await _auth.signInWithCredential(credential);
  //     fbUser = result.user;
  //   }
  //   else{
  //     errorLogin = true;
  //   }

  //   if (!errorLogin) {
  //     return fbUser;
  //   }
  //   else {
  //     print("error ");
  //     return null;
  //   }

  // }

  Future<bool> authenticateUser(firebaseUser.User user) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('careProvider')
        .where('userEmail', isEqualTo: user.email)
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    //if user is registered then length of list > 0 or else less than 0
    return docs.length == 0 ? true : false;
  }

  Future<void> addDataToDbFacebookorGoogle(firebaseUser.User currentUser) async {
  String? username = currentUser.displayName;
    // String username = username2.split('_')[0];
    print('username === !!!! $username');
    User.User user = User.User(
        uid: currentUser.uid,
        userEmail: currentUser.email,
        name: currentUser.displayName,
        profilePhoto: currentUser.photoURL,
        userName: username,
        status:null,
        state:null,
        );

        FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .set({
          'uid': user.uid,
          'name': user.name,
          'userEmail': user.userEmail,
          'userName': user.userName,
          'status': user.status,
          'state': user.state,
          'profile_photo': user.profilePhoto,
        });
  }

  sendLoginToApi(String token) async {
    var storageService = SharedConfigs();

    var deviceId;
    await storageService.readKey('devicetoken').then((data) {
      deviceId = data;
    });
    // take phone model id and data
      var systemName;
      var version;
      var name;
      var model;
      var identifier;
      if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      // systemName = androidInfo.version.release;
      systemName = 'android';
      version = androidInfo.version.sdkInt;
      name = androidInfo.manufacturer;
      model = androidInfo.model;
      identifier = androidInfo.androidId;
      // print('data is ======== Android $systemName (SDK $version), $name $model');
      // Android 9 (SDK 28), Xiaomi Redmi Note 7
    }
    else if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      // systemName = iosInfo.systemName;
      systemName = 'ios';
      version = iosInfo.systemVersion;
      name = iosInfo.name;
      model = iosInfo.model;
      identifier = iosInfo.identifierForVendor;
      // print('data ======= $systemName $version, $name $model');
      // iOS 13.1, iPhone 11 Pro Max iPhone
    }
    // end of data model id
    var tokenid = token;

    String apiData = '$tokenid|$identifier|$systemName|$model|$version';
    var systemName1 = systemName.toString();
    var model1 = model.toString();
    var version1 = version.toString();
    // print('the apidata is =======!!!!! $tokenid  && $identifier && $systemName1 && (SDK $version), $name $model; ');
    ApiService().createPost(tokenid,identifier,systemName1,model1,version1);
  }

  // Future<String> loginFacebook() async{
  //   var id;
  //   final FacebookLoginResult facebookLoginResult = await facebookLogin.logIn(['email', 'public_profile']);
  //   FacebookAccessToken facebookAccessToken = facebookLoginResult.accessToken;
  //   AuthCredential authCredential = FacebookAuthProvider.getCredential(accessToken: facebookAccessToken.token);
  //   FirebaseUser fbUser;
  //   try{
  //     fbUser = (await _auth.signInWithCredential(authCredential)).user;
  //     }catch(e){
  //     print(e);
  //   }

  //   if(fbUser != null){
  //       print("fbuser ==== ${fbUser.displayName},  aaa === ${fbUser.email}, aaa === ${fbUser.uid},aaa === ${fbUser.photoUrl}");
  //       var userid = fbUser.uid;
  //       await SharedConfigs().writeKey('userid', fbUser.uid).then((_) {});
  //       await SharedConfigs().writeKey('username', fbUser.displayName).then((_) {});
  //       await SharedConfigs().writeKey('email', fbUser.email).then((_) {});
  //       await SharedConfigs().writeKey('img_url', fbUser.photoUrl).then((_) {});
  //       id =  userid;

  //   }
  //   else{
  //     id =  null;
  //   }
  //   return id;
  // }


  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

}
