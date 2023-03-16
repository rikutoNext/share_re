class JoinUsersModel {
  final String uid;
  final String name;
  final String photoURL;

  JoinUsersModel(
      {required this.uid, required this.name, required this.photoURL});

  Map<String, String> toMap() {
    Map<String, String> classToMap = {
      'uid': uid,
      'name': name,
      'photoURL': photoURL
    };
    return classToMap;
  }

  factory JoinUsersModel.fromJson(Map<String, dynamic> json) {
    return JoinUsersModel(
        uid: json['uid'], name: json['name'], photoURL: json['photoURL']);
  }
}
