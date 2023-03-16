import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_update_replace/constant/navigator.dart';
import 'package:share_update_replace/view/profile_edit.dart';
import 'package:share_update_replace/view_model/auth_view_model.dart';
import 'package:share_update_replace/view_model/join_users_view_model.dart';

import '../view/create_group.dart';
import '../view/group.dart';
import '../view/top.dart';
import '../view_model/chats_view_model.dart';
import '../view_model/join_groups_view_model.dart';

class CustomDrawer extends ConsumerWidget {
  CustomDrawer({Key? key}) : super(key: key);
  String? photoURLSend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider);
    final joinGroups = ref.watch(joinGroupsProvider);
    final colorIndex = ref.watch(drawerIndexProvider);

    return Drawer(
      width: 250.w,
      backgroundColor: const Color.fromRGBO(53, 56, 63, 1.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 220.h,
            child: UserAccountsDrawerHeader(
              currentAccountPictureSize: Size(125.w, 125.h),
              margin: null,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
              ),
              accountName: Text(
                user?.displayName ?? '名称未設定',
                style: TextStyle(color: Colors.white, fontSize: 15.sp),
              ),
              accountEmail: Text(
                user?.email ?? 'メールアドレス未設定',
                style: TextStyle(color: Colors.white, fontSize: 10.sp),
              ),
              currentAccountPicture: myPhoto(user?.photoURL ?? '', user!.uid),
              otherAccountsPictures: [
                SizedBox(
                  height: 100.h,
                  width: 100.w,
                  child: Center(
                    child: IconButton(
                      onPressed: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileEdit(
                                    photoURL: photoURLSend,
                                  )),
                        );
                      },
                      iconSize: 20.sp,
                      icon: Icon(
                        Icons.edit,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.w,
                )
              ],
            ),
          ),
          SizedBox(
            height: 305.h,
            child: ListView.builder(
              itemCount: joinGroups.length + 1,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 125.h,
                  child: InkWell(
                    onTap: () {
                      ref.read(drawerIndexProvider.notifier).state = index;
                      if (colorIndex != 0 && index == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Top()),
                        );
                      } else if (index != colorIndex) {
                        ref
                            .read(chatProvider.notifier)
                            .readTodo(joinGroups[index - 1].id);
                        ref
                            .read(joinUsersProvider.notifier)
                            .readUsers(joinGroups[index - 1].id);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Group(
                                    model: joinGroups[index - 1],
                                  )),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      color:
                          index == colorIndex ? Colors.red : Colors.transparent,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                                index == 0
                                    ? 'Home'
                                    : joinGroups[index - 1].name,
                                style: TextStyle(
                                    fontSize: 30.sp, color: Colors.white)),
                          ),
                          index != 0
                              ? photo(joinGroups[index - 1].photoURL)
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            onPressed: () {
              navigateToNextPage(context, ref, const CreateGroup());
            },
            icon: Icon(
              Icons.add_box,
              color: Colors.grey,
              size: 20.sp,
            ),
          ),

          Text('プライバシーポリシー',
              style: TextStyle(color: Colors.grey, fontSize: 10.sp)),
          Text('使用させていただいた写真',
              style: TextStyle(color: Colors.grey, fontSize: 10.sp)),
        ],
      ),
    );
  }

  Future<String> _getFutureValue(String photoURL) async {

    Reference ref =
        FirebaseStorage.instance.ref().child('groups/$photoURL/information');
    try {
      return await ref.getDownloadURL();
    } catch (e) {
      return '$e';
    }
  }

  photo(String groupPhotoURL) {
    return SizedBox(
        height: 75.h,
        width: 75.w,
        child: groupPhotoURL.substring(
                    groupPhotoURL.length - 3, groupPhotoURL.length) ==
                'png'
            ? Image.asset('images/$groupPhotoURL')
            : FutureBuilder<String>(
                future: _getFutureValue(groupPhotoURL),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Image.asset('images/default_group.png');
                  }
                  if (snapshot.hasData) {

                    return ClipOval(
                      child: Center(
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: snapshot.data.toString(),
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Text("データが存在しません");
                  }
                },
              ));
  }

  myPhoto(String photoURL, String uid) {
    int len = photoURL.length;
    if (photoURL == '') {
      return Image.asset('images/default.png');
    } else if (photoURL.substring(len - 3, len) == 'png') {
      return Image.asset('images/$photoURL');
    } else {
      return FutureBuilder<String>(
        future: _getFutureProfile(uid),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Image.asset('images/default.png');
          }
          if (snapshot.hasData) {
            photoURLSend = snapshot.data.toString();

            return ClipOval(
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: photoURLSend!,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          } else {
            return Image.asset('images/default.png');
          }
        },
      );
    }
  }

  Future<String> _getFutureProfile(String uid) async {
    Reference ref = FirebaseStorage.instance.ref().child('Users/$uid/profile');
    try {
      String url = await ref.getDownloadURL();


      return url;
    } catch (e) {
      return '$e';
    }
  }
}
