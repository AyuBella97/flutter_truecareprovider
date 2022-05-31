class User {
  String? uid;
  String? name;
  String? userEmail;
  String? userName;
  String? status;
  int? state;
  String? profilePhoto;

  User({
    required this.uid,
    required this.name,
    required this.userEmail,
    required this.userName,
    required this.status,
    required this.state,
    required this.profilePhoto,
  });

  Map toMap(User user) {
    var data = Map<String, dynamic>();
    data['uid'] = user.uid;
    data['name'] = user.name;
    data['userEmail'] = user.userEmail;
    data['userName'] = user.userName;
    data["status"] = user.status;
    data["state"] = user.state;
    data["profile_photo"] = user.profilePhoto;
    return data;
  }

  // Named constructor
  User.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.name = mapData['name'];
    this.userEmail = mapData['userEmail'];
    this.userName = mapData['userName'];
    this.status = mapData['status'];
    this.state = mapData['state'];
    this.profilePhoto = mapData['profile_photo'];
  }
}
