import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int randomColor = 0;
  String token = '';
  var onPress;
  var userInfo = {
    'tip':'CILCK ONCE at 14:40-15:06',
    'account':'Fangzao225215@163.com',//IM
    'password':'qwer1234.',//IM
    'TEL':'',
    'id':'4489359',
    "payment_account": 11249213,
    'dasher': '4369984',//IM
    'vehicle': '4419694',//IM
    "applicant_unique_link": "95TmcKkOCNgxKOnqz6OHSPVbMRbURm2VoPow2uQXT5aI4OqXEs",
    'start': '10:00:00',//IM
    'end': '23:00:00',
    'status':'CILCK ONCE at 14:40-15:06',
    'location':452,
    'startHour':14,
    'startMins':40,
    'endHour':15,
    'endMins':6,
    'FPS':2,
  };
  Timer timer;
  void loop(){

    timer = new Timer.periodic(Duration(seconds: userInfo['FPS']),(timer){
      var hour = new DateTime.now().hour;
      var minute = new DateTime.now().minute;
      var flag = (hour == userInfo['startHour'] && minute>userInfo['startMins'])||(hour == userInfo['endHour'] && minute<userInfo['endMins']);
      if(!flag ){
        timer.cancel();
        setState(() {
          userInfo['status'] = userInfo['tip'];
        });
        return ;
      }else{
        if(hour == userInfo['endHour'] && minute<userInfo['endMins']) {
          setState(() {
            userInfo['status'] = 'pedding...';
          });
          saveScheduleReq();
        }
      }
    });
  }

  void getToken() {
    try{
      timer.cancel();
    }catch(e){}

    setState(() {
      userInfo['status'] = 'START...';
    });
    HttpClient client = new HttpClient();
    client
        .postUrl(Uri.parse("https://api-dasher.doordash.com/v2/auth/token/"))
        .then((HttpClientRequest request) {
      request.headers.clear();
      request.headers.set('host', 'api-dasher.doordash.com');
      request.headers.set('transfer-encoding', 'chunked');
      request.headers.set('content-type', 'application/json');
      request.headers.set('connection', 'keep-alive');
      request.headers.set('client-version', 'ios v2.12.0 b124.190611');
      request.headers.set('accept', 'application/json');
      request.headers.set('user-agent',
          'DoordashDriver/124.190611 CFNetwork/974.2.1 Darwin/18.0.0');
      request.headers.set('cookies', '');
      request.write(json.encode({
        "email": userInfo['account'],
        "is_manual": 1,
        "password": userInfo['password']
      }));

      return request.close();
    }).then((HttpClientResponse response) {
      // Process the response.
      response.transform(utf8.decoder).listen((contents) {
        token = 'JWT ' + json.decode(contents)['token'];
        loop();
      });
    });
  }

  void saveScheduleReq(){
    HttpClient client = new HttpClient();
    client
        .postUrl(Uri.parse("https://api-dasher.doordash.com/v1/dashes/"))
        .then((HttpClientRequest request) {
      request.headers.clear();
      request.headers.set('Authorization', token);
      request.headers.set('host', 'api-dasher.doordash.com');
      request.headers.set('transfer-encoding', 'chunked');
      request.headers.set('content-type', 'application/json');
      request.headers.set('connection', 'keep-alive');
      request.headers.set('client-version', 'ios v2.12.0 b124.190611');
      request.headers.set('accept', 'application/json');
      request.headers.set('user-agent',
          'DoordashDriver/124.190611 CFNetwork/974.2.1 Darwin/18.0.0');
      request.headers.set('cookies', '');
      request.write(json.encode({
        "expand": "starting_point",
        "dasher": userInfo['dasher'],
        "scheduled_end_time": setDate(userInfo['end']),
        "is_impromptu_dash": false,
        "scheduled_start_time": setDate(userInfo['start']),
        "vehicle": '4539870',
        "starting_point": userInfo['location']
      }));

      return request.close();
    }).then((HttpClientResponse response) {
      // Process the response.
      response.transform(utf8.decoder).listen((contents) {
        var id = json.decode(contents)['id'];
        if(id !=null){
          setState(() {
            userInfo['status'] = 'SUCCESS';
            onPress = null;
          });
          timer.cancel();
        }
      });
    });

  }



  String setDate(str){
    var date = DateTime.now();
    var newDate = date.add(new Duration(days:6));
    var df = new DateFormat("yyyy-MM-dd'T'$str'-07:00'");
    //'2019-07-08T10:00:00-07:00'
    return df.format(newDate);

  }

  void handleTimeout(){

  }




  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    var hour = new DateTime.now().hour;
    var minute = new DateTime.now().minute;
    var flag = (hour == userInfo['startHour'] && minute>userInfo['startMins'])||(hour == userInfo['endHour'] && minute<userInfo['endMins']);
    if(flag){
      onPress = getToken;
    }else{
      onPress = null;
    }
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text('DASHER-HELP'),
        ),
        body: Column(children: <Widget>[
          Center(
              child: Container(
                height: 90,
                margin: EdgeInsets.fromLTRB(0.0, 60.0, 0.0, 0.0),
                child: Text(
                  userInfo['status'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 2.0,
                  ),
                ),
              )),
          Center(
              child: Container(
                height: 150,
                alignment: Alignment.center,
                child: MaterialButton(
                    splashColor: Colors.blueAccent,
                    onPressed: onPress,
                    shape: CircleBorder(),
                    color: Colors.blue,
                    textColor: Colors.white,
                    disabledColor:Color.fromRGBO(191,191,191,1.0),
                    disabledTextColor:Colors.white,
                    child: Text('CILCK'),
                    minWidth: 220.0,
                    height: 220.0,
                    elevation: 15),
              )),
        ]));
  }
}
