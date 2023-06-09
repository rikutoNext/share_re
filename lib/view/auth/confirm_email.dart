import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_update_replace/view/auth/change_email.dart';
import 'package:share_update_replace/view/profile_view.dart';
import 'package:share_update_replace/widgets/alert_message_dialog.dart';
import 'package:share_update_replace/widgets/enter_button.dart';

import '../../constant/color.dart';
import '../../view_model/auth_view_model.dart';

class ConfirmEmail extends ConsumerWidget {
  const ConfirmEmail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    User? user = ref.watch(authViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('メール認証確認', style: TextStyle(fontSize: 15.sp)),
        automaticallyImplyLeading: false,
        toolbarHeight: 40.h,
      ),
      backgroundColor: OftenColors.backGroundColor,
      body: Center(
        child: Column(
          children: [
            Text(
              '${user?.email}\nにメールを送信しました。\nリンクをクリックし、下記のボタンを押してください。',
              style: TextStyle(color: Colors.white, fontSize: 20.sp),
              textAlign: TextAlign.center,
            ),
            Spacer(),
            SizedBox(
              height: 70.h,
              width: 150.w,
              child: EnterButton(
                title: '認証完了',
                enter: () async {
                  bool emailVerified = await ref
                      .read(authViewModelProvider.notifier)
                      .isEmailVerified();
                  if (emailVerified) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('メールの認証が確認できました。'),
                    ));
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Profile()));
                  } else {
                    AlertMessageDialog.show(
                        context, 'メールアドレスの確認が取れませんでした。', '');
                  }
                },
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('メールの再送信。',style: TextStyle(fontSize: 10.sp),),
              onPressed: () async {
                await ref
                    .read(authViewModelProvider.notifier)
                    .sendEmailVerification();
              },
            ),
            TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('メールアドレスの変更',style: TextStyle(fontSize: 10.sp)),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangeEmail()));
              },
            ),
            Spacer(),
            Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('「メールが届かないという方は」.....',
                        style: TextStyle(color: Colors.red, fontSize: 20.sp)),

                    Text('〇迷惑メールフォルダに入っている可能性があります。ご確認ください。',

                        style: TextStyle(color: Colors.white, fontSize: 18.sp)),
                    SizedBox(height: 5.h,),
                    Text('〇メールアドレスが間違っている可能性があります。変更してください。',
                        style: TextStyle(color: Colors.white, fontSize: 18.sp)),
                    Text('\nそれでも届かない場合はしばらく待ってか再度お試しください。',
                        style: TextStyle(color: Colors.white, fontSize: 18.sp)),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
