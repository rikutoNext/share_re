import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_update_replace/view/auth/password_reset_screen.dart';
import 'package:share_update_replace/view_model/auth_view_model.dart';
import 'package:share_update_replace/widgets/enter_button.dart';
import 'package:share_update_replace/widgets/text_field.dart';
import 'package:sqflite/sqflite.dart';

import '../constant/color.dart';
import '../widgets/horizontal_image_picker.dart';
import 'auth/change_email.dart';
import 'top.dart';

class ProfileEdit extends ConsumerStatefulWidget {
  final photoURL;

  const ProfileEdit({Key? key, this.photoURL}) : super(key: key);

  @override
  ConsumerState<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends ConsumerState<ProfileEdit> {
  int selectedIndex = 0;
  final ImagePicker _picker = ImagePicker();
  File? file;
  String afterName = '';
  bool nickNameChange = false;
  bool field = false;

  @override
  Widget build(BuildContext context) {

    List<String> images = [
      'default.png',
      'father.png',
      'mother.png',
      'boy.png',
      'girl.png'
    ];
    String target = ref.read(authViewModelProvider)?.photoURL ?? 'default.png';
    List<String> sortedList = sortList(images, target);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_outlined),
              iconSize: 15.sp),
          automaticallyImplyLeading: false,
          toolbarHeight: 40.h,
          title: Text(
            'プロフィール',
            style: TextStyle(fontSize: 15.sp),
          )),
      backgroundColor: OftenColors.backGroundColor,
      body: Column(children: [
        SizedBox(
          height: 100.h,
          child: MyImageSelector(
            photoURL: widget.photoURL,
            file: file,
            images: sortedList,
            selectedIndex: selectedIndex,
            tappedProcess: (int index) {
              setState(() {
                selectedIndex = index;
              });
            },
            iconPressed: () async {
              final XFile? image =
                  await _picker.pickImage(source: ImageSource.gallery);
              file = File(image!.path);
              setState(() {});
            },
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ニックネーム', style: TextStyle(color: Colors.grey)),
                field
                    ? Column(
                        children: [
                          SizedBox(
                            height: 10.h,
                          ),
                          SizedBox(
                            height: 60.h,
                            width: 300.w,
                            child: MyTextField(
                              onChanged: (value) {
                                afterName = value;
                              },
                              hintText: ref
                                      .read(authViewModelProvider)
                                      ?.displayName ??
                                  '名称未設定',
                            ),
                          ),
                        ],
                      )
                    : Text(
                        nickNameChange
                            ? afterName
                            : ref.read(authViewModelProvider)?.displayName ??
                                '名称未設定',
                        style: TextStyle(color: Colors.white, fontSize: 50.sp),
                      ),
                SizedBox(height: 15.h),
                const Text('メールアドレス', style: TextStyle(color: Colors.grey)),
                Text(
                  ref.read(authViewModelProvider)?.email ?? 'メールアドレス未設定',
                  style: TextStyle(color: Colors.white, fontSize: 30.sp),
                ),
                SizedBox(height: 15.h),
                const Text('メールアドレス確認状況', style: TextStyle(color: Colors.grey)),
                Text(
                  ref.read(authViewModelProvider)?.emailVerified ?? false
                      ? '確認済み✅'
                      : '未確認',
                  style: TextStyle(color: Colors.white, fontSize: 30.sp),
                ),
              ],
            ),
            const Spacer(),
            Column(
              children: [
                field
                    ? TextButton(
                        onPressed: () async {
                          await ref
                              .read(authViewModelProvider.notifier)
                              .nameUpdate(afterName);
                          nickNameChange = true;
                          setState(() {
                            field = false;
                          });
                        },
                        child: Text(
                          '決定',
                          style: TextStyle(color: Colors.grey,fontSize: 15.sp),
                        ))
                    : TextButton(
                    // style: TextButton.styleFrom(
                    //   minimumSize: Size(200, 50), // 幅200、高さ50に指定
                    // ),
                        onPressed: () {
                          setState(() {
                            field = true;
                          });
                        },
                        child:  Text('変更',style: TextStyle(fontSize: 15.sp),)),
                SizedBox(height: 50.h),
                TextButton(
                    onPressed: () async {
                      if (selectedIndex != 0) {
                        await ref
                            .read(authViewModelProvider.notifier)
                            .imageUpdate(sortedList[selectedIndex]);
                      } else if (file != null) {
                        await ref
                            .read(authViewModelProvider.notifier)
                            .fileUpdate(file!);
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChangeEmail()),
                      );
                    },
                    child: Text('変更',style: TextStyle(fontSize: 15.sp),)),
                SizedBox(
                  height: 45.h,
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 50.h,
        ),
        EnterButton(
            enter: () async {
              if (afterName != '') {

                await ref
                    .read(authViewModelProvider.notifier)
                    .nameUpdate(afterName);
              }
              if (selectedIndex != 0) {
                await ref
                    .read(authViewModelProvider.notifier)
                    .imageUpdate(sortedList[selectedIndex]);
              } else if (file != null) {
                await ref
                    .read(authViewModelProvider.notifier)
                    .fileUpdate(file!);
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Top()),
              );
            },
            title: 'OK'),
      Spacer(),
        TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PasswordResetScreen()),
              );
            },
            child: Text('パスワードの再設定',style:TextStyle(fontSize: 10.sp) ,)),
        TextButton(
            onPressed: () async {
              ref.read(authViewModelProvider.notifier).signOut();
              final database = await openDatabase('JoinGroupsModels.db');
              await database.delete('JoinGroupsModels');
              await database.close();
            },
            child: Text(
              'ログアウト',
              style: TextStyle(color: Colors.red,fontSize: 10.sp),
            ))
      ]),
    );
  }

  List<String> sortList(List<String> list, String target) {
    int index = list.indexOf(target);
    if (index == -1) {
      // リストに指定した文字列がない場合はそのままのリストを返す
      return list;
    }
    list.removeAt(index); // リストから指定した文字列を削除
    list.insert(0, target); // リストの先頭に指定した文字列を挿入
    return list;
  }
}
