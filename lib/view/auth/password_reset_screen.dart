import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_update_replace/constant/color.dart';
import 'package:share_update_replace/view/auth/login_view.dart';
import 'package:share_update_replace/view_model/auth_view_model.dart';
import 'package:share_update_replace/widgets/text_field.dart';

import '../../widgets/alert_message_dialog.dart';
import '../../widgets/enter_button.dart';

class PasswordResetScreen extends ConsumerWidget {
  const PasswordResetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String email = '';
    return Scaffold(
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
              'パスワードの再設定',
              style: TextStyle(fontSize: 15.sp),
            )),
        backgroundColor: OftenColors.backGroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'あなたのメールアドレス宛てに\nパスワード再設定用リンクを送信します。',
                style: TextStyle(color: Colors.white, fontSize: 15.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20.h,
              ),
              MyTextField(
                  onChanged: (value) {
                    email = value;
                  },
                  hintText: 'abc@example.com'),
              SizedBox(
                height: 30.h,
              ),
              SizedBox(
                height: 40.h,
                width: 100.w,
                child: EnterButton(
                  enter: () async {
                    if (email == '') {
                      AlertMessageDialog.show(
                          context, 'エラー', 'メールアドレスを入力してください。');
                    } else {
                      String error = await ref
                          .read(authViewModelProvider.notifier)
                          .sendPasswordResetEmail(email);
                      if (error == '成功') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginView()));
                      } else {
                        AlertMessageDialog.show(context, 'エラー', error);
                      }
                    }
                  },
                  title: '送信',
                ),
              )
            ],
          ),
        ));
  }
}
