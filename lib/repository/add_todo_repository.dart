import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../model/todo_model.dart';

final todoStreamProvider =
    StreamProvider.autoDispose.family<QuerySnapshot, String>((ref, docList) {
  final collection1 =
      FirebaseFirestore.instance.collection('collection1').snapshots();
  final collection2 =
      FirebaseFirestore.instance.collection('collection2').snapshots();
  final collection3 =
      FirebaseFirestore.instance.collection('collection3').snapshots();
  var a = Rx.merge([collection1, collection2, collection3]);
  return a;
});

final todoRepositoryProvider =
    Provider<TodoRepository>((ref) => TodoRepository());

class TodoRepository {
  final CollectionReference _todosRef =
      FirebaseFirestore.instance.collection('lists');

  Future<void> addTodo({
    required String doc,
    required String title,
    required String detail,
    required bool completed,
    required String creator,
    required DateTime ? deadLine,
    required String groupPhotoURL,

  }) async {
    final ToDoModel todo = ToDoModel(
      title: title,
      detail: detail,
      groupID: doc,
      groupPhotoURL: groupPhotoURL,
      createTime: DateTime.now(),
      completed: false,
      deadLine: deadLine,
      creator:creator
    );
    await _todosRef.doc(doc).collection('tasks').doc().set(todo.toMap());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllDocuments(
      List<String> docs) {
    List<Stream<QuerySnapshot<Map<String, dynamic>>>> snapshots = [];
    for (String doc in docs) {
      snapshots.add(FirebaseFirestore.instance
          .collection('lists')
          .doc(doc)
          .collection('tasks')
          .snapshots());
    }
    return Rx.merge(snapshots);
  }

  void changeCompleted(ToDoModel model){
     ToDoModel changedModel=model.changeCompleted();
    _todosRef.doc(model.groupID).collection('tasks').doc(model.doc).set(changedModel.toMap());
  }
}
