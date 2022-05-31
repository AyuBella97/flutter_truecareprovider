import 'package:TrueCare2u_flutter/helper/constants.dart';
import 'package:TrueCare2u_flutter/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../services/database.dart';
import 'appointment_details.dart';
class LabRequest extends StatefulWidget {
  final String appointmentId;
  LabRequest({Key? key, required this.appointmentId}) : super(key: key);

  @override
  _LabRequestState createState() => _LabRequestState();
}

class _LabRequestState extends State<LabRequest> {
  var _deeppurple = const Color(0xFF512c7c);
  var _lightpurple = const Color(0xFF997fbb);
  var _orangebutton = const Color(0xFFF47920);
  var _width;
  var _height;
  var selectedtest;
  var selectedprice;
  var selectedcode;

  List testList = [];
  List testPrice = [];
  List testCode = [];
  bool isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    testList.add("-Select-");
    testPrice.add("0");
    testCode.add("-");
    selectedtest = testList[0];
    getTest();
  }


  getTest()async{
    
    await DatabaseMethods().getLabTest().then((_data){
      print("data _data ${_data.docs[0].data}");
      List namelist = _data.docs[0].data['name'];
      List pricelist = _data.docs[0].data['price'];
      List codelist = _data.docs[0].data['code'];
      namelist.forEach((v) {
        testList.add(v);
      });
      pricelist.forEach((v) {
        testPrice.add(v);
      });
      codelist.forEach((v) {
        testCode.add(v);
      });
      
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;  

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        // automaticallyImplyLeading: false,p
        title: Text('Laboratory',style: TextStyle(color: Colors.white,),),
        centerTitle: true,
        backgroundColor: _deeppurple,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white,size: 14,),
            onPressed: () => Navigator.of(context).pop(),
          ),
      ),
      body: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child:Container(
            margin: EdgeInsets.only(bottom:10),
          child: 
          Column(
          children: <Widget>[
            isLoading ? Center(child: CircularProgressIndicator(),):thislabtest(),
             buttonSubmit(),
          ]
      ),
    ),
    ),
    );
  }

  Widget thislabtest(){
    return Container(
            margin: EdgeInsets.only(left:_width*0.05,right: _width*0.05,top: _height*0.02),
            padding: EdgeInsets.only(left:15,right: 15,top: 15),
            width: _width,
            height: _height*0.15,
            decoration: customboxshadow,
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  
                
                Text("List of Test",style: TextStyle(color: _deeppurple,fontSize: 16,fontWeight: FontWeight.bold),),
                SizedBox(height: _height*0.01,),
                
                Container(
                  width: _width,
                // padding: EdgeInsets.all(15),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    _selectTest(),
                   
                ],),
                
              ),

              
                  
            ],),
            );
  }

  final customboxshadow = BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(5),
                  boxShadow: [ 
                            BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1.5,
                            blurRadius: 2,
                            offset: new Offset(2.0, 2.0), // changes position of shadow
                        ),
                      ]);

  final dropdownTextStyle = TextStyle(fontSize: 12,color: Colors.white);
  _selectTest(){ 
    return Container(
      margin: EdgeInsets.all(_height*0.01),
      height: _height>600?_height*0.07:_height*0.09,
      child:
      new Container(
      // margin: EdgeInsets.only(left: _width/15, right: _width/15, top: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: const Color(0xff442569),
      ),
      padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new DropdownButton<String>(
            underline: SizedBox(),
            dropdownColor: const Color(0xff442569),
            isExpanded: true,
            value: selectedtest,
            items: testList
                .map((purposeTemp) {
              return new DropdownMenuItem<String>(
                value: purposeTemp,
                child: Row(children: <Widget>[
                  new Text(purposeTemp,style: dropdownTextStyle,overflow: TextOverflow.ellipsis,maxLines: 1,),
                 
                ],),
              );
            }).toList(),
            onChanged: (String? type) {
                setState(() {
                  selectedtest = type;
                });
                
                for(var i=0;i<testList.length;i++){
                  if(testList[i] == selectedtest){
                    setState(() {
                      selectedprice = testPrice[i] ;
                      selectedcode = testCode[i];
                    });

                  }
                }

                print("selectedtype == $selectedtest $selectedcode $selectedprice");
                
              
            },
          )
        ],
      ),
    ));
  }

  buttonSubmit(){
    return Container(
          height: _height*0.05,
          width: _width,
          margin: EdgeInsets.only(top:_height*0.02,bottom: _height*0.02),child:Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
      InkWell(
      onTap: (){
          showConfirmationDialog();
      },
      child: Container(
          height: _height*0.05,
          width: _width*0.2,
          decoration: BoxDecoration(
            color: _deeppurple,borderRadius: BorderRadius.circular(2),
            boxShadow: [ 
                      BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0.5,
                      blurRadius: 1,
                      offset: new Offset(0.0, 0.0), // changes position of shadow
                  ),
                ]),
                child: Center(child:Text("Submit",style: TextStyle(color: Colors.white),textAlign: TextAlign.center,)),
          ),),
    ],),
    ); 
    
  }

  showConfirmationDialog(){
     return showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(5.0)), //this right here
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: _height*0.02,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                Text("Confirm to submit?",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                              ],),
                              SizedBox(height: _height*0.02,),
                              Row(
                                mainAxisAlignment:MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: _width*0.3,
                                    child: GestureDetector(
                                      onTap: () async {
                                        await updateAppointment();
                                        Navigator.of(context).pop();
                                      },
                                      child:  Text("Cancel",style: TextStyle(color: Colors.blue),),
                                    ),
                                  ),
                                   Container(
                                    width: _width*0.38,
                                    child: RaisedButton(
                                      color: _orangebutton,
                                      onPressed: () async {
                                        setState(() {
                                          Constants.testLab = selectedtest;  
                                        });
                                        print("Constants.testLab ${Constants.testLab}");
                                        await updateAppointment();
                                        Navigator.pop(context);
                                        
                                      },
                                      child: Text("Confirm",style: TextStyle(color: Colors.white)),
                                    ),
                                  )
                              ],),
                             
                            ],
                          ),
                        ),
                      ),
                    );
                  });

  }   

  updateAppointment() async{
        
        Map apiData = {
          "ApId":widget.appointmentId,
          "RequestTest":Constants.testLab,
          "RequestTestPrice":selectedprice,
          "RequestDate":DateTime.now(),
        };

        String? testId;
        await ApiService().createAppointmentTest(apiData).then((value) {
          print("value ${value['Code']}");
          testId = value['Code'];
        });

        Map<String, dynamic> surveyData = {
          "testId":testId,
          "testlab":Constants.testLab,
          "testprice":selectedprice,
          "testcode":selectedcode,
        };

        Map<String, dynamic> surveyDataTestLab = {
          "appointmentId":widget.appointmentId,
          "testId":testId,
          "testlab":Constants.testLab,
          "testprice":selectedprice,
          "testcode":selectedcode,
          "status":"Pending",
          "paymentStatus":"Pending",
          "paymentDate":null,
        };
        
        print("surveyData $surveyDataTestLab");
     await DatabaseMethods().updateSurvey(widget.appointmentId,surveyData);
     await DatabaseMethods().createTestLab(testId,surveyDataTestLab);
  }
}