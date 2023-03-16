import 'package:flutter/material.dart';

@immutable
class ChatModel {
  final String title;
  final DateTime createTime;
  final String groupID;
  final String creator;
  final String? reply;

  const ChatModel(
      {required this.title,
      required this.groupID,
      required this.createTime,
      required this.creator,
      this.reply});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'createTime': createTime,
      'creator': creator,
      'groupID': groupID,
      'reply': reply,
    };
  }
}
