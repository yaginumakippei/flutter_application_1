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
        color: Colors.green, // 背景色を緑に変更
        child: Center(
          child: SizedBox(
            width: 250, // ボタンの横幅
            height: 60,  // ボタンの高さ
            child: TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(color: Colors.white, width: 2), // 枠線の色と太さ
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: Colors.green, // ボタン背景色（背景と合わせる場合）
              ),
              child: Text(
                "クイズに進む",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white, // ボタン文字色を白に変更
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KippeifirstPage()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
