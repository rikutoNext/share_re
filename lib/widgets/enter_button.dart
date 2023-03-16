import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EnterButton extends StatelessWidget {
  final enter;
  final String title;

  const EnterButton({
    Key? key,
    required this.title,
    required this.enter,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {


    return SizedBox(
      height: 50.h,
      width: 150.w,
      child: ElevatedButton(
        onPressed: () {
          enter();
        },
        style: ElevatedButton.styleFrom(
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(color: Colors.white,fontSize: 25.sp),
        ),
      ),
    );
  }
}
