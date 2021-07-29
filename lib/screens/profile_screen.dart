import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/all.dart' as kakao;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _email;
  late String _name;
  @override
  void initState() {
    _initTexts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        Text('Kakao Login Success.'),
        Text(_email),
        Text(_name),
      ],
    ));
  }

  _initTexts() async {
    final kakao.User user = await kakao.UserApi.instance.me();

    setState(() {
      _email = user.kakaoAccount!.email.toString();
      _name = user.kakaoAccount!.profile!.nickname.toString();
    });
  }
}
