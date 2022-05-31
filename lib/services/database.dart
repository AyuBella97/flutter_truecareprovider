
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class DatabaseMethods {
  Future<void> addUserInfo(id,userData) async {
    FirebaseFirestore.instance.collection("careProvider").doc(id).set(userData).catchError((e) {
      print(e.toString());
    });
  }

  getUserLogin(String? email,password) async {
    return FirebaseFirestore.instance
        .collection("careProvider")
        .where("email", isEqualTo: email)
        .where("password",isEqualTo:password)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  getPatientInfo(String id) async {
    return FirebaseFirestore.instance
        .collection("patient")
        .where("id", isEqualTo: id)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  getUserInfo(String email) async {
    return FirebaseFirestore.instance
        .collection("careProvider")
        .where("userEmail", isEqualTo: email)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  searchByName(String searchField) {
    return FirebaseFirestore.instance
        .collection("users")
        .where('userName', isEqualTo: searchField)
        .get();
  }

  Future<bool?> addChatRoom(chatRoom, chatRoomId) async{
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .set(chatRoom)
        .catchError((e) {
      print(e);
    });
  }

  getChats(String chatRoomId) async{
    return FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy('time')
        .snapshots();
  }

  removedChatRoom(String chatRoomId,mapData) async {
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .update(mapData);
        print('data update $mapData');
  }


  Future<void> addMessage(String chatRoomId, chatMessageData)async {
    FirebaseFirestore.instance.collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .add(chatMessageData).catchError((e){
          print(e.toString());
    });
    
  }

  getUserChats(String myid) async {
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .where('usersId', arrayContains: myid)
        .where("isRemovedbyCareprovider",isEqualTo:false)
        .where('deleteDateTime', isGreaterThanOrEqualTo:Timestamp.now())
        .orderBy("deleteDateTime",descending: true)
        .snapshots();
  }

  getunreadchats(String chatRoomId,patientid) async{
    return FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .where('isRead',isEqualTo: false)
        .where('sendByUserId',isEqualTo:patientid)
        .orderBy('sendBy',descending: true)
        .orderBy('time',descending: true)
        .snapshots();
  }

  getLastChats(String chatRoomId) async{
    return FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy('time',descending: true)
        .limit(1)
        .snapshots();
  }
  
  readMessage(String chatRoomId, chatMessageData,patientId) async {
    await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .where('isRead',isEqualTo: false)
        .where('sendByUserId',isEqualTo:patientId)
        .orderBy('sendBy',descending: true)
        .orderBy('time',descending: true)
        .get()
        .then((val)=> 
        val.docs.forEach((doc) {
          print("val.documents.length ${val.docs.length}");
          doc.reference.update(chatMessageData);
        }));
        print('data update $chatMessageData');
  }
  // 
  getVideoRoomId(String a, String b) {
      return "$a\_$b";
  }

  // add videoRoom
  Future<bool?> addVideoRoom( videoRoomId, videoRoomData) async{
    FirebaseFirestore.instance
        .collection("videoRoom")
        .doc(videoRoomId)
        .set(videoRoomData)
        .catchError((e) {
      print(e);
    });  
  }
  
  getVideoRoom(String itIsMyName,int channelid) async {
    return FirebaseFirestore.instance
        .collection("videoRoom")
        .where("users", arrayContains: itIsMyName)
        .where("channelId", isEqualTo: channelid)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<bool?> joinVideoRoom(String roomId,String itIsMyName, var expiredDate) async{
    var now = new DateTime.now();
    FirebaseFirestore.instance
        .collection("videoRoom")
        .where('users', arrayContains: itIsMyName)
        .where('start_date', isGreaterThanOrEqualTo: now)
        .where('end_date', isLessThanOrEqualTo: expiredDate)
        .get()
        .catchError((e) {
      print(e);
    });
  }

  // ignore: missing_return
  Future<void> addSurvey(appointmentId,surveyData )  async {
    FirebaseFirestore.instance
        .collection("appointment")
        .doc(appointmentId)
        .set(surveyData)
        .catchError((e) {
      print(e);
    });
  }

  Future<void> addSurveyData(appointmentId, surveyData,transid) async{
    FirebaseFirestore.instance.collection("appointment")
        .doc(appointmentId)
        .collection("surveyForms")
        .doc(transid)
        .set(surveyData);
  }

  Future<void> updateSurvey(appointmentId,surveyData )  async {
    FirebaseFirestore.instance
        .collection("appointment")
        .doc(appointmentId)
        .update(surveyData)
        .catchError((e) {
      print(e);
    });
  }

  Future<void> createTestLab(id,surveyData ) async {
    FirebaseFirestore.instance
        .collection("labTest")
        .doc(id)
        .set(surveyData)
        .catchError((e) {
      print(e);
    });
  }

  getTestLab(id){
    return FirebaseFirestore.instance
        .collection("labTest")
        .where("testId",isEqualTo: id)
        .get();
  }


  gettransactionId(appointmentId) async {
    return FirebaseFirestore.instance
        .collection("appointment")
        .doc(appointmentId)
        .collection("surveyForms")
        .orderBy("createdDate")
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  getSurveyData(appointmentId) async {
    var result =  FirebaseFirestore.instance
        .collection("appointment")
        .where("appointmentId",isEqualTo: appointmentId)
        .limit(1)
        .get();
     return result;  
  }
  
  getfourtransaction(String myid) async {
    var now = DateTime.now();
    var nowsubtract = now.subtract(Duration(minutes: 120));
    var nowsubtract2 = "$nowsubtract".split(".")[0];
    var newnow ="${now.toLocal()}".split(' ')[0];
    return FirebaseFirestore.instance
        .collection("appointment")
        .where("status",whereIn:["Confirm"])
        .where("cpCode",isEqualTo:myid)
        // .where("appointmentDateTime",isGreaterThanOrEqualTo:nowsubtract2)
        .orderBy("appointmentDateTime")
        .limit(4)
        .snapshots();
  }

  getAlltransaction(String myid)async{
    var now = DateTime.now();
    var nowsubtract = now.subtract(Duration(minutes: 180));
    var nowsubtract2 = "$nowsubtract".split(".")[0];
    var newnow ="${now.toLocal()}".split(' ')[0];
    return FirebaseFirestore.instance
        .collection("appointment")
        .where("status",whereIn:["Confirm"])
        .where("cpCode",isEqualTo:myid)
        // .where("appointmentDateTime",isGreaterThanOrEqualTo:nowsubtract2)
        .orderBy("appointmentDateTime")
        .snapshots();
  }

  getArchievetransaction(userId) async {
    var now = DateTime.now();
    var newnow ="${now.toLocal()}".split(' ')[0];
    var nowsubtract = now.add(Duration(minutes: 120));
    var nowsubtract2 = "$nowsubtract".split(".")[0];
    print("new now $newnow");
    return FirebaseFirestore.instance
        .collection("appointment")
        .where("status",whereIn:["Done","Completed"])
        .where("cpCode",isEqualTo:userId)
        .where("appointmentDateTime",isLessThan:nowsubtract2)
        .orderBy("appointmentDateTime",descending: true)
        .snapshots();
  }

  getAllinOneMonth(userId) async {
    var now = new DateTime.now();
    var formatter = new DateFormat('MM');
    String month = formatter.format(now);
    var startappointmentdatetime = DateTime(DateTime.now().year, DateTime.now().month-1, 31);
    var endappointmentdate = DateTime(DateTime.now().year, DateTime.now().month+1, 1);
    var startappointmentdatetime1 ="${startappointmentdatetime.toLocal()}".split(' ')[0];
    var endappointmentdate2 ="${endappointmentdate.toLocal()}".split(' ')[0];
    print("startappointmentdatetime aaa $startappointmentdatetime1 $endappointmentdate2 ");
    return FirebaseFirestore.instance
        .collection("appointment")
        .where("cpCode",isEqualTo:userId)
        .where("status",isEqualTo: "Completed")
        .where("appointmentDateTime",isGreaterThan:startappointmentdatetime1)
        .where("appointmentDateTime",isLessThan:endappointmentdate2)
        .orderBy("appointmentDateTime",descending: true)
        .get();
  }
  



  Future<bool> getUserSurveyExist(id) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('appointment')
        .where('userId', isEqualTo: id)
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    //if user is registered then length of list > 0 or else less than 0
    return docs.length == 0 ? true : false;
  }

  // CareProvider
  getCareProvider(id) async{
    return FirebaseFirestore.instance
        .collection("careProvider")
        .limit(1)
        .where("cpCode",isEqualTo:id)
        .get();
  }

  updateCareProvider(id,mapData) async {
    FirebaseFirestore.instance
        .collection("careProvider")
        .doc(id)
        .update(mapData);
  }

  updateDeviceToken(id,mapData) async {
    FirebaseFirestore.instance
        .collection("careProvider")
        .doc(id)
        .update(mapData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getChatsDevicesToken(String chatRoomId) async{
    return FirebaseFirestore.instance
        .collection("chatRoom")
        .where('chatRoomId', isEqualTo: chatRoomId)
        .get();
  }

  // upload chat message fileimage
  Future<String> uploadImageToStorage(File imageFile) async {
    // mention try catch later on

    try {
      Reference _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      UploadTask  storageUploadTask =
      _storageReference.putFile(imageFile);
      var url = await (await storageUploadTask).ref.getDownloadURL();
      url = url.toString();
      // print(url);
      return url;
    } catch (e) {
      return "";
    }
  }

  void setImageMsg(String url, chatMessageData,chatRoomId) async {
    

    await FirebaseFirestore.instance.collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .add(chatMessageData)
        .catchError((e){
          print(e.toString());
    });
  }
  // end upload chat message fileimage

  addCall(id,mapData) async{
    await FirebaseFirestore.instance
        .collection("call")
        .doc(id)
        .set(mapData)
        .catchError((e){
          print(e.toString());
    });
  }

  // getcallIncoming(id) async{
  //   return Firestore.instance
  //       .collection("call")
  //       .where("receiverId",isEqualTo:id)
  //       .where("isPickup",isEqualTo:false)
  //       .snapshots();
  // }

  Stream<QuerySnapshot> getcallIncoming({String? id}) =>
      FirebaseFirestore.instance.collection("call")
        .where("receiverId",isEqualTo:id)
        .where("isPickup",isEqualTo:false).snapshots();

  Future<bool> updatecallIncoming(id,mapData)async{
    try{ FirebaseFirestore.instance
        .collection("call")
        .doc(id)
        .update(mapData);
        return true;
    } catch(e){
      print(e);
      return false;
    }
  }

  Future<bool> endCall({id}) async {
    try {
      await FirebaseFirestore.instance.collection("call").doc(id).delete();
      await FirebaseFirestore.instance.collection("call").doc(id).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // labtest services
  getLabTest() async{
    return FirebaseFirestore.instance
        .collection("services")
        .where("type",isEqualTo:"labtest")
        .get();
  }
  


}
