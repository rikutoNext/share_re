import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_update_replace/constant/color.dart';
import 'package:share_update_replace/model/chat_model.dart';
import 'package:share_update_replace/model/joinGroupsModel.dart';
import 'package:share_update_replace/model/join_users_model.dart';
import 'package:share_update_replace/model/todo_model.dart';
import 'package:share_update_replace/view_model/chats_view_model.dart';
import 'package:share_update_replace/view_model/join_users_view_model.dart';

import '../view_model/auth_view_model.dart';
import '../view_model/todo_view_model.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/text_field.dart';

class Group extends ConsumerStatefulWidget {
  final JoinGroupsModel model;

  const Group({Key? key, required this.model}) : super(key: key);

  @override
  ConsumerState<Group> createState() => _GroupState();
}

class _GroupState extends ConsumerState<Group> {
  final TextEditingController _textController = TextEditingController();
  String message = '';

  @override
  Widget build(BuildContext context) {
    JoinGroupsModel model = widget.model;
    String id = model.id;
    String name = model.name;
    List<ToDoModel> todo =
        ref.read(todoProvider.notifier).groupTodo(id, true);
    ref.watch(todoProvider);
    List<ChatModel> chat = ref.watch(chatProvider);
    List<JoinUsersModel> users = ref.watch(joinUsersProvider);
    List<dynamic> mergedList = [...todo, ...chat];
    mergedList.sort((a, b) => a.createTime.compareTo(b.createTime));

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
          centerTitle: true,
          // タイトルの表示位置
          title: Text(
            name,
            style: TextStyle(fontSize: 15.sp),
          ),
          actions: [
            name != '私だけのTODO'
                ? IconButton(
                    iconSize: 15.sp,
                    onPressed: () async {
                      // launchUrl(
                      //   Uri.parse('https://shareriri.page.link/c8Ci'),
                      // );

                      final dynamicLinkParams = DynamicLinkParameters(
                        link: Uri.parse(
                            'https://www.google.com/?id=$id&name=$name&photoURL=${model.photoURL}&creator=${model.creator}&invitedName=${ref.read(authViewModelProvider)!.displayName!}'),
                        uriPrefix: "https://sharetodoriri.page.link/",
                        androidParameters: const AndroidParameters(
                            packageName: "com.example.share_update_replace"),
                        socialMetaTagParameters: const SocialMetaTagParameters(
                            title: "招待リンク",
                            description: 'このリンクは招待する人以外に公開しないでください。'),
                      );
                      final dynamicLink = await FirebaseDynamicLinks.instance
                          .buildShortLink(dynamicLinkParams);
                      Share.share(dynamicLink.shortUrl.toString());
                    },
                    icon: const Icon(Icons.share))
                : const SizedBox(),

            // IconButton(
            //     icon: const Icon(Icons.edit),
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (context) =>  GroupEdit(model: model)),
            //       );
            //     }),
            // SizedBox(
            //   width: 20.w,
            // )
          ],
        ),
        drawer: CustomDrawer(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 5.h,
              ),
              SizedBox(
                height: 480.h,
                child: ListView.builder(
                  itemCount: mergedList.length,
                  itemBuilder: (BuildContext context, int index) {
                    var info = mergedList[index];

                    String id = ref.read(authViewModelProvider)!.uid;
                    JoinUsersModel? user = users
                        .firstWhere((element) => element.uid == info.creator);

                    if (info is ChatModel) {
                      return Column(
                        children: [
                          info.creator == id
                              ? BubbleNormal(
                                  text: info.title,
                                  isSender: true,
                                  color: info.creator == id
                                      ? Colors.white54
                                      : Colors.lightBlue,
                                  tail: true,
                                  textStyle:  TextStyle(
                                    fontSize: 20.sp,
                                    color: Colors.black,
                                  ),
                                )
                              : Row(
                             crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      children: [
                                        SizedBox(
                                          height:18.h,
                                            width:18.w,
                                            child: myPhoto(
                                                user.photoURL , user.uid)),
                                        Text(user.name,style: TextStyle(color: Colors.white,))
                                      ],
                                    ),
                                    BubbleNormal(
                                  text: info.title,
                                      isSender: info.creator == id,
                                      color: info.creator == id
                                          ? Colors.white54
                                          : Colors.lightBlue,
                                      tail: true,
                                      textStyle:  TextStyle(
                                        fontSize: 20.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                          SizedBox(
                            height: 10.h,
                          )
                        ],
                      );
                    } else {
                      DateTime? deadLineDead = info?.deadLine;
                      String deadLine = deadLineDead == null
                          ? '未設定'
                          : '${deadLineDead.year}年${deadLineDead.month}月${deadLineDead.day}日';

                      return Row(
                        children: [
                          if (info.creator == id) const Spacer(),
                          Container(
                              margin: EdgeInsets.only(bottom: 20.h),
                              height: 120.h,
                              width: 300.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: info.creator == id
                                    ? Colors.white54
                                    : Colors.lightBlue,
                                border: Border.all(color: Colors.white),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    info.creator == id
                                        ? 'あなたがTODOを登録しました。'
                                        : '${'${info.creator}'.substring(0, 3)}さんがTODOを登録しました。',
                                    style: TextStyle(fontSize: 15.sp),
                                  ),
                                  Divider(
                                    color: info.creator == id
                                        ? Colors.white
                                        : Colors.grey,
                                    thickness: 1.w,
                                  ),
                                  Text(
                                    info.title,
                                    style: TextStyle(fontSize: 30.sp),
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    '締め切り:${deadLine ?? '未設定'}',
                                    style: TextStyle(
                                        fontSize: 15.sp, color: Colors.black54),
                                    textAlign: TextAlign.left,
                                  ),
                                  Text(
                                    '詳細:${info?.detail ?? '未設定'}',
                                    style: TextStyle(
                                        fontSize: 15.sp, color: Colors.black38),
                                    textAlign: TextAlign.left,
                                  )
                                ],
                              )),
                          if (info.creator != id) const Spacer(),
                        ],
                      );
                    }
                  },
                ),
              ),
              Row(children: [
                const Spacer(),
                Row(
                  children: [
                    SizedBox(
                      height: 50.h,
                      width: 330.w,
                      child: MyTextField(
                        max: 2,
                        controller: _textController,
                        onChanged: (value) {
                          message = value;
                        },
                        hintText: '誰か手伝ってください',
                      ),
                    ),
                    Center(
                        child: SizedBox(
                      width: 30.w,
                      height: 30.h,
                      child: Ink(
                        decoration: const ShapeDecoration(
                          color: Colors.blue,
                          shape: CircleBorder(),
                        ),
                        child: IconButton(
                          iconSize:20.sp,
                          icon: const Icon(Icons.send),
                          color: Colors.white,
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _textController.clear();

                            ref.read(chatProvider.notifier).addChat(
                                  doc: id,
                                  title: message,
                                );
                            message = '';
                          },
                        ),
                      ),
                    )),
                  ],
                )
              ]),
            ],
          ),
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
            return ClipOval(
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: snapshot.data.toString(),
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

  usersPhoto(String photoURL, String uid) {
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
            return ClipOval(
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: snapshot.data.toString(),
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
