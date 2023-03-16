import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_update_replace/constant/color.dart';
import 'package:share_update_replace/model/joinGroupsModel.dart';
import 'package:share_update_replace/view/group.dart';
import 'package:share_update_replace/view/top.dart';
import 'package:share_update_replace/view_model/auth_view_model.dart';
import 'package:share_update_replace/view_model/chats_view_model.dart';
import 'package:share_update_replace/view_model/join_groups_view_model.dart';
import 'package:share_update_replace/view_model/join_users_view_model.dart';
import 'package:share_update_replace/view_model/todo_view_model.dart';

class JoinConfirmation extends ConsumerWidget {
  final Map<String, dynamic> data;

  const JoinConfirmation({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    JoinGroupsModel model = JoinGroupsModel.fromJson(data);
    return Scaffold(
        backgroundColor: OftenColors.backGroundColor,
        appBar: AppBar(title: const Text('グループへ参加の確認')),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              '${data['invitedName']}さんから\nグループへ招待されています。',
              style: TextStyle(color: Colors.grey, fontSize: 25.sp),
              textAlign: TextAlign.center,
            ),
            Container(
              width: 120.0,
              height: 120.0,
              margin: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage("images/${model.photoURL}")),
              ),
            ),
            Text(model.name,
                style: TextStyle(color: Colors.grey, fontSize: 60.sp)),
            SizedBox(
              height: 10.h,
            ),
            ElevatedButton(onPressed: () async {
              List<JoinGroupsModel> models=ref.read(joinGroupsProvider);
              int index = models.indexWhere((searchModel) => searchModel.id==model.id );
              if (index!=-1 ) {

                ref
                    .read(drawerIndexProvider.notifier)
                    .state = index+1;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('既にこのグループに参加しています。'),
                  ),
                );
              } else {
                ref
                    .read(drawerIndexProvider.notifier)
                    .state = models.length+2;

                await ref
                    .read(joinGroupsProvider.notifier)
                    .joinGroupsModel(model, ref.read(authViewModelProvider)!);
                ref
                    .read(chatProvider.notifier)
                    .readTodo(model.id);
                ref
                    .read(joinUsersProvider.notifier)
                    .readUsers(model.id);
                ref.read(todoProvider.notifier).readTodo();

              }

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Group(
                      model: model,
                    )),
              );

            }, child: const Text('参加する')),
            ElevatedButton(
              onPressed: () async {
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                '辞退する',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ]),
        ));
  }
}
