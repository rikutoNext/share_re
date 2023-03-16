import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_update_replace/view_model/auth_view_model.dart';
import 'package:share_update_replace/widgets/text_field.dart';

import '../widgets/horizontal_image_picker.dart';
import 'top.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  int selectedIndex = 0;
  final ImagePicker _picker = ImagePicker();
  File? file;
  String name = '';

  @override
  Widget build(BuildContext context) {
    List<String> images = [
      'default.png',
      'father.png',
      'mother.png',
      'boy.png',
      'girl.png'
    ];

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('プロフィール登録', style: TextStyle(fontSize: 15.sp)),
          toolbarHeight: 40.h,
        ),
        backgroundColor: const Color.fromRGBO(53, 56, 63, 0.7),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('あともう一息です！',
                style: TextStyle(color: Colors.white, fontSize: 40.sp)),
            SizedBox(
              height: 180.0,
              // child: Scrollbar(
              //   controller: scrollController,
              //   interactive: true,
              //   child: ListView.builder(
              //     controller: scrollController,
              //     scrollDirection: Axis.horizontal,
              //     itemCount: images.length,
              //     itemBuilder: (BuildContext context, int index) {
              //       return GestureDetector(
              //         onTap: () {
              //           setState(() {
              //             selectedIndex = index;
              //           });
              //         },
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             SizedBox(
              //               width: index == 0 ? 150.w : 100.w,
              //             ),
              //             Stack(
              //               children: [
              //                 Container(
              //                   height: 150.h,
              //                   width: 150.w,
              //                   decoration: BoxDecoration(
              //                     shape: BoxShape.circle,
              //                     border: Border.all(
              //                       color: index == selectedIndex
              //                           ? Colors.blue
              //                           : Colors.grey,
              //                       width: 5.0.w,
              //                     ),
              //                   ),
              //                   child: index == 0 && _file != null
              //                       ? ClipOval(
              //                           child: Image.file(
              //                             _file!,
              //                             fit: BoxFit.cover,
              //                           ),
              //                         )
              //                       : Image(
              //                           image: AssetImage(images[index]),
              //                           fit: BoxFit.cover,
              //                         ),
              //                 ),
              //                 index == 0
              //                     ? Positioned(
              //                         bottom: 0,
              //                         right: 0,
              //                         child: IconButton(
              //                           onPressed: () async {
              //                             final XFile? _image =
              //                                 await _picker.pickImage(
              //                                     source:
              //                                         ImageSource.gallery);
              //                             _file = File(_image!.path);
              //                             setState(() {});
              //                           },
              //                           icon: Icon(
              //                             Icons.camera_alt,
              //                             color: Colors.black,
              //                             size: 50.0.w,
              //                           ),
              //                         ),
              //                       )
              //                     : Container(),
              //               ],
              //             ),
              //             index == 4
              //                 ? SizedBox(
              //                     width: 150.w,
              //                   )
              //                 : Container()
              //           ],
              //         ),
              //       );
              //     },
              //   ),
              // )

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
              height: 100.h,
              width: 400.w,
              child: MyTextField(
                  onChanged: (value) {
                    name = value;
                  },
                  hintText: 'ニックネーム'),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
                onPressed: () async {
                  if (name == '') {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) {
                        return AlertDialog(
                          title: Text("ニックネームが未入力です。"),
                          content: Text("This is the content"),
                          actions: [
                            ElevatedButton(
                              child: Text("Cancel"),
                              onPressed: () => Navigator.pop(context),
                            ),
                            ElevatedButton(
                              child: Text("OK"),
                              onPressed: () => print('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else if (file == null || selectedIndex != 0) {
                    await ref
                        .read(authViewModelProvider.notifier)
                        .nameAndImage(name, images[selectedIndex], null);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Top()));
                    });
                  } else {
                    await ref
                        .read(authViewModelProvider.notifier)
                        .nameAndImage(name, null, file);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Top()));
                    });
                  }
                },
                child: Text('登録完了！'))
          ],
        ));
  }
}
