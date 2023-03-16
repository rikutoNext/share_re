import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod/riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../model/joinGroupsModel.dart';

final joinGroupsModelRepositoryProvider =
    Provider((ref) => JoinGroupsModelRepository());

class JoinGroupsModelRepository {
  static const _databaseName = 'JoinGroupsModels.db';
  static const _databaseVersion = 1;
  static const _tableName = 'JoinGroupsModels';

  final CollectionReference _chatsRef =
      FirebaseFirestore.instance.collection('lists');
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _memberSubscription;

  Future<List<JoinGroupsModel>> getFireStoreJoinGroups(String id) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(id)
        .collection('sharedLists')
        .get();
    final joinGroups = <JoinGroupsModel>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final id = data['id'] ?? '';
      final name = data['name'] ?? '';
      final photoURL = data['photoURL'] ?? '';
      final creator = data['creator'] ?? '';

      final joinGroupModel = JoinGroupsModel(
          id: id, name: name, photoURL: photoURL, creator: creator);
      joinGroups.add(joinGroupModel);
    }
    return joinGroups;
  }

  Future<List<JoinGroupsModel>> getJoinGroups() async {
    final db = await _open(); // データベースを開く

    final results = await db.query(_tableName);
    final joinGroups = <JoinGroupsModel>[];
    for (final result in results) {

      final id = result['id'] as String;
      final name = result['name'] as String;
      final photoURL = result['photoURL'] as String;
      final creator = result['creator'] as String;

      final joinGroupModel = JoinGroupsModel(
          id: id, name: name, photoURL: photoURL, creator: creator);
      joinGroups.add(joinGroupModel);
    }

    await db.close(); // データベースを閉じる

    return joinGroups;
  }

  Future<void> fileUpload(File file, String id) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('groups/$id/information');
    await storageRef.putFile(file);
  }

  Future<Database> _open() async {
    final databasePath = await getDatabasesPath();
    final databaseFilePath = path.join(databasePath, _databaseName);

    return await openDatabase(
      databaseFilePath,
      version: _databaseVersion,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE $_tableName (
          id TEXT PRIMARY KEY,
          name TEXT,
          photoURL TEXT,
          creator TEXT
        )
      ''');
      },
    );
  }

  Future<void> saveJoinGroupsList(List<JoinGroupsModel> joinGroupsList) async {

    final db = await _open(); // データベースを開く
    for (JoinGroupsModel joinGroupsModel in joinGroupsList) {
      final data = {
        'id': joinGroupsModel.id,
        'name': joinGroupsModel.name,
        'photoURL': joinGroupsModel.photoURL,
        'creator': joinGroupsModel.creator,
      };

      try {
        await db.insert(_tableName, data); // データを挿入する
      } catch (e) {

      }
    }

    await db.close(); // データベースを閉じる
  }

  Future<JoinGroupsModel> createGroups(String name, String detail,
      String? groupPhotoURL, File? file, User? myInformation) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('lists').doc();
    String docID = docRef.id;
    if (file != null) {
      await fileUpload(file, docID);
      groupPhotoURL = docID;
    }
    JoinGroupsModel model = JoinGroupsModel(
      id: docID,
      name: name,
      photoURL: groupPhotoURL!,
      creator: myInformation!.uid,
    );
    await docRef.set(model.toMap());
    await FirebaseFirestore.instance
        .collection('lists')
        .doc(docID)
        .collection('joinUsers')
        .doc(myInformation.uid)
        .set({
      'name': myInformation.displayName ?? '名称未設定',
      'uid': myInformation.uid,
      'photoURL': myInformation.photoURL ?? '写真未設定'
    });
    return model;
  }

  Future<List<JoinGroupsModel>> addJoinGroupsModel(
      JoinGroupsModel model, User myInformation) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(myInformation.uid)
        .collection('sharedLists')
        .doc(model.id)
        .set(model.toMap());

    await FirebaseFirestore.instance
        .collection('lists')
        .doc(model.id)
        .collection('joinUsers')
        .doc(myInformation.uid)
        .set({
      'uid': myInformation.uid,
      'name': myInformation.displayName,
      'photoURL': myInformation.photoURL
    }, SetOptions(merge: true));

    await saveJoinGroupsList([model]);

    return getJoinGroups();
  }

  Future<JoinGroupsModel?> getJoinGroupsModelById(int id) async {
    final db = await _open();

    final results =
        await db.query(_tableName, where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return JoinGroupsModel(
        id: results.first['id'] as String,
        name: results.first['name'] as String,
        photoURL: results.first['photoURL'] as String,
        creator: results.first['creator'] as String,
      );
    } else {
      return null;
    }
  }

  void dispose() {
    _memberSubscription?.cancel();
  }

  Future<int> deleteJoinGroupsModel() async {
    final db = await _open();

    return await db.delete(_tableName);
  }
}
