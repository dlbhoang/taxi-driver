import 'package:drivers_app/authentication/reset_password_screen.dart';
import 'package:drivers_app/authentication/signup_screen.dart';
import 'package:drivers_app/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../methods/common_methods.dart';
import '../widgets/loading_dialog.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}



class _LoginScreenState extends State<LoginScreen>
{
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();



  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);

    signInFormValidation();
  }

  signInFormValidation()
  {

    if(!emailTextEditingController.text.contains("@"))
    {
      cMethods.displaySnackBar("vui lòng viết email hợp lệ.", context);
    }
    else if(passwordTextEditingController.text.trim().length < 5)
    {
      cMethods.displaySnackBar("mật khẩu của bạn phải có ít nhất 6 ký tự trở lên.", context);
    }
    else
    {
      signInUser();
    }
  }

  signInUser() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Cho phép bạn đăng nhập..."),
    );

    final User? userFirebase = (
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).catchError((errorMsg)
        {
          Navigator.pop(context);
          cMethods.displaySnackBar(errorMsg.toString(), context);
        })
    ).user;

    if(!context.mounted) return;
    Navigator.pop(context);

    if(userFirebase != null)
    {
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("drivers").child(userFirebase.uid);
      usersRef.once().then((snap)
      {
        if(snap.snapshot.value != null)
        {
          if((snap.snapshot.value as Map)["blockStatus"] == "no")
          {
            Navigator.push(context, MaterialPageRoute(builder: (c)=> const Dashboard()));
          }
          else
          {
            FirebaseAuth.instance.signOut();
            cMethods.displaySnackBar("bạn đã bị chặn. Liên hệ quản trị viên: danhlam0194@gmail.com", context);
          }
        }
        else
        {
          FirebaseAuth.instance.signOut();
          cMethods.displaySnackBar("your record do not exists as a Driver.", context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              const SizedBox(
                height: 60,
              ),

              Image.asset(
                  "assets/images/uberexec.png",
                width: 220,
              ),

              const SizedBox(
                height: 30,
              ),

              const Text(
                "Đăng nhập với vai tài xê",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              //text fields + button
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [

                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Mật khẩu",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32,),

                    ElevatedButton(
                      onPressed: ()
                      {
                        checkIfNetworkIsAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                      ),
                      child: const Text(
                          "Đăng nhập"
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 12,),

              //textbutton
              TextButton(
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> SignUpScreen()));
                },
                child: const Text(
                  "Bạn chưa có tài khoản? Đăng kí ngày!",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              TextButton(
                onPressed: ()
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
                  );
                },
                child: const Text(
                  "Reset Password",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
