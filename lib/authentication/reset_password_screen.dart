import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/loading_dialog.dart';
import '../methods/common_methods.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController emailController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Nhập email của bạn',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                resetPassword();
              },
              child: const Text('Gửi email đặt lại'),
            ),
          ],
        ),
      ),
    );
  }

  void resetPassword() async {
    String email = emailController.text.trim();

    if (email.isNotEmpty && email.contains('@')) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "Sending reset email..."),
      );

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        Navigator.pop(context);
        cMethods.displaySnackBar("Password reset email sent!", context);
      } catch (error) {
        Navigator.pop(context);
        cMethods.displaySnackBar(error.toString(), context);
      }
    } else {
      cMethods.displaySnackBar("Please enter a valid email.", context);
    }
  }
}