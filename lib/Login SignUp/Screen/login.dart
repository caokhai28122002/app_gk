import 'package:app_gk/home_screen.dart';
import 'package:flutter/material.dart';
import '../Widget/button.dart';

import '../Services/authentication.dart';
import '../Widget/snackbar.dart';
import '../Widget/text_field.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

/// giải phóng bộ nhớ 
  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
   
// xác thực user AuthMethod
  void loginUser() async {
    setState(() {
      isLoading = true;
    });
    String res = await AuthMethod().loginUser(
        email: emailController.text, password: passwordController.text);

    if (res == "success") {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: height / 2.7,
            ),
            TextFieldInput(
                icon: Icons.person,
                textEditingController: emailController,
                hintText: ' email',
                textInputType: TextInputType.text),
            TextFieldInput(
              icon: Icons.lock,
              textEditingController: passwordController,
              hintText: ' password',
              textInputType: TextInputType.text,
              isPass: true,
            ),
            MyButtons(onTap: loginUser, text: "Log In"),
            Row(
              children: [
                Expanded(
                  child: Container(height: 1, color: Colors.black26),
                ),
                const Text("  or  "),
                Expanded(
                  child: Container(height: 1, color: Colors.black26),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Chưa có tài khoản "),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Đăng kí tài khoản",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
