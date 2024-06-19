import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:drivers_app/authentication/login_screen.dart';
import 'package:drivers_app/global/global_var.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController carController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setDriverInfo();
  }

  void setDriverInfo() {
    nameController.text = driverName;
    phoneController.text = driverPhone;
    emailController.text = FirebaseAuth.instance.currentUser!.email.toString();
    carController.text = "$carNumber - $carColor - $carModel";
  }

  void saveChanges() async {
      DatabaseReference driverRef = FirebaseDatabase.instance.ref().child("drivers").child(FirebaseAuth.instance.currentUser!.uid);
    await driverRef.update({
      "name": nameController.text,
      "phone": phoneController.text,
      "email": emailController.text,
      "car_details": {
        "carColor": carController.text.split('-').map((word) => word.trim()).toList()[1],
        "carModel": carController.text.split('-').map((word) => word.trim()).toList()[2],
        "carNumber": carController.text.split('-').map((word) => word.trim()).toList()[0],
      },

    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu thay đổi')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('không thể lưu thay đổi')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: NetworkImage(driverPhoto),
                  ),
                ),
              ),
              const SizedBox(height: 16,),
              buildTextField(nameController, 'Tên', Icons.person),
              buildTextField(phoneController, 'Điện thoại', Icons.phone_android_outlined),
              buildTextField(emailController, 'Email', Icons.email),
              buildTextField(carController, 'Thông tin xe', Icons.drive_eta_rounded),
              const SizedBox(height: 12,),
              ElevatedButton(
                onPressed: saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 18),
                ),
                child: const Text("Lưu thay đổi"),
              ),
              const SizedBox(height: 12,),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 18),
                ),
                child: const Text("Đăng xuất"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 8),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        enabled: true,
        style: const TextStyle(fontSize: 16, color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white24,
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
              width: 2,
            ),
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white,
          ),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
