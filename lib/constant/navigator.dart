import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_update_replace/view/auth/confirm_email.dart';
import 'package:share_update_replace/view/auth/registration_view.dart';
import 'package:share_update_replace/view/profile_view.dart';
import 'package:share_update_replace/view_model/auth_view_model.dart';

void navigateToNextPage(BuildContext context, WidgetRef ref, Widget? route) {
  User? auth = ref.read(authViewModelProvider);

  if (auth!.email != null && auth!.emailVerified && auth.displayName != null) {
    route != null
        ? Navigator.push(
            context, MaterialPageRoute(builder: (context) => route))
        : null;
  } else if (auth.emailVerified) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Profile()));
  } else if (!auth.emailVerified && auth.email != null) {
    auth.sendEmailVerification();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ConfirmEmail()));
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color.fromRGBO(98, 129, 224, 1.0),
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // 画像をタップしたときの処理
                  },
                  child: Image.asset(
                    'images/pop_up.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(30.r),
                height: 120.h,
                width: double.infinity,
                color: Color.fromRGBO(98, 129, 224, 1.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegistrationView()));
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 20,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(200),
                    ),
                  ),
                  child: Text(
                    '登録する',
                    style: TextStyle(color: Colors.white, fontSize: 25.sp),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
