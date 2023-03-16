import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = FirebaseAuth.instance;
  return AuthRepository(firebaseAuth: firebaseAuth);
});

class AuthRepository {
  final FirebaseAuth firebaseAuth;

  AuthRepository({required this.firebaseAuth});

  Future<UserCredential> signInAnonymously() async {
    return await firebaseAuth.signInAnonymously();
  }

  Future<User?> getCurrentUserId() async {
    final User? currentUser = firebaseAuth.currentUser;
    return currentUser;
  }

  Future<User?> updateEmailAndSendVerificationEmail(String newEmail) async {
    final currentUser = firebaseAuth.currentUser;
    try {
      await currentUser?.updateEmail(newEmail);
      await currentUser?.sendEmailVerification();

    } catch (e) {

      debugPrint(e.toString());
    }

    final newCurrentUser = firebaseAuth.currentUser;

    return newCurrentUser;
  }

  Future<User?> nameUpdate(String name) async {
    final credential = firebaseAuth.currentUser;
    final uid = credential!.uid;
    final profileRef = FirebaseFirestore.instance.collection('Users').doc(uid);
    profileRef.update({'name': name});
    await credential.updateDisplayName(name);
    final credentialRe = firebaseAuth.currentUser;

    return credentialRe;
  }

  Future<User?> imageUpdate(String image) async {
    final credential = firebaseAuth.currentUser;
    final uid = credential!.uid;
    final profileRef = FirebaseFirestore.instance.collection('Users').doc(uid);

    await credential.updatePhotoURL(image);
    profileRef.update({'image': image});
    final credentialRe = firebaseAuth.currentUser;
    return credentialRe;
  }

  Future<User?> fileUpdate(File file) async {
    final credential = firebaseAuth.currentUser;
    final uid = credential!.uid;
    final profileRef = FirebaseFirestore.instance.collection('Users').doc(uid);
    final storageRef =
        FirebaseStorage.instance.ref().child('Users/$uid/profile');
    final task = await storageRef.putFile(file);
    credential.updatePhotoURL(uid);
    profileRef.update({'image': uid});
    final credentialRe = firebaseAuth.currentUser;
    return credentialRe;
  }

  Future<User?> nameAndImage(String name, String? image, File? file) async {

    final credential = firebaseAuth.currentUser;
    String uid = credential!.uid;
    final DocumentReference<Map<String, dynamic>> profileRef =
        FirebaseFirestore.instance.collection('Users').doc(uid);

    if (image != null) {
      await credential.updatePhotoURL(image);
      profileRef.set({'name': name, 'image': image});
    }
    if (file != null) {
      final storageRef =
          FirebaseStorage.instance.ref().child('Users/$uid/profile');
      final task = await storageRef.putFile(file);
      credential.updatePhotoURL(uid);
      profileRef.set({'name': name, 'image': uid});
    }

    final credential2 = firebaseAuth.currentUser;
    await credential2!.updateDisplayName(name);
    final credentialRe = firebaseAuth.currentUser;

    return credentialRe;
  }

  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user!.sendEmailVerification();

    return credential;
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<bool> isSignedIn() async {
    final currentUser = firebaseAuth.currentUser;
    return currentUser != null;
  }

  Future<bool> isEmailVerified() async {
    final currentUser = firebaseAuth.currentUser;
    await currentUser?.reload();
    return currentUser?.emailVerified ?? false;
  }

  Future<void> sendEmailVerification() async {
    final currentUser = firebaseAuth.currentUser;
    await currentUser?.sendEmailVerification();
  }

  Future<void> resetPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<User?> switchToPermanentAccount({
    required String email,
    required String password,
  }) async {
    final currentUser = firebaseAuth.currentUser;

    if (currentUser == null) {
      return null;
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    try {

      await currentUser.linkWithCredential(credential);
      await sendEmailVerification();
      return firebaseAuth.currentUser;

    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
