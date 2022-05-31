import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

import '../route/route.dart';
import '../models/shared_configs.dart';
class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  SharedConfigs configs = SharedConfigs();
  var route = MyCustomroute(); 
  MapType _currentMapType = MapType.normal;
  // aasd
  StreamSubscription? _locationSubscription;
  Location _locationTracker = Location();
  Marker? marker;
  Circle? circle;
  // asd


  GoogleMapController? _controller;
  
  List<Marker> allMarkers = [];
  var textController = TextEditingController();
  PageController? _pageController;
  var cities;
  var restaurantsLocations;
  int? prevPage;
  var markerIcon;
  var loca;
  bool first = true;
  LatLng _selectedLatLng = LatLng(3.08507000, 101.53281000);
  var _apikey = "AIzaSyDWbwXOGHOTMcn-DJC7nc0crmSBBMNTMNY";
  String? _address;
  LatLng? _selectedLatLngText;
  @override
  void initState() {
    super.initState();

    // _getLocationPermission();  
    _handleLocation();
    
  }

  // get address
  Future<String?> getAddress(LatLng location) async {
    try {
      var endPoint =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$_apikey';
      var response = jsonDecode((await http.get(Uri.parse(endPoint)))
          .body);
      print('response in $response');    
      print('endpoint == $endPoint');
      var data = response['results'][0]['formatted_address'];
      print('data address == $data');
      setState(() {
        _address = data;
      });
      textController.text = _address!;
      return data;
    } catch (e) {
      print(e);
    }

    return null;
  }

  // get address to LatLng
  Future<LatLng?> updateUserLatLng(String _address) async {
    Uint8List imageData = await getMarker();
    
    try {
      var endPoint =
          // 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location?.latitude},${location?.longitude}&key=$_apikey';
          'https://maps.googleapis.com/maps/api/geocode/json?address=$_address&key=$_apikey';

      var response = jsonDecode((await http.get(Uri.parse(endPoint)))
          .body);
      print('response in $response');    
      print('endpoint == $endPoint');
      var data = response['results'][0]['geometry']['location'];
      print('data address == $data');
      setState(() {
        _selectedLatLngText = LatLng(data['lat'], data['lng']);
      });
      // LocationData a = _selectedLatLngText;
      updateMarkerAndCircleCustom(_selectedLatLngText!, imageData);
      _controller?.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(data['lat'], data['lng']),
              tilt: 0,
              zoom: 18.00)));
      // textController.text = _address;
      return _selectedLatLngText;
    } catch (e) {
      print(e);
    }

    return null;
  }

  

  // togglemap
  void _onToggleMapTypePressed() {
    final MapType nextType =
        MapType.values[(_currentMapType.index + 1) % MapType.values.length];
        
    setState(() => _currentMapType = nextType);
    print('maptype is === $_currentMapType');
  }

  // getlocationpermission
  // void _getLocationPermission() async {
  //   var location = new Location();
  //   try {
  //     location.requestPermission();
  //   } on Exception catch (_) {
  //     print('There was a problem allowing location access');
  //   }
  // }

  // getMarker
  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  // updatemarkerandcirlce with latitudenlongtitude
  void updateMarkerAndCircleCustom(LatLng newLocalData, Uint8List imageData) {
    LatLng latlng = newLocalData;
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          // rotation: newLocalData.heading,
          draggable: true,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("car"),
          // radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });

    getAddress(LatLng(latlng.latitude, latlng.longitude)); 

  }

  // updatemarkerandcircle
  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude!, newLocalData.longitude!);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: newLocalData.heading!,
          draggable: true,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy!,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  // getcurrentlocation
  void getCurrentLocation() async {
    try {
      print('get current location');
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();  
      print('location is === $location');
      getAddress(LatLng(location.latitude!, location.longitude!));
      
      // print("new address is == $newaddress");
      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription!.cancel();
      }
          _controller?.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(location.latitude!, location.longitude!),
              tilt: 0,
              zoom: 18.00)));
          updateMarkerAndCircle(location, imageData);

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print("Permission Denied");
      }
    }
  }
  

  

  Completer<GoogleMapController> mapController = Completer();

  @override
  Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Maps'),
            centerTitle: true,
          ),
          body: Stack(children: <Widget>[
            GoogleMap(
              mapType: _currentMapType,
              initialCameraPosition:
                  CameraPosition(target: _selectedLatLng, zoom: 15.0),
              markers: Set.from(allMarkers),
              onTap: (position) async {
                Uint8List imageData = await getMarker();
                Marker mk1 = Marker(
                  markerId:MarkerId('1'),
                position: position,
                );
                setState(() {
                  allMarkers.add(mk1);
                });
                updateMarkerAndCircleCustom(position,imageData);
                print('postion is $position');
              },
              onMapCreated: mapCreated,
              
              // myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
            Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.only(top: kToolbarHeight + 24, right: 8),
            child: Column(
              children: <Widget>[
                  changemapButton(),
                  getlocationButton(),
                ],
              ),
            ),
            // searchbar(),
            addressbar(),
          ],
          ),
      );
  }
  changemapButton(){
    return FloatingActionButton(
                    onPressed: _onToggleMapTypePressed,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    mini: true,
                    child: const Icon(Icons.layers),
                    heroTag: "layers",
                  );
  }
  getlocationButton(){
    return FloatingActionButton(
                      mini: true,
                      child: Tooltip(
                        message: 'My location',
                        child:Icon(Icons.location_searching),
                      ),
                      onPressed: () {
                        getCurrentLocation();
                      });
  }

  searchbar(){
    return Positioned(
              top: 10,
              right: 15,
              left: 15,
              child: Container(
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      splashColor: Colors.grey,
                      icon: Icon(Icons.menu),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.go,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 15),
                            hintText: "Search..."),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.search,
                      ),
                    ),
                  ],
                ),
              ),
          );
  }

  addressbar(){
    return Positioned(
              bottom: 20,
              right: 15,
              left: 15,
              child: Container(
                decoration: BoxDecoration(
                  color:Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8)),
                height:100,
                width:200, 
                // color: Colors.white,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        maxLines: null, expands: true,
                        controller: textController,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.go,
                        onChanged: (val){
                          print('location == $val');
                          _address = textController.text;
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 15),
                            hintText: "Adress"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),

                      child: Column(children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.location_on),
                            onPressed: () {
                                setState(() {
                                  _address = textController.text;
                                });
                                updateUserLatLng(_address!);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.save),
                            onPressed: (){
                              configs.writeKey('savelocation',_address!);
                              route.goToIndex(context);
                            },
                        )  
                      ],) 
                      
                    ),
                  ],
                ),
              ),
          );
  }

  void mapCreated(controller) {
    setState(() {
      _controller = controller;
    });
  }

  Future<void> _handleLocation() async {
    await Permission.location.request;
  }

}


  

  

