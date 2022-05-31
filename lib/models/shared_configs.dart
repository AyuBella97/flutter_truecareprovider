import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SharedConfigs {
  final storage = new FlutterSecureStorage();
  // final key = 'defaultKey';

// Read value
  Future<String?> readKey(String key) async {
    String? value = await storage.read(key: key);
    return value;
  }

// Read all values
  Future<Map<String, String>> readAll() async {
    Map<String, String> allValues = await storage.readAll();
    return allValues;
  }

// Delete value
Future<void> deleteKey(String key) async {
   await storage.delete(key: key);
  }


// Delete all
Future<void> deleteAll() async {
   await storage.deleteAll();
  }
// await storage.deleteAll();



  Future<void> writeKey(String key, String value) async {
    await storage.write(key: key, value: value);
  }
// Write value


}
