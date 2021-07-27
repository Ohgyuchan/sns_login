import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sns_login/screens/sign_in_screen.dart';
import 'package:sns_login/src/authentication.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final LoginType loginType;
  const HomeScreen({Key? key, required this.user, required this.loginType})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User _user;
  late LoginType _loginType;

  @override
  void initState() {
    _user = widget.user;
    _loginType = widget.loginType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase SNS Login'),
      ),
      body: Column(
        children: [
          Center(
            child: Text('${_user.displayName}님 환영합니다.'),
          ),
          _signOutButton(),
        ],
      ),
    );
  }

  Widget _signOutButton() {
    return MaterialButton(
      color: Colors.redAccent,
      shape: StadiumBorder(),
      onPressed: () async {
        _loginType == LoginType.Google
            ? await Authentication.signOutWithGoogle(context: context)
            : await Authentication.signOutWithFacebook(context: context);
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
                _loginType.toString(),
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
