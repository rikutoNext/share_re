import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlertMessageDialog {
  static void show(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(title,style: TextStyle(color: Colors.white,fontSize: 20.sp)),
          content: Text(message,style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              child: Text('OK',style: TextStyle(fontSize: 10.sp)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
