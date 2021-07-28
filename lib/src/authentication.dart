import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sns_login/screens/home_screen.dart';
import 'package:uuid/uuid.dart';

class Authentication {
  static late LoginType _loginType = LoginType.Google;
  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            loginType: _loginType,
            user: user,
          ),
        ),
      );
    }

    return firebaseApp;
  }

  static Future<UserCredential> signInWithKaKao() async {
    final clientState = Uuid().v4();
    final url = Uri.https('kauth.kakao.com', '/oauth/authorize', {
      'response_type': 'code',
      'client_id': "<카카오 관리 콘솔에서 제공하는 REST_API 키 입력>",
      'response_mode': 'form_post',
      'redirect_uri': '<카카오에 등록한 authrization_code 받을 return uri 입력>',
      'scope': 'account_email profile',
      'state': clientState,
    });

    final result = await FlutterWebAuth.authenticate(
        url: url.toString(),
        callbackUrlScheme: "webauthcallback"); //"applink"//"signinwithapple"
    final body = Uri.parse(result).queryParameters;
    print(body["code"]);

    final tokenUrl = Uri.https('kauth.kakao.com', '/oauth/token', {
      'grant_type': 'authorization_code',
      'client_id': "<카카오 관리 콘솔에서 제공하는 REST_API 키 입력>",
      'redirect_uri': '<카카오에 등록한 authrization_code 받을 return uri 입력>',
      'code': body["code"],
    });
    var responseTokens = await http.post(tokenUrl.toString());
    Map<String, dynamic> bodys = json.decode(responseTokens.body);
    var response = await http.post(
        "https://adaptive-river-train.glitch.me/callbacks/kakao/token",
        body: {"accessToken": bodys['access_token']});
    return FirebaseAuth.instance.signInWithCustomToken(response.body);
  }

  static Future<User?> signInWithFacebook() async {
    _loginType = LoginType.Facebook;
    final LoginResult result = await FacebookAuth.instance.login();

    final AccessToken accessToken = result.accessToken!;

    final facebookAuthCredential =
        FacebookAuthProvider.credential(accessToken.token);

    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential);

    final User? user = userCredential.user;

    return user;
  }

  static Future<void> signOutWithFacebook(
      {required BuildContext context}) async {
    try {
      await FacebookAuth.instance.logOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        Authentication.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    _loginType = LoginType.Google;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);

          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                content:
                    'The account already exists with a different credential.',
              ),
            );
          } else if (e.code == 'invalid-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                content:
                    'Error occurred while accessing credentials. Try again.',
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content: 'Error occurred using Google Sign-In. Try again.',
            ),
          );
        }
      }
      return user;
    }
  }

  static Future<void> signOutWithGoogle({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        Authentication.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }
}

enum LoginType { Google, Facebook, Kakao, Naver }
