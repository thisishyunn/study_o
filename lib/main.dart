import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_study_o_ver2/data/database.dart';
import 'package:flutter_project_study_o_ver2/screens/homepagebody.dart';
import 'package:flutter_project_study_o_ver2/screens/menu.dart';
import 'package:get/get.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    // systemNavigationBarColor: Colors.transparent, // navigation bar color
    statusBarColor: Color.fromRGBO(135, 206, 250, 1), // status bar color
  ));
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  runApp(Phoenix(child: StudyO()));
}

class StudyO extends StatelessWidget {
  const StudyO({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '스터디오',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future savedData;
  // RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    // TODO: implement initState
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    super.initState();
    
    savedData = ManageData().loadData();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageData>(
      init: ManageData(),
      builder: (md) {
        return Container(
          color: Color.fromRGBO(135, 206, 250, 1),
          child: SafeArea(
            child: Scaffold(
                primary: false,
                appBar: PreferredSize(
                    preferredSize: Size.fromHeight(50), child: myAppBar(md)),
                body: myBody(md)),
          ),
        );
      },
    );
  }

  AppBar myAppBar(ManageData _) {
    return AppBar(
        backgroundColor: Color.fromRGBO(135, 206, 250, 1),
        elevation: 2,
        title: Container(
            // margin: EdgeInsets.fromLTRB(0,10,0,5),
            width: 170,
            height: 50,
            color: Colors.transparent,
            child: Image.asset('images/logo.PNG')),
        actions:
            // 앨범 삭제 모드이면 '완료' 텍스트 버튼을 표시하고, 아니면 설정 아이콘을 표시한다
            _.settingMap['onDelete'] ?? false
                ? [
                    TextButton(
                        onPressed: () {
                          _.onSubjectDeleteEnd();
                        },
                        // style: ButtonStyle(foregroundColor: MaterialStateProperty()),
                        child: Text(
                          '완료',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ))
                  ]
                : [
                    // IconButton(
                    //     onPressed: () {},
                    //     icon: Icon(Icons.search)),
                    IconButton(
                        onPressed: () async {
                          var settingCall = await Get.to(() => MenuPage(),
                              transition: Transition.rightToLeft);
                          if (settingCall == 'deleteSubject') {
                            setState(() {});
                          }
                        },
                        icon: Icon(Icons.settings))
                  ]);
  }

  Widget myBody(ManageData md) {
    return FutureBuilder(
      future: savedData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
              key: Key(''),
              child: Column(
                children: [
                  Container(
                    height: Get.height - myAppBar(md).preferredSize.height-4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        // Padding(
                        //   padding: const EdgeInsets.all(20.0),
                        //   child: Text(
                        //     '데이터를 불러오고 있습니다...',
                        //     style:
                        //         TextStyle(color: Colors.black.withOpacity(0.6)),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ],
              ));
        }

        return HomePageBody(
          subjectMap: md.subjectMap,
          highlightMap: md.highlightMap,
          settingMap: md.settingMap,
        );
      },
    );
  }
}
