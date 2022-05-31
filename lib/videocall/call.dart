import 'dart:async';
import 'package:TrueCare2u_flutter/helper/constants.dart';
import 'package:TrueCare2u_flutter/services/database.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:TrueCare2u_flutter/widgetsGloabal/formattimer.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wakelock/wakelock.dart';
import './settings.dart';

class CallPage extends StatefulWidget {
  final String appointmentId;
  final int channelid;
  final String id;
  // final String careprovidername;
  /// non-modifiable channel name of the page
  final String channelName;
  final String patientname;
  final String endTime;
  /// non-modifiable client role of the page
  final String role;
  final int leftTimer;
  final bool isCalling;
  /// Creates a call page with given channel name.
  const CallPage({Key? key, required this.channelName, required this.role, required this.channelid, required this.endTime, required this.patientname, required this.id, required this.appointmentId, required this.leftTimer, required this.isCalling,}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> with SingleTickerProviderStateMixin {
  var _width;
  var _height;

  bool isCalling = true;
  bool isPickup = false;
  bool insideCall = false;

  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  var channelid;
  var AgoraRtcEngine;
  var AgoraRenderWidget;
  var endTime;
  var _deeppurple = const Color(0xFF512c7c);
  var _lightpurple = const Color(0xFF997fbb);
  // timer
  Timer? _timer;
  int _start = 120;
  // timer
  @override
  void dispose() {
    _timer?.cancel();
    // clear users
    _users.clear();
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setchannelid();
    setState(() {
      Wakelock.enable();
      print("Wakelock.enable()");
    });
    // initialize agora sdk
    initialize();
    addPostFrameCallback();
    
  }

  void startTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    } else {
      _timer = new Timer.periodic(
        const Duration(seconds: 1),
        (Timer timer) => setState(
          () {
            if (_start < 1) {
              timer.cancel();
              _onCallEnd(context);
            } else {
              _start = _start - 1;
              if(!isCalling && !insideCall){
                insideCall = !insideCall;
                _start = widget.leftTimer*60;
                print("timer_start_start $_start");
                showTimerLeft();
              }
              if(widget.leftTimer != (int.parse('$_start')/60).floor() && !isCalling){
                Constants.lefttimer = (int.parse('$_start')/60).floor();
                Map<String, dynamic> data = {
                  "lefttimer":(int.parse('$_start')/60).floor(),
                };
                DatabaseMethods().updateSurvey(widget.appointmentId,data);
              }
            }
          },
        ),
      );
    }
  }

  Future<void> setchannelid()async {
    
     setState(() {
        channelid = widget.channelid;
        endTime = widget.endTime;
      });
      var now = DateTime.now();
      var expired  = endTime.difference(now);
      print("expired is ========= $expired");
      startTimer();
  }

  Widget countdown(){
    if(isCalling){ 
    return Center(
          child:  Text(widget.isCalling ? "Calling ${widget.patientname}":"Joining Call..."));
    }
    return SizedBox();
  }

  Widget  patientName(){
    return Positioned(
            top: _height*0.05,
            left: 10,
            // left: 0,
            child:Text("${widget.patientname}"),
            );
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = Size(1280, 720) as VideoDimensions?;
    configuration.minFrameRate = 1 as VideoFrameRate?;
    configuration.degradationPreference = DegradationPreference.MaintainFramerate;
    configuration.orientationMode = VideoOutputOrientationMode.Adaptative;
    await AgoraRtcEngine.setVideoEncoderConfiguration(configuration);
    await AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(APP_ID);
    await AgoraRtcEngine.enableVideo();
    await AgoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await AgoraRtcEngine.setClientRole(widget.role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() async {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(AgoraRenderWidget(0, local: true, preview: true));
    }
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }
  bool switchscreen = true;
  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
      setState(() {
       isCalling = false;
      });
        return 
        Container(
          height: _height,
          width: _width,
        child:
        switchscreen ?
        callScreen([views[1],views[0]]):callScreen([views[0],views[1]])); 
        // Container(
        //     child: Column(
        //   children: <Widget>[
        //     _expandedVideoRow([views[0]]),
        //     _expandedVideoRow([views[1]])
        //   ],
        // ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  _switchRender() {
    setState(() {
      switchscreen = !switchscreen;
    });
  }
  /// Toolbar layout
  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      // alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children:<Widget>[
        Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 56,
            height: 56,
            child: IconButton(
              icon: SvgPicture.asset('assets/test/flip.svg'),
              onPressed: () {_switchRender();},
            ),
          ),
        ]),
        Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    ])
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return SizedBox();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  addPostFrameCallback() {
    SchedulerBinding.instance?.addPostFrameCallback((_) async {

       FirebaseFirestore.instance
        .collection("call")
        .where("id",isEqualTo:widget.id)
        .snapshots()
        .listen((querySnapshot) {
          querySnapshot.docChanges.forEach((change) {
             if (change.type == DocumentChangeType.removed) {
              print("removed");
              setState(() {
                Wakelock.disable();
              }); 
              Navigator.pop(context);
            }
          });
          });
            // snapshot is null which means that call is hanged and documents are deleted
            

        });
      }
      
  // void _onCallEnd(BuildContext context) {
  //   Navigator.pop(context);
  // }
  void _onCallEnd(BuildContext context) async {
    await DatabaseMethods().endCall(id:widget.id);
    // Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to end the call'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () async{ 
              _onCallEnd(context);
              Navigator.of(context).pop(true);},
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.patientname??""),
      //   centerTitle: true,
      //   leading: SizedBox(),
      // ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: <Widget>[
            _viewRows(),
            // _panel(),
            _toolbar(),
            countdown(),
            Positioned(
              child: customAppBar(),
              top: 0,
              left: 0,
              right: 0,
            ),
            // !isCalling ? patientName():SizedBox(),
          ],
        ),
      ),
      ),
    );
  }

  showTimerLeft(){
            return showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // return 
                      return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                      ),      
                      elevation: 0.0,
                      backgroundColor: Colors.transparent,
                      child: Stack(children: [
                          Container(
                          padding: EdgeInsets.only(
                            top: 30,
                            bottom: 10.0,
                            left: 10.0,
                            right: 10.0,
                          ),
                          margin: EdgeInsets.only(top: 25.0),
                          decoration: new BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                offset: const Offset(0.0, 10.0),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("This consultation session is valid for ${widget.leftTimer} minutes",style: TextStyle(color: _deeppurple,),overflow: TextOverflow.ellipsis,maxLines: 1,textAlign: TextAlign.center),
                               Divider(),
                              SizedBox(height: 10,),
                              
                              Divider(),
                              SizedBox(height: 5,),
                                   Container(
                                    width: _width*0.3,
                                    height: _height*0.05,
                                    child: RaisedButton(
                                       color: _deeppurple,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                        side: BorderSide(color: _deeppurple)
                                      ),
                                      // shape: CircleBorder(),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Text("OK ",style: TextStyle(color: Colors.white),),
                                        // SizedBox(width: 5,),
                                        Icon(
                                          Icons.check,
                                          size: 20.0,
                                          color: Colors.white,
                                        ),
                                      ],),
                                      
                                      
                                    ),),
                             
                            ],
                          ),
                      ),
                        Positioned(
                        left: 16,
                        right: 16,
                        child: CircleAvatar(
                          backgroundColor: _lightpurple,
                          radius: 25.0,
                          child: Icon(Icons.info_outline,color: Colors.white,),
                        ),
                      ),
                    ],),
                    // dialogContent(context),
                  );
                  });

            }

            Widget callScreen(views){
                var thisview = views;
                return Stack(
                  children: <Widget>[
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: thisview[0],
                    ),
                    Positioned(
                      child: customAppBar(),
                      top: 0,
                      left: 0,
                      right: 0,
                    ),
                    Positioned(
                      top: 0,
                      bottom: _height*0.15,
                      left: 0,
                      right: 15,
                      child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container( 
                          width: 80,
                          height: 100,
                            child: thisview[1],
                          ),
                      ]
                      )),
              ]);

              }

              Widget customAppBar() {
              return AppBar(
                backgroundColor: Colors.transparent,
                centerTitle: true,
                    leading: IconButton(icon: SvgPicture.asset('assets/test/arrow_left.svg'), onPressed: () {_onWillPop();}),
                    title: Column(
                      children: <Widget>[
                        Text(
                          !isCalling ? '${widget.patientname}':'',
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                        Text('${formatTimer(_start)}', style: TextStyle(color: Colors.black, fontSize: 14)),
                      ],
                    ),
                    elevation: 0,
                  
                );
              }
}
