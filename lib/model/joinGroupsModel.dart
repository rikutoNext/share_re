class JoinGroupsModel {
  final String id;
  final String name;
  final String photoURL;
  final String creator;

  JoinGroupsModel({
    required this.id,
    required this.name,
    required this.photoURL,
    required this.creator,
  });

  Map<String, String> toMap() {
    Map<String, String> classToMap = {
      'id': id,
      'name': name,
      'photoURL': photoURL,
      'creator': creator
    };
    return classToMap;
  }


  factory JoinGroupsModel.fromJson(Map<String, dynamic> json) {
    return JoinGroupsModel(
      id: json['id'],
      name: json['name'],
      photoURL: json['photoURL'],
      creator: json['creator'],
    );
  }
}
