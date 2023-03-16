import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_update_replace/constant/color.dart';
import 'package:share_update_replace/view/auth/password_reset_screen.dart';
import 'package:share_update_replace/view/auth/registration_view.dart';
import 'package:share_update_replace/view/top.dart';
import 'package:share_update_replace/view_model/auth_view_model.dart';
import 'package:share_update_replace/view_model/join_groups_view_model.dart';
import 'package:share_update_replace/view_model/todo_view_model.dart';
import 'package:share_update_replace/widgets/alert_message_dialog.dart';

import '../../widgets/enter_button.dart';
import '../../widgets/text_field.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  bool _isObscured = true;
  String? email;
  String? password;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: OftenColors.backGroundColor,
        appBar: AppBar(),
        body: SingleChildScrollView(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100.h,
              ),
              Text(
                'ログイン',
                style: TextStyle(color: Colors.white, fontSize: 40.sp),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegistrationView()));
                },
                child: const Text('まだ会員登録がお済みでない方はこちら(無料登録)'),
              ),
              SizedBox(
                height: 30.h,
              ),
              isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          const Text('メールアドレス',
                              style: TextStyle(color: Colors.white)),
                          SizedBox(
                              height: 55.h,
                              width: 400.w,
                              child: MyTextField(
                                  hintText: 'abc@example.com',
                                  onChanged: (value) {
                                    email = value;
                                  })),
                          SizedBox(
                            height: 30.h,
                          ),
                          const Text(
                            'パスワード',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                              width: 400.w,
                              child: TextFormField(
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                obscureText: _isObscured,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                          width: 0.1.w, color: Colors.white)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  suffixIcon: IconButton(
                                    icon: Icon(_isObscured
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        _isObscured = !_isObscured;
                                      });
                                    },
                                  ),
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'パスワードを入力してください';
                                  }

                                  // パスワードの長さが6文字以上でない場合はエラーを返す
                                  if (value.length < 6) {
                                    return 'パスワードは6文字以上';
                                  }
                                  password = value;
                                  return null;
                                },
                              )),
                        ]),
              SizedBox(
                height: 40.h,
              ),
              EnterButton(
                  title: 'ログイン',
                  enter: () async {
                    if (email == '' || password == null) {
                      AlertMessageDialog.show(
                          context, 'メールアドレスまたはパスワードが正しく入力されていません', '');
                    } else {
                      String error = await ref
                          .read(authViewModelProvider.notifier)
                          .signInWithEmailAndPassword(
                              email: email!, password: password!);
                      if (error == '成功') {
                        await ref.read(joinGroupsProvider.notifier).login();
                        await ref.read(todoProvider.notifier).readTodo();
                        await ref
                            .read(authViewModelProvider.notifier)
                            .readProfile();
                        if (!mounted) return;
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Top()));
                      } else {
                        if (!mounted) return;
                        AlertMessageDialog.show(context, error, '');
                      }
                    }
                  }),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PasswordResetScreen()));
                },
                child: const Text('パスワードを忘れた方はこちら'),
              ),
            ],
          ),
        )));
  }
}
