import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_update_replace/constant/color.dart';
import 'package:share_update_replace/constant/navigator.dart';
import 'package:share_update_replace/model/joinGroupsModel.dart';
import 'package:share_update_replace/model/todo_model.dart';
import 'package:share_update_replace/view_model/auth_view_model.dart';

import '../view_model/join_groups_view_model.dart';
import '../view_model/todo_view_model.dart';
import '../widgets/custom_drawer.dart';
import 'create_group.dart';
import 'todo_add_view.dart';

StateProvider<int> drawerIndexProvider = StateProvider((ref) => 0);
StateProvider<String> upChoiceProvider = StateProvider((ref) => '');
StateProvider<bool> completedProvider = StateProvider((ref) => false);

class Top extends StatelessWidget {
  Top({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: OftenColors.backGroundColor,
        appBar: AppBar(
          toolbarHeight: 40.h,
          leading: Builder(
            builder: (context) => IconButton(
                icon: Icon(Icons.menu, size: 20.w),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                }),
          ),
          title: Text(
            'Share',
            style: TextStyle(fontSize: 20.sp),
          ), // タイトル名
          centerTitle: true, // タイトルの表示位置
        ),
        drawer: CustomDrawer(),
        body: Center(
          child: ListView(
            children: [
              SizedBox(
                height: 70.h,
                child: Consumer(builder: (BuildContext context, ref, _) {

                  List<JoinGroupsModel> joinGroups =
                      ref.watch(joinGroupsProvider);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 330.w,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: joinGroups.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return groupChoiceContainer('すべて', '', ref);
                              } else {
                                final join = joinGroups[index - 1];
                                return groupChoiceContainer(
                                    join.name, join.id, ref);
                              }
                            },
                          )),
                      SizedBox(
                        width: 30.w,
                        child: IconButton(
                            icon: Icon(
                              Icons.add_box,
                              color: Colors.white,
                              size: 20.r,
                            ),
                            onPressed: () {
                              navigateToNextPage(context, ref, CreateGroup());
                            }),
                      ),
                    ],
                  );
                }),
              ),
              SizedBox(
                height: 5.h,
              ),
              Consumer(
                builder: (context, ref, _) {
                  bool completed = ref.watch(completedProvider);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 40.h,
                        width: completed ? 60.w : 260.w,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(completedProvider.notifier).state =
                                !completed;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.red.withOpacity(completed ? 0.4 : 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.r),
                                bottomLeft: Radius.circular(10.0.r),
                                topRight: Radius.zero,
                                bottomRight: Radius.zero,
                              ),
                            ),
                          ),
                          child: Text(
                            '未完了',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: completed ? 10.sp : 15.sp),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40.h,
                        width: completed ? 260.w : 60.w,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(completedProvider.notifier).state =
                                !completed;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent
                                .withOpacity(completed ? 1 : 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10.r),
                                bottomRight: Radius.circular(10.r),
                                topLeft: Radius.zero,
                                bottomLeft: Radius.zero,
                              ),
                            ),
                          ),
                          child: Text(
                            '完了済み',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: completed ? 15.sp : 10.sp),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(
                height: 5.h,
              ),
              Consumer(builder: (context, ref, _) {
                List todo = ref.watch(todoProvider);
                String groupId = ref.watch(upChoiceProvider);
                bool completed = ref.watch(completedProvider);
                if (groupId != '') {
                  todo =
                      ref.read(todoProvider.notifier).groupTodo(groupId, false);
                }

                return SizedBox(
                  width: 500.h,
                  child: ListView.builder(
                    shrinkWrap: true, //追加
                    physics: const NeverScrollableScrollPhysics(), //
                    itemBuilder: (context, index) {
                      ToDoModel ob = todo[index];
                      return ob.completed == completed
                          ? Center(
                              child: Padding(
                                  padding: EdgeInsets.all(10.r),
                                  child: Dismissible(
                                    key: Key(ob.doc!),
                                    direction: ob.completed
                                        ? DismissDirection.endToStart
                                        : DismissDirection.startToEnd,
                                    onDismissed: (DismissDirection direction) {
                                      ref
                                          .read(todoProvider.notifier)
                                          .changeCompleted(ob);
                                    },
                                    background: Container(
                                      color: Colors.red,
                                    ),
                                    child: SizedBox(
                                      height: 80.h,
                                      width: 300.w,
                                      child: ListTile(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (_) {
                                                return AlertDialog(
                                                  title: const Text("情報"),
                                                  content: SizedBox(
                                                    height: 120.h,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text('タイトル:${ob.doc}'),
                                                        ob.detail != ''
                                                            ? Text(
                                                                '詳細　:${ob.detail}')
                                                            : const SizedBox
                                                                .shrink(),
                                                        ob.deadLine != null
                                                            ? Text(
                                                                '期限　:${ob.deadLine}')
                                                            : const SizedBox
                                                                .shrink(),
                                                        Text(
                                                            '作成日時:${ob.createTime}'),
                                                        Text(
                                                            '作成者:${ob.creator}'),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                        child: const Text("OK"),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        }),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                          ),
                                          title: Center(
                                            child: Row(
                                              children: [
                                                Text(
                                                  ob.title,
                                                  style: TextStyle(
                                                      fontSize: 30.sp),
                                                ),
                                                Spacer(),
                                                SizedBox(
                                                    height: 50.h,
                                                    child: photo(ob))
                                              ],
                                            ),
                                          ),
                                          enabled: true,
                                          tileColor: ob.deadLine == null ||
                                                  DateTime.now()
                                                      .isBefore(ob.deadLine!)
                                              ? Colors.white
                                              : Colors.pinkAccent.shade100),
                                    ),
                                  )),
                            )
                          : SizedBox();
                    },
                    itemCount: todo.length,
                  ),
                );
              }),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          height: 50.h,
          width: 200.w,
          child: FloatingActionButton.extended(
              label: Text(
                'TODOを追加',
                style: TextStyle(color: Colors.white, fontSize: 20.sp),
              ),
              icon: Icon(
                Icons.add,
                color: Colors.white,
                size: 20.sp,
              ),
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddView()),
                  )),
        ));
  }

  InkWell groupChoiceContainer(String title, String id, WidgetRef ref) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        ref.read(upChoiceProvider.notifier).state = id;
      },
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: ref.read(upChoiceProvider) == id ? 7.h : 15.h),
        width: ref.watch(upChoiceProvider) == id ? 100.w : 80.w,
        decoration: BoxDecoration(
          color:
              ref.read(upChoiceProvider) == id ? Colors.blueGrey : Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
            child: Text(
          title,
          style: TextStyle(
              fontSize: ref.read(upChoiceProvider) == id ? 15.sp : 10.sp),
        )),
      ),
    );
  }

  void showPopup(BuildContext context, WidgetRef ref) {
    final button = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      button.localToGlobal(Offset.zero, ancestor: overlay) & button.size,
      overlay.localToGlobal(Offset.zero) & overlay.size,
    ).shift(
      Offset(overlay.size.width, 10.h),
    );

    showMenu<String>(
      color: Colors.black12,
      context: context,
      position: position,
      items: [
        const PopupMenuItem<String>(
          value: 'option1',
          child: Text('期限順', style: TextStyle(color: Colors.white)),
        ),
        const PopupMenuItem<String>(
          value: 'option2',
          child: Text('作成日順', style: TextStyle(color: Colors.white)),
        ),
      ],
      elevation: 8,
    ).then((selectedValue) {
      var todo = ref.read(todoProvider.notifier);
      if (selectedValue == 'option1' && !todo.deadLineOrder) {
        todo.sortDeadLine(null, true);
        todo.deadLineOrder = true;
      } else if (selectedValue == 'option2' && todo.deadLineOrder) {
        todo.sortCreateTime(null, true);
        todo.deadLineOrder = false;
      }
    });
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

  photo(ob) {
    return ob.groupPhotoURL.substring(
                ob.groupPhotoURL.length - 3, ob.groupPhotoURL.length) ==
            'png'
        ? SizedBox(
            height: 75.h,
            width: 75.w,
            child: Image.asset(
              'images/${ob.groupPhotoURL}',
              fit: BoxFit.fill,
            ))
        : SizedBox(
            height: 50.h,
            width: 50.w,
            child: FutureBuilder<String>(
              future: _getFutureValue(ob.groupPhotoURL),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Image.asset('images/default_group.png');
                }
                if (snapshot.hasData) {
                  print('fijad');
                  print(snapshot.data.toString());
                  return ClipOval(
                    child: CachedNetworkImage(
                      fit: BoxFit.contain,
                      imageUrl: snapshot.data.toString(),
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                } else {
                  return Text("データが存在しません");
                }
              },
            ),
          );
  }
}
