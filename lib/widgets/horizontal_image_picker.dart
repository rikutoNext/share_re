import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyImageSelector extends StatelessWidget {
  final String? photoURL;
  final List<String> images;
  final int selectedIndex;
  final File? file;
  final Function tappedProcess;
  final Function iconPressed;

  const MyImageSelector({
    this.photoURL,
    required this.images,
    required this.selectedIndex,
    required this.file,
    required this.tappedProcess,
    required this.iconPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return Scrollbar(
      controller: scrollController,
      interactive: true,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              tappedProcess(index);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                        height: 80.h,
                        width: 80.w,
                        margin: EdgeInsets.symmetric(horizontal: 20.r),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: index == selectedIndex
                                ? Colors.blue
                                : Colors.grey,
                            width: 4.w,
                          ),
                        ),
                        child: index == 0 && file != null
                            ? ClipOval(
                                child: Image.file(
                                  file!,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : photoURL != null && index == 0
                                ? CircleAvatar(
                                    radius: 80.r,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.fill,
                                      imageUrl: photoURL!,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  )
                                : Image(

                                    image:
                                        AssetImage('images/${images[index]}'),
                                    fit: BoxFit.contain,
                                  )),
                    index == 0
                        ? Positioned(
                            bottom: -15.h,
                            right: 0,
                            child: IconButton(
                              onPressed: () async {
                                iconPressed();
                              },
                              iconSize: 50.0.w,
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
                index == 4
                    ? SizedBox(
                        width: 150.w,
                      )
                    : Container()
              ],
            ),
          );
        },
      ),
    );
  }
}
