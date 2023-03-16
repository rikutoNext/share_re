import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_update_replace/view/auth/confirm_email.dart';
import 'package:share_update_replace/view/profile_view.dart';
import 'package:share_update_replace/view/auth/registration_view.dart';
import 'package:share_update_replace/view/top.dart';
import 'package:share_update_replace/view_model/auth_view_model.dart';
import 'package:share_update_replace/view_model/join_groups_view_model.dart';
import 'package:share_update_replace/view_model/todo_view_model.dart';

import 'view/join_confirmation.dart';

//https://sharetodoriri.page.link/rM3L
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Get any initial links

  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();

  runApp(ProviderScope(child: MyApp(para: initialLink?.link.queryParameters)));
}

Future<void> writeDataToFirestore(WidgetRef ref) async {
  // ログインしているユーザーを取得
  User? user = FirebaseAuth.instance.currentUser;

  // ログインしいる場合は、処理を終了
  if (user == null) {
    User? myInformation =
        await ref.read(authViewModelProvider.notifier).signInAnonymously();
    await ref.read(joinGroupsProvider.notifier).createGroupsModel(
        myInformation!,
        '私だけのTODO',
        'このTODOはあなただけが見ることができます。',
        'default_group.png',
        null);
    String uid = ref.read(authViewModelProvider)!.uid;
  }
  await ref.read(authViewModelProvider.notifier).readProfile();

  await ref.read(joinGroupsProvider.notifier).joinGroupConfirmation();
  await ref.read(todoProvider.notifier).readTodo();
}

class MyApp extends ConsumerStatefulWidget {
  final Map? para;

  const MyApp({Key? key, required this.para}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    writeDataToFirestore(ref);
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {

      User? auth = ref.read(authViewModelProvider);
      if (auth!.emailVerified && auth.displayName != null) {
        _navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) =>
                JoinConfirmation(data: dynamicLinkData.link.queryParameters)));
      }

     else if (auth.emailVerified) {
        _navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) =>
               const Profile()));
      }


    else if(!auth.emailVerified&&auth.email!=null){
    auth.sendEmailVerification();
    _navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) =>
            const ConfirmEmail()));

    }
    else{
        _navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) =>
            const RegistrationView()));

      }
    }).onError((error) {

      // Handle errors
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.resumed:
        // WidgetsBinding.instance.addPostFrameCallback((_) {

        // });
        break;
      case AppLifecycleState.detached:
        break;
    }
    if (state == AppLifecycleState.resumed) {
      // FlutterAppBadger.removeBadge();
    }
  }

  @override
  Widget build(BuildContext context) {

    return ScreenUtilInit(
      designSize: const Size(360, 640),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'First Method',
          darkTheme: ThemeData.dark(),
          theme: ThemeData(
            appBarTheme: const AppBarTheme(

              titleTextStyle: TextStyle(color: Colors.white),
              backgroundColor: Colors.black,
              iconTheme: IconThemeData(
                color: Colors.white, // 戻るボタンの色を変更
              ),
            ),
            primarySwatch: Colors.cyan,
          ),
          home: widget.para == null
              ? Top()
              : JoinConfirmation(
                  data: widget.para! as Map<String, String>,
                ),
        );
      },
    );
  }
}
