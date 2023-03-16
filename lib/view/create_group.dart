import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_update_replace/view/top.dart';
import 'package:share_update_replace/view_model/auth_view_model.dart';
import 'package:share_update_replace/view_model/join_groups_view_model.dart';
import 'package:share_update_replace/view_model/todo_view_model.dart';
import 'package:share_update_replace/widgets/alert_message_dialog.dart';
import 'package:share_update_replace/widgets/enter_button.dart';
import 'package:share_update_replace/widgets/text_field.dart';

import '../widgets/horizontal_image_picker.dart';

class CreateGroup extends ConsumerStatefulWidget {
  const CreateGroup({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends ConsumerState<CreateGroup> {
  int selectedIndex = 0;
  final ImagePicker _picker = ImagePicker();
  File? file;
  String groupName = '';
  String groupDetail = '';

  @override
  Widget build(BuildContext context) {
    List<String> images = [
      'default_group.png',
      'family.png',
      'club.png',
      'work.png',
    ];

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
              'グループ作成',
              style: TextStyle(fontSize: 15.sp),
            )),
        backgroundColor: const Color.fromRGBO(53, 56, 63, 0.7),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 120.0,
              child: MyImageSelector(
                file: file,
                images: images,
                selectedIndex: selectedIndex,
                tappedProcess: (int index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                iconPressed: () async {

                  final XFile? _image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  file = File(_image!.path);
                  setState(() {});
                },
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: 400.w,
              child: MyTextField(
                  onChanged: (value) {
                    groupName = value;
                  },
                  hintText: 'グループ名'),
            ),
            SizedBox(
              height: 50.h,
            ),
            SizedBox(
              height: 250.h,
              width: 400.w,
              child: MyTextField(
                  max: 5,
                  onChanged: (value) {
                    groupDetail = value;
                  },
                  hintText: '詳細'),
            ),
            SizedBox(
                height: 50.h,
                width: 150.w,
                child: EnterButton(
                  enter: () async {
                    if (groupName == '' || groupDetail == '') {
                      AlertMessageDialog.show(context, 'グループ名が未入力です。', '');
                    } else if (selectedIndex == 0 && file != null) {
                      await ref
                          .read(joinGroupsProvider.notifier)
                          .createGroupsModel(ref.read(authViewModelProvider)!,
                              groupName, groupDetail, null, file!);
                      await ref.read(todoProvider.notifier).readTodo();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Top()));
                      });
                    } else {
                      await ref
                          .read(joinGroupsProvider.notifier)
                          .createGroupsModel(
                              ref.read(authViewModelProvider)!,
                              groupName,
                              groupDetail,
                              images[selectedIndex],
                              null);
                      await ref.read(todoProvider.notifier).readTodo();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Top()));
                      });
                    }
                  },
                  title: '登録完了',
                ))
          ],
        ));
  }
}
