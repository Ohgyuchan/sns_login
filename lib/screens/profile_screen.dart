import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/all.dart' as kakao;
import 'package:sns_login/screens/sign_in_screen.dart';
import 'package:sns_login/src/authentication.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _email;
  late String _name;
  late String _profileUrl;
  @override
  void initState() {
    _initTexts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('카카오 로그인'),
      ),
      body: Center(
        child: _email.isEmpty
            ? CircularProgressIndicator()
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: Image.network(_profileUrl).image,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_email),
                          Text(_name),
                        ],
                      ),
                    ],
                  ),
                  _signOutButton(),
                ],
              ),
      ),
    );
  }

  _initTexts() async {
    final kakao.User user = await kakao.UserApi.instance.me();

    setState(() {
      _email = user.kakaoAccount!.email.toString();
      _name = user.kakaoAccount!.profile!.nickname.toString();
      _profileUrl = user.kakaoAccount!.profile!.thumbnailImageUrl.toString();
    });
  }

  Widget _signOutButton() {
    return MaterialButton(
      color: Colors.redAccent,
      shape: StadiumBorder(),
      onPressed: () async {
        Navigator.of(context).pushReplacement(_routeToSignInScreen());
      },
      elevation: 5.0,
      child: Container(
        width: 250,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(6.0),
              child: Text(
                '로그아웃',
                style: TextStyle(
                  fontSize: 19.0,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
