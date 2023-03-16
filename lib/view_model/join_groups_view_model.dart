import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_update_replace/model/joinGroupsModel.dart';

import '../repository/joing_groups_repository.dart';
import 'auth_view_model.dart';

class JoinGroupsViewModel extends StateNotifier<List<JoinGroupsModel>> {
  final _read;

  JoinGroupsViewModel(this._read) : super([]);

  Future<void> joinGroupConfirmation() async {
    List<JoinGroupsModel> joinGroupsList =
        await _read(joinGroupsModelRepositoryProvider).getJoinGroups();
    state = joinGroupsList;
  }

  Future<void> createGroupsModel(User myInformation, String name, String detail,
      String? groupPhotoURL, File? file) async {
    JoinGroupsModel model = await _read(joinGroupsModelRepositoryProvider)
        .createGroups(name, detail, groupPhotoURL, file, myInformation);

    state = await _read(joinGroupsModelRepositoryProvider).addJoinGroupsModel(
        model,
    myInformation);
  }

  Future<void> joinGroupsModel(JoinGroupsModel model,User myInformation, ) async {
  state = await _read(joinGroupsModelRepositoryProvider)
        .addJoinGroupsModel(model,myInformation);

  }

  Future<void> login() async {
    await _read(joinGroupsModelRepositoryProvider).deleteJoinGroupsModel();
    List<JoinGroupsModel> joinGroupsList =
        await _read(joinGroupsModelRepositoryProvider)
            .getFireStoreJoinGroups(_read(authViewModelProvider).uid);
    await _read(joinGroupsModelRepositoryProvider)
        .saveJoinGroupsList(joinGroupsList);
    state = joinGroupsList;
  }
}

final joinGroupsProvider =
    StateNotifierProvider<JoinGroupsViewModel, List<JoinGroupsModel>>((ref) {
  return JoinGroupsViewModel(ref.read);
});
