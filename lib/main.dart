import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:sns_login/screens/sign_in_screen.dart';

void main() {
  KakaoContext.clientId = "b0a20ee901c809d4063fc3fd07f63ce0";
  KakaoContext.javascriptClientId = "222beab234fc71597b55198dfa69f6ae";
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignInScreen(),
    );
  }
}
