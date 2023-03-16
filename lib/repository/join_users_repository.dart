import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final joinUsersRepositoryProvider =
    Provider<JoinUsersRepository>((ref) => JoinUsersRepository());

class JoinUsersRepository {
  final CollectionReference _membersRef =
      FirebaseFirestore.instance.collection('lists');
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _memberSubscription;

  Stream<QuerySnapshot<Map<String, dynamic>>> getJoinUsers(String groupID) {
    print('adhj');
    _memberSubscription?.cancel();
    // _memberSubscription = _membersRef
    //     .doc(groupID)
    //     .collection('joinUsers')
    //     .snapshots()
    //     .listen((snapshot) {
    //       print('auhdi');
    //
    //   // スナップショットが更新されたときに呼び出されるコールバック関数
    // });

    return _membersRef.doc(groupID).collection('joinUsers').snapshots();
  }
}
