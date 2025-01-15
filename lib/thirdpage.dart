import 'package:flutter/material.dart';

class thirdpage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title : Text("ページ(3)")
      ),
      body : Center(
        child: TextButton(
          child: Text("2ページに戻る"),
          // （1） 前の画面に戻る
          onPressed: (){
            Navigator.popUntil(context,(route) => route.isFirst);
          },
        ),
      )
    );
  }
}