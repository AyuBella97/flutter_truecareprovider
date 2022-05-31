import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/shared_configs.dart';

class ApiService {
  // final AsyncMemoizer _memoizer = AsyncMemoizer();
  ApiService();
  final String apiUrl =
      'http://ec2-3-1-201-214.ap-southeast-1.compute.amazonaws.com/api1';
  String? userId;
  String? accessToken;
  String? devicetoken;
  Dio dio = new Dio();

  // SharedConfigs().getKey('firebasedevice', 'String').toString();

  



  Future<String?> createPost(String token,String identifier,String systemName,String model,String version) async {
    var ret;

    Map<String, dynamic> body = {
        "access_token": token, 
        "device_id":identifier,
        "device_platform": systemName,
        "device_model": model,
        "device_version": version,
     };
     String jsonBody = json.encode(body);
    //  print('[TRACE] API CALLED  - $url');
     print('the jsonbody is $jsonBody');
     print('getting inside response');
  }

  Future updateAppointmentData(userData) async{
    try {
    var url = "http://www.truecare2u.com.my/web/truecare2u/API/appointment/update.php";
    var data;
    return await dio.post(url,data:userData,options: Options(contentType:Headers.formUrlEncodedContentType )).then((Response response) async {
        var statusCode = response.statusCode;
        print("status code ==== $statusCode");
        if (statusCode! < 200 || statusCode > 400 || json == null) {
          print("status code ===== $statusCode");
          throw new Exception("Error while fetching data 1 $statusCode");
          
        }
        data = response.toString();
        final jsonData = jsonDecode(data);
        print('data response is ====== $jsonData');
        return jsonData;
        
      });
      }catch (e) { 
        print("error message ${e}");
    }
    
    }

    Future updateAppointmentPaymentStatus(userData) async{
    try {
    var url = "http://www.truecare2u.com.my/web/truecare2u/API/appointment/updatePaymentStatus.php";
    var data;
    return await dio.post(url,data:userData,options: Options(contentType:Headers.formUrlEncodedContentType )).then((Response response) async {
        var statusCode = response.statusCode;
        print("status code ==== $statusCode");
        if (statusCode! < 200 || statusCode > 400 || json == null) {
          print("status code ===== $statusCode");
          throw new Exception("Error while fetching data 1 $statusCode");
          
        }
        data = response.toString();
        final jsonData = jsonDecode(data);
        print('data response is ====== $jsonData');
        return jsonData;
        
      });
      }catch (e) { 
        print("error message ${e}");
    }
    
    }

    Future createAppointmentPrescription(userData) async{
    try {
    var url = "http://www.truecare2u.com.my/web/truecare2u/API/prescription/create.php";
    var data;
    return await dio.post(url,data:userData,options: Options(contentType:Headers.formUrlEncodedContentType )).then((Response response) async {
        var statusCode = response.statusCode;
        print("status code ==== $statusCode");
        if (statusCode! < 200 || statusCode > 400 || json == null) {
          print("status code ===== $statusCode");
          throw new Exception("Error while fetching data 1 $statusCode");
          
        }
        data = response.toString();
        final jsonData = jsonDecode(data);
        print('data response is ====== $jsonData');
        return jsonData;
        
      });
      }catch (e) { 
        print("error message ${e}");
    }
    
    }

    

    Future createAppointmentTest(userData) async{
    try {
    var url = "http://www.truecare2u.com.my/web/truecare2u/API/Labtest/create.php";
    var data;
    return await dio.post(url,data:userData,options: Options(contentType:Headers.formUrlEncodedContentType )).then((Response response) async {
        var statusCode = response.statusCode;
        print("status code ==== $statusCode");
        if (statusCode! < 200 || statusCode > 400 || json == null) {
          print("status code ===== $statusCode");
          throw new Exception("Error while fetching data 1 $statusCode");
          
        }
        data = response.toString();
        final jsonData = jsonDecode(data);
        print('data response is ====== $jsonData');
        return jsonData;
        
      });
      }catch (e) { 
        print("error message ${e}");
    }
    
    }

    Future updateCareProvider(userData) async{
    try {
    var url = "http://www.truecare2u.com.my/web/truecare2u/API/careprovider/update.php";
    var data;
    return await dio.post(url,data:userData,options: Options(contentType:Headers.formUrlEncodedContentType )).then((Response response) async {
        var statusCode = response.statusCode;
        print("status code ==== $statusCode");
        if (statusCode! < 200 || statusCode > 400 || json == null) {
          print("status code ===== $statusCode");
          throw new Exception("Error while fetching data 1 $statusCode");
          
        }
        data = response.toString();
        final jsonData = jsonDecode(data);
        print('data response is ====== $jsonData');
        return jsonData;
        
      });
      }catch (e) { 
        print("error message ${e}");
    }
    
    }
    
  
}
