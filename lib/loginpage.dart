import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiketBus/models/api_response.dart';
import 'package:tiketBus/pages/homepage.dart';
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
    try {
      setState(() {
        loading = true;
      });

      print('Starting login process...');
      ApiResponse response = await login(txtEmail.text, txtPassword.text);
      print('Login response received');

      if (!mounted) return;

      if (response.error == null) {
        print('Login successful, verifying token...');

        // Tunggu sebentar untuk memastikan token tersimpan
        await Future.delayed(const Duration(milliseconds: 500));

        // Verifikasi token
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        print('Verified token after login: $token');

        if (token == null || token.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan sesi login'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage1()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${response.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error in login process: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
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
                            'Login',
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
                                'Register',
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
