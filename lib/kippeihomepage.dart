import 'package:flutter/material.dart';
import 'package:flutter_application_1/kippeifirstpage.dart';

class Kippeihomepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ホーム"),
      ),
      body: Container(
        color: Colors.green,  // 背景色を緑に変更
        child: Center(
          child: TextButton(
            style: TextButton.styleFrom(
    side: BorderSide(color: Colors.white, width: 2), // 枠線の色と太さ
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // 余白の調整（任意）
     ),
            child: Text(
              "1ページ目に遷移する",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,  // ボタン文字色を白に変更
              ),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => KippeifirstPage(),
              ));
            },
          ),
        ),
      ),
    );
  }
}
