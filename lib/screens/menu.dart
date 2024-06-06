import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_study_o_ver2/data/database.dart';
import 'package:flutter_project_study_o_ver2/screens/feedback_page.dart' as fb;
import 'package:flutter_project_study_o_ver2/screens/help_page.dart';
import 'package:flutter_project_study_o_ver2/screens/highlight_manage_page.dart';
import 'package:flutter_project_study_o_ver2/screens/trashbin.dart';
import 'package:get/get.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Color.fromRGBO(135, 206, 250, 1)),
          title: Text(
            '설정',
            style: TextStyle(color: Colors.black54, fontSize: 20),
          ),
          centerTitle: true,
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 5.0),
          //     child: IconButton(
          //       iconSize: 24,
          //       color: Color.fromRGBO(135, 206, 250, 1),
          //       icon: Icon(Icons.help_outline_rounded),
          //       onPressed: () {},
          //     ),
          //   )
          // ],
          // bottom: PreferredSize(
          //   preferredSize: Size.fromHeight(0),
          //   child: Divider(),
          // ),
        ),
      ),
      body: Column(
        children: [
          Container(height: 30, color: Colors.grey[200]),
          ListTile(
            title: Text('앨범 삭제'),
            leading: Icon(Icons.backspace),
            trailing: Icon(Icons.arrow_forward_ios_outlined, size: 20,),
            enabled: ManageData().subjectMap.length != 0 ? true : false,
            onTap: () {
              ManageData().onSubjectDeleteStart();
              Get.back(result: 'deleteSubject');
            },
          ),

          Container(height: 0.6, color: Colors.grey.withOpacity(0.4),),
          ListTile(
            leading: Icon(Icons.delete),
            trailing: Icon(Icons.arrow_forward_ios_outlined, size: 20,),
            title: Text('휴지통'),
            onTap: () {
              Get.to(() => TrashBin(),
                  transition: Transition.rightToLeft);
            },
          ),
          Container(height: 0.6, color: Colors.grey.withOpacity(0.4),),
          ListTile(
            leading: Icon(Icons.edit),
            trailing: Icon(Icons.arrow_forward_ios_outlined, size: 20,),
            title: Text('하이라이트 편집'),
            onTap: () {
              Get.to(() => HighlightManage(),
                  transition: Transition.rightToLeft);
            },
          ),
          Container(height: 30, color: Colors.grey[200]),
          ListTile(
            leading: Icon(Icons.help_outline_rounded),
            trailing: Icon(Icons.arrow_forward_ios_outlined, size: 20,),
            title: Text('도움말'),
            onTap: () {
              Get.to(() => Help(), transition: Transition.rightToLeft);
            },
          ),
          Container(height: 0.6, color: Colors.grey.withOpacity(0.4),),
          ListTile(
            leading: Icon(Icons.message_rounded),
            trailing: Icon(Icons.arrow_forward_ios_outlined, size: 20,),
            title: Text('앱 리뷰 작성'),
            onTap: () {},
          ),
          Container(height: 0.6, color: Colors.grey.withOpacity(0.4),),
          ListTile(
            leading: Icon(Icons.info_outline),
            trailing: Icon(Icons.arrow_forward_ios_outlined, size: 20,),
            title: Text('프리미엄 (광고 제거)'),
            onTap: () {},
          ),
          Container(height: 0.6, color: Colors.grey.withOpacity(0.4),),
          ListTile(
            leading: Icon(Icons.email_outlined),
            trailing: Icon(Icons.arrow_forward_ios_outlined, size: 20,),
            title: Text('피드백 보내기'),
            onTap: () {
              Get.to(() => fb.Feedback(), transition: Transition.rightToLeft);
            },
          ),
          Flexible(
            child: Container(
              alignment: AlignmentDirectional.topStart,
              // height: 250,
              color: Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: Text("스터디오 ver 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12),),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
