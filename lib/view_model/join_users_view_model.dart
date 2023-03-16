import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_update_replace/model/join_users_model.dart';
import 'package:share_update_replace/repository/join_users_repository.dart';

final joinUsersProvider =
StateNotifierProvider<JoinUsersViewModel, List<JoinUsersModel>>((ref) {
  return JoinUsersViewModel(
    ref.read,
  );
});

class JoinUsersViewModel extends StateNotifier<List<JoinUsersModel>> {
  final _read;

  JoinUsersViewModel(this._read) : super([]);

  bool deadLineOrder = true;


  readUsers(String groupID) async{

    Stream<QuerySnapshot<Map<String, dynamic>>> str =
    await _read(joinUsersRepositoryProvider).getJoinUsers(groupID);

    str.listen((querySnapshot) {

      List<JoinUsersModel> modelsList = [];
      for (var doc in querySnapshot.docs) {
        final uid = doc.get('uid');
        final name = doc.get('name');
        final photoURL = doc.get('photoURL');

         JoinUsersModel model = JoinUsersModel(
           uid: uid,
           name: name,
           photoURL: photoURL
         );
        modelsList.add(model);
      }
      List<JoinUsersModel>sortedList = List.of(modelsList); // 破壊的な変更を避けるために新しいリストを作成する

      state = sortedList;
    });
  }
}
