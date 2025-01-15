import 'package:flutter/material.dart';
import 'package:flutter_application_1/thirdpage.dart';

class Secondpage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title : Text("ページ(2)")
      ),
      body : Center(
        child: TextButton(
          child: Text("3ページへ"),
          // （1） 前の画面に戻る
          onPressed: (){
                      // （1） 指定した画面に遷移する
            Navigator.push(context, MaterialPageRoute(
              // （2） 実際に表示するページ(ウィジェット)を指定する
              builder: (context) => thirdpage()
            ));
          },
        ),
      )
    );
  }
}