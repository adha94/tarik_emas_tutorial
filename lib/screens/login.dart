import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tarik_emas_tutorial/screens/homepage.dart';
import 'package:tarik_emas_tutorial/screens/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utilities/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signIn(String emailUser, String passwordUser) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: emailUser, password: passwordUser)
        .then((value) => {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const HomePage()))
            })
        .catchError((e) {
      Fluttertoast.showToast(msg: e!.message);
    });
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Email',
          style: kLabelStyle,
        ),
        const SizedBox(
          height: 10.0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Enter your e-mail',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Password',
          style: kLabelStyle,
        ),
        const SizedBox(
          height: 10.0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white, fontFamily: 'OpenSans'),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Enter your password',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      width: MediaQuery.of(context).size.width * 1.0,
      padding: const EdgeInsets.symmetric(vertical: 35.0),
      child: ElevatedButton(
        onPressed: () {
          signIn(emailController.text.trim(), passwordController.text.trim());
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 15.0,
        ),
        child: const Text(
          'LOGIN',
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSignUpBtn() {
    return RichText(
        text: TextSpan(children: [
      TextSpan(
        text: 'Sign Up',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SignUpPage())),
      ),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: GestureDetector(
                onTap: (() => FocusScope.of(context).unfocus()),
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF73AEF5),
                            Color(0xFF61A4F1),
                            Color(0xFF478DE0),
                            Color(0xFF398AE5),
                          ],
                          stops: [0.1, 0.4, 0.7, 0.9],
                        ),
                      ),
                    ),
                    SizedBox(
                        height: double.infinity,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40.0,
                            vertical: 120.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'OpenSans',
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 30.0,
                              ),
                              _buildEmailTF(),
                              const SizedBox(
                                height: 30.0,
                              ),
                              _buildPasswordTF(),
                              _buildLoginBtn(),
                              _buildSignUpBtn(),
                            ],
                          ),
                        ))
                  ],
                ),
              ),
            );
          }),
    );
  }
}
