import 'package:flutter/material.dart';

class Help extends StatefulWidget {
  const Help({Key? key}) : super(key: key);

  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {
  int selectedPanel = -1;
  List<List<String>> qnaList = [
    ["스터디오가 무슨 뜻인가요?", "오답을 공부한다는 뜻입니다."],
    ["사진은 어떻게 삭제하나요?", "과목 페이지의 오른쪽 위 메뉴에서 선택 삭제하는 수밖에 없습니다."],
    ["사진을 복구할 수는 없나요?", "사진 복구는 불가능하며, 과목 삭제를 하시기 바랍니다."],
    ["홈 화면에서 과목 순서는 어떻게 바꾸나요?", "길게 누른 뒤, 원하는 곳에 드랍하시면 됩니다."],
    ["하이라이트는 어떻게 새로고침하나요?", "홈 화면을 아래로 당기면 됩니다."],
    ["갤러리의 사진을 지워도 괜찮나요?", "저장 공간이 분리되어 있기 때문에, 원본 사진을 삭제하셔도 괜찮습니다."],
    // ["사진을 복구할 수는 없나요?", "사진 복구는 불가능하며, 과목 삭제를 하시기 바랍니다."],
    // ["사진을 복구할 수는 없나요?", "사진 복구는 불가능하며, 과목 삭제를 하시기 바랍니다."],
    // ["사진을 복구할 수는 없나요?", "사진 복구는 불가능하며, 과목 삭제를 하시기 바랍니다."],
  ];

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
            '도움말',
            style: TextStyle(color: Colors.black54, fontSize: 20),
          ),
          centerTitle: true,
        ),
      ),
      body: ListView(
        children: [
          Container(height: 30, color: Colors.grey[200]),
          ExpansionPanelList(
            children: [
              for (List<String> qna in qnaList)
                ExpansionPanel(
                    headerBuilder: (context, aa) {
                      print(aa);
                      return Container(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          qna[0],
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87.withOpacity(0.75)),
                        ),
                        alignment: Alignment.centerLeft,
                      );
                    },
                    body: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        qna[1],
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87.withOpacity(0.75)),
                      ),
                      padding: EdgeInsets.only(left: 20, bottom: 20, right: 20),
                    ),
                    isExpanded:
                        selectedPanel == qnaList.indexOf(qna) ? true : false,
                    canTapOnHeader: true),
            ],
            expansionCallback: (id, isOpen) {
              setState(() {
                if (isOpen) {
                  selectedPanel = -1;
                  print("$id, $isOpen");
                } else {
                  selectedPanel = id;
                  print("$id, $isOpen");
                }
              });
            },
            elevation: 0,
          ),
        ],
      ),
    );
  }
}
