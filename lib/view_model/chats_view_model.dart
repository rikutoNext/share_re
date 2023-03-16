import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_update_replace/view_model/auth_view_model.dart';

import '../model/chat_model.dart';
import '../repository/chat_repository.dart';

final chatProvider =
    StateNotifierProvider<ChatViewModel, List<ChatModel>>((ref) {
  return ChatViewModel(
    ref.read,
  );
});

class ChatViewModel extends StateNotifier<List<ChatModel>> {
  final _read;

  ChatViewModel(this._read) : super([]);

  bool deadLineOrder = true;

  Future<void> addChat({
    required String doc,
    required String title,
    String? reply,
  }) async {
    final repository = _read(chatRepositoryProvider);
    String? uid = await _read(authViewModelProvider).uid;
    await repository.addChat(
        groupID: doc, title: title, creator: uid, reply: reply);
  }

  readTodo(String groupID) async{
    Stream<QuerySnapshot<Map<String, dynamic>>> str =
       await _read(chatRepositoryProvider).getChats(groupID);
    str.listen((querySnapshot) {
      List<ChatModel> modelsList = [];
      for (var doc in querySnapshot.docs) {
        final title = doc.get('title');
        final createTime = doc.get('createTime').toDate();
        final groupID = doc.get('groupID');
        final creator = doc.get('creator');
        final reply = doc.get('reply');

        ChatModel model = ChatModel(
            reply: reply,
            title: title,
            createTime: createTime,
            creator: creator,
            groupID: groupID);
        modelsList.add(model);
      }
      List<ChatModel>sortedList = List.of(modelsList); // 破壊的な変更を避けるために新しいリストを作成する

      state = sortedList;
    });
  }
}
