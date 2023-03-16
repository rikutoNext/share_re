import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_update_replace/model/chat_model.dart';




final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepository());

class ChatRepository {
  final CollectionReference _chatsRef = FirebaseFirestore.instance.collection('lists');
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _chatSubscription;

  Future<void> addChat({
    required String groupID,
    required String title,
    required String creator,
    String? reply,
  }) async {
    final ChatModel chat = ChatModel(
        title: title, groupID: groupID, createTime: DateTime.now(), creator: creator, reply: reply);
    await _chatsRef.doc(groupID).collection('chats').doc().set(chat.toMap());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChats(String groupID) {

    _chatSubscription?.cancel();
    _chatSubscription = _chatsRef.doc(groupID).collection('chats').snapshots().listen((snapshot) {
      // スナップショットが更新されたときに呼び出されるコールバック関数
    });
    return _chatsRef.doc(groupID).collection('chats').snapshots();
  }

  void dispose() {
    _chatSubscription?.cancel();
  }
}
