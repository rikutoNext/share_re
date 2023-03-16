import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_update_replace/constant/color.dart';
import 'package:share_update_replace/widgets/enter_button.dart';

import '../model/joinGroupsModel.dart';
import '../view_model/join_groups_view_model.dart';
import '../view_model/todo_view_model.dart';

class AddView extends ConsumerStatefulWidget {
  const AddView({Key? key}) : super(key: key);

  @override
  ConsumerState<AddView> createState() => _AddViewState();
}

class _AddViewState extends ConsumerState<AddView> {
  String deadLine = '期限を選択';
  DateTime? deadLineDateTime;
  String group = 'グループを選択';
  String title = '';
  String detail = '';
  String? groupID;
  String? groupPhotoURL;

  @override
  Widget build(BuildContext context) {
    final todo = ref.read(todoProvider.notifier);
    final joinGroups = ref.read(joinGroupsProvider.notifier);

    final FocusNode _focusNode1 = FocusNode();

    final FocusNode _focusNode2 = FocusNode();

    void addTodo() async {
      await todo.addTodo(
        doc: groupID!,
        title: title,
        detail: detail,
        deadLine: deadLineDateTime,
        groupPhotoURL: groupPhotoURL!,
      );
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(toolbarHeight: 40.h),
        backgroundColor: OftenColors.backGroundColor,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(children: [
            Spacer(flex: 2),
            Text(
              'タイトルを入力してください。',
              style: TextStyle(fontSize: 15.sp, color: Colors.grey),
            ),
            SizedBox(
              height: 75.h,
              child: TextField(
                style: TextStyle(
                  fontSize: 30.sp,
                ),
                focusNode: _focusNode1,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 1.w, color: Colors.grey)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (text) {
                  _focusNode2.unfocus();
                  title = text;
                },
              ),
            ),
            const Spacer(),
            Text(
              '詳細を入力してください。',
              style: TextStyle(fontSize: 15.sp, color: Colors.grey),
            ),
            SizedBox(
              child: TextField(
                style: TextStyle(
                  fontSize: 20.sp,
                ),
                maxLines: 5,
                focusNode: _focusNode2,
                onChanged: (text) {
                  _focusNode1.unfocus();
                  detail = text;
                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 1.w, color: Colors.grey)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Spacer(),
            Text(
              '期限がある場合期限を入力してください。',
              style: TextStyle(fontSize: 15.sp, color: Colors.grey),
            ),
            TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.all(3.r)),
                minimumSize: MaterialStateProperty.all(Size.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(deadLine,
                  style: TextStyle(
                      color: deadLine == '期限を選択' ? Colors.grey : Colors.white,
                      fontSize: deadLine == '期限を選択' ? 30.sp : 50.sp)),
              onPressed: () {
                _focusNode1.unfocus();
                _focusNode2.unfocus();
                DateTime now = DateTime.now();
                DatePicker.showDatePicker(context,
                    showTitleActions: true,
                    minTime: DateTime(now.year, now.month, now.day, 23, 59, 59, 59),
                    maxTime: DateTime(2030, 12, 31),
                    onChanged: (date) {}, onConfirm: (date) {
                  deadLineDateTime = date;
                  setState(() {
                    deadLine = '${date.year}/${date.month}/${date.day}';
                  });
                }, currentTime: DateTime.now(), locale: LocaleType.jp);
              },
            ),
            const Spacer(),
            Text(
              'グループを選択してください。',
              style: TextStyle(fontSize: 15.sp, color: Colors.grey),
            ),
            TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.all(3.r)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(group,
                  style: TextStyle(
                      color: group == 'グループを選択' ? Colors.grey : Colors.white,
                      fontSize: group == 'グループを選択' ? 30.sp : 50.sp)),
              onPressed: () async {
                _focusNode1.unfocus();
                _focusNode2.unfocus();

                List<JoinGroupsModel> joinGroups = ref.read(joinGroupsProvider);
                var result = await showModalBottomSheet<int>(
                    context: context,
                    builder: (BuildContext context) {
                      return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List<Widget>.generate(joinGroups.length,
                              (int index) {
                            return SizedBox(
                              height: 40.h,
                              child: ListTile(
                                  leading: Icon(Icons.music_note, size: 25.sp),
                                  title: Text(
                                    joinGroups[index].name,
                                    style: TextStyle(fontSize: 25.sp),
                                  ),
                                  onTap: () {
                                    groupID = joinGroups[index].id;
                                    groupPhotoURL = joinGroups[index].photoURL;

                                    setState(() {
                                      group = joinGroups[index].name;
                                    });
                                    _focusNode1.unfocus();
                                    _focusNode2.unfocus();
                                    Navigator.pop(context);
                                  }),
                            );
                          }));
                    });
              },
            ),
            Spacer(flex: 2),

            EnterButton(
              title: '決定',
              enter: () {
                addTodo();
                Navigator.pop(context);
              },
            ),
            Spacer(flex: 3),
            // ElevatedButton(
            //     onPressed: () async {
            //       ref.read(authViewModelProvider.notifier).signOut();
            //       final database = await openDatabase('JoinGroupsModels.db');
            //
            //       await database
            //           .delete('JoinGroupsModels'); // ここでテーブルからすべてのデータを削除します
            //
            //       await database.close();
            //     },
            //     child: Text('fa')),
          ]),
        ));
  }
}
