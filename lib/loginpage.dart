import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiketBus/models/api_response.dart';
import 'package:tiketBus/registerpage.dart';
import 'package:tiketBus/services/user_service.dart';

import 'constant.dart';
import 'homepage.dart';
import 'models/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();

  bool loading = false;

  void _loginUser() async {
    ApiResponse response = await login(txtEmail.text, txtPassword.text);

    if (response.error == null && response.data != null) {
      // Login berhasil
      final responseData = response.data as Map<String, dynamic>;

      // Simpan data user ke SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', responseData['token'] ?? '');
      if (responseData['user'] != null) {
        await prefs.setInt('id', responseData['user']['id'] ?? 0);
        await prefs.setString('name', responseData['user']['name'] ?? '');
        await prefs.setString('email', responseData['user']['email'] ?? '');
        await prefs.setString('phone', responseData['user']['phone'] ?? '');
      }

      // Navigate to HomePage
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false);
      }
    } else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}')),
      );
    }
  }

  void _saveAndRedirectToHome(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', user.token ?? '');
    await prefs.setInt('id', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top section: Logo or image
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blue, // Background color for the top section
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/images/gambar2.png', // Path to your image asset
                        fit: BoxFit.cover, // Make the image fill the container
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom section: Login form
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white, // Background color for the form
              child: SingleChildScrollView(
                child: Center(
                  child: Form(
                    key: formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize:
                                  24, // Increased font size for better readability
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Please enter your credentials to continue',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email field
                        TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: txtEmail,
                            decoration: inputDecoration('Email'),
                            validator: (val) =>
                                val!.length < 8 ? 'Invalid email' : null),
                        const SizedBox(height: 20),

                        // Password field
                        TextFormField(
                            controller: txtPassword,
                            decoration: inputDecoration('Password'),
                            obscureText: true,
                            validator: (val) => val!.isEmpty
                                ? 'Required at least 8 chars'
                                : null),
                        const SizedBox(height: 20),

                        // Login button
                        loading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  if (formkey.currentState!.validate()) {
                                    setState(() {
                                      loading = true;
                                      _loginUser();
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(
                                      50), // Stretch button
                                ),
                                child: const Text('Login'),
                              ),

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => Registerpage()),
                                );
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
