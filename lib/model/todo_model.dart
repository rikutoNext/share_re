import 'package:flutter/material.dart';

@immutable
class ToDoModel {
  final String title;
  final String ? detail;
  final DateTime createTime;
  final DateTime ? deadLine;
  final String groupID;
  final String groupPhotoURL;
  final bool completed;
  final String creator;
  final String ? doc;

  const ToDoModel({
    this.doc,
    required this.completed,
    required this.title,
    this.detail,
    required this.groupID,
    required this.groupPhotoURL,
    required this.createTime,
    this.deadLine,
    required this.creator,
  });

  ToDoModel changeCompleted() {
    return ToDoModel(completed: !completed,
        title: title,
        groupID: groupID,
        groupPhotoURL: groupPhotoURL,
        createTime: createTime,
        creator: creator);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'detail': detail,
      'createTime': createTime,
      'deadLine': deadLine,
      'completed': completed,
      'creator': creator,
      'groupID': groupID,
      'groupPhotoURL': groupPhotoURL,
    };
  }
}
