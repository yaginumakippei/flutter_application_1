import 'package:flutter/material.dart';
import 'package:flutter_application_1/secondpage.dart';

class KippeifirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ページ(1)"),
      ),
      body: Center(
        child: TextButton(
          child: Text("最初のページに戻る"),
          onPressed: () {
            // 現在のページをポップして前のページに戻る
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.orange, // 背景色をオレンジに設定
    );
  }
}
