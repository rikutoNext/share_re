import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_update_replace/model/joinGroupsModel.dart';
import 'package:share_update_replace/view/top.dart';
import 'package:share_update_replace/view_model/auth_view_model.dart';
import 'package:share_update_replace/view_model/join_groups_view_model.dart';

import '../model/todo_model.dart';
import '../repository/add_todo_repository.dart';

final todoProvider = StateNotifierProvider<TodoList, List<ToDoModel>>((ref) {
  return TodoList(ref.read);
});

class TodoList extends StateNotifier<List<ToDoModel>> {
  final _read;

  TodoList(this._read) : super([]);

  bool deadLineOrder = true;

  Future<void> addTodo(
      {required String doc,
      required String title,
      required String? detail,
      required DateTime? deadLine,
      required String groupPhotoURL}) async {
    final repository = _read(todoRepositoryProvider);
    String? uid = await _read(authViewModelProvider).uid;
    await repository.addTodo(
        doc: doc,
        title: title,
        detail: detail,
        creator: uid,
        completed: false,
        deadLine: deadLine,
        groupPhotoURL: groupPhotoURL);
  }

  Future<void> readTodo() async {
    List<String> joinGroupIDsList = [];
    for (JoinGroupsModel model in _read(joinGroupsProvider)) {
      joinGroupIDsList.add(model.id);
    }
    Stream<QuerySnapshot<Map<String, dynamic>>> str =
        _read(todoRepositoryProvider).getAllDocuments(joinGroupIDsList);
    List<ToDoModel> modelsList = [];
    str.listen((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final docId = doc.id;
        final title = doc.get('title');
        final detail = doc.get('detail');
        final createTime = doc.get('createTime').toDate();
        final groupID = doc.get('groupID');
        final groupPhotoURL = doc.get('groupPhotoURL');
        final deadLine = doc.get('deadLine')?.toDate();
        final completed = doc.get('completed');
        final creator = doc.get('creator');

        ToDoModel model = ToDoModel(
          doc: docId,
          title: title,
          completed: completed,
          createTime: createTime,
          creator: creator,
          deadLine: deadLine,
          detail: detail,
          groupID: groupID,
          groupPhotoURL: groupPhotoURL,
        );
        final existingModelIndex =
            modelsList.indexWhere((element) => element.doc == docId);
        if (existingModelIndex >= 0) {
          // リストにすでに存在する場合は更新する
          modelsList[existingModelIndex] = model;
        } else {
          // 新しいデータの場合は追加する
          modelsList.add(model);
        }
      }

      if (deadLineOrder) {

        sortDeadLine(modelsList, true);
      } else {
        sortCreateTime(modelsList, true);
      }
    });
  }

  changeCompleted(ToDoModel model) {
    _read(todoRepositoryProvider).changeCompleted(model);
    _read(completedProvider.notifier).state = !model.completed;
  }

  sortCreateTime(List<ToDoModel>? modelsList, bool stateChange) {
    modelsList ??= state;
    final sortedList = List.of(modelsList); // 破壊的な変更を避けるために新しいリストを作成する
    sortedList.sort((a, b) {
      return b.createTime.compareTo(a.createTime);
    });

    if (!stateChange) {
      return sortedList;
    }
    state = sortedList; // 新しいリストをStateNotifierの状態として更新する
  }

  sortDeadLine(List<ToDoModel>? receivedModelsList, bool stateChange) {
    List<ToDoModel> modelLists = [];
    List<ToDoModel> modelListsDeadLineNull = [];
    receivedModelsList ??= state;
    for (ToDoModel ob in receivedModelsList) {
      if (ob.deadLine != null) {
        modelLists.add(ob);
      } else {
        modelListsDeadLineNull.add(ob);
      }
    }
    modelLists.sort((a, b) => a.deadLine!.compareTo(b.deadLine!));
    modelListsDeadLineNull.sort((a, b) => b.createTime.compareTo(a.createTime));

    modelLists.addAll(modelListsDeadLineNull);
    if (!stateChange) {
      return modelLists;
    }
    state = modelLists;
  }

  List<ToDoModel> groupTodo(String searchGroup, bool decideSort) {
    List<ToDoModel> copyState = List.from(state);
    List<ToDoModel> groupTodo = [];
    for (ToDoModel todo in copyState) {
      if (todo.groupID == searchGroup) {
        groupTodo.add(todo);
      }
    }
    if (decideSort || !deadLineOrder) {
      return sortCreateTime(groupTodo, false);
    } else {
      return sortDeadLine(groupTodo, false);
    }
  }
}
