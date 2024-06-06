import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class Feedback extends StatefulWidget {
  const Feedback({Key? key}) : super(key: key);

  @override
  _FeedbackState createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedback> {
  TextEditingController _textEditingController = TextEditingController();

  sendSlackMessage(String message) async {

    String url =
        "https://hooks.slack.com/services/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";
    Map<String, String> requestHeader = {
      'Content-type': 'application/json',
    };

    var request = {
      'text': message,
    };
    try {
      var result = await http
          .post(Uri.parse(url),
          body: json.encode(request), headers: requestHeader)
          .then((response) {
        return response.body;
      });
    } catch(e) {
      print("에러");
      return "error";
    }
    return "ok";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.0,
            iconTheme: IconThemeData(color: Color.fromRGBO(135, 206, 250, 1)),
            title: Text(
              '피드백 보내기',
              style: TextStyle(color: Colors.black54, fontSize: 20),
            ),
            centerTitle: true,
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: Get.width * 0.9,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  child: TextField(
                    maxLines: null,
                    keyboardType: TextInputType.name,
                    controller: _textEditingController,
                    decoration: InputDecoration.collapsed(
                        hintText: "이 피드백은 개발자 메신저로 즉시 전송됩니다.",
                        hintStyle: TextStyle(
                            fontSize: 15,
                            color: Colors.black.withOpacity(0.4))),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  width: Get.width * 0.85,
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    child: Icon(Icons.email),
                    onPressed: () async {
                      SnackBar sendFeedbackSucess = SnackBar(
                        content: Text("피드백을 성공적으로 보냈어요"),
                      );
                      SnackBar sendFeedbackFail = SnackBar(
                        content: Text("피드백을 보내는 데 실패했어요"),
                      );
                      String result = await sendSlackMessage(_textEditingController.text);
                      print("$result ${result.length}");
                      if(result.length == 2) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(sendFeedbackSucess);
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(sendFeedbackFail);
                      }
                      Get.back();
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(135, 206, 250, 1))),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
