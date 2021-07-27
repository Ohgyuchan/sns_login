import 'package:flutter/material.dart';
import 'package:sign_button/constants.dart';
import 'package:sign_button/create_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sns_login/src/authentication.dart';
import 'package:sns_login/screens/home_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder(
                        future:
                            Authentication.initializeFirebase(context: context),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error initializing Firebase');
                          } else if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Column(
                              children: [
                                _googleSignInButton(),
                                _kakaoSignInButton(),
                                _facebookSignInButton(),
                              ],
                            );
                          }
                          return CircularProgressIndicator();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _googleSignInButton() {
    return SignInButton(
      buttonType: ButtonType.google,
      onPressed: _googleSignIn,
    );
  }

  Widget _facebookSignInButton() {
    return MaterialButton(
      color: Color(0xFF1877F2),
      shape: StadiumBorder(),
      onPressed: _facebookSignIn,
      elevation: 5.0,
      child: Container(
        width: 200,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(6.0),
              child: Image.asset(
                'packages/sign_button/images/facebook.png',
                width: 25.0,
                height: 25.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(6.0),
              child: Text(
                'Sign in with Facebook',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kakaoSignInButton() {
    return MaterialButton(
      color: Color(0xffffd25c),
      shape: StadiumBorder(),
      onPressed: () {
        print('click kakao');
      },
      elevation: 5.0,
      child: Container(
        width: 200,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(6.0),
              child: Image.asset(
                'assets/images/kakao.png',
                width: 25.0,
                height: 25.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(6.0),
              child: Text(
                'Sign in with Kakao',
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _facebookSignIn() async {
    User? user = await Authentication.signInWithFacebook();

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            user: user,
            loginType: LoginType.Facebook,
          ),
        ),
      );
    }
  }

  Future<void> _googleSignIn() async {
    User? user = await Authentication.signInWithGoogle(context: context);

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            user: user,
            loginType: LoginType.Google,
          ),
        ),
      );
    }
  }
}
