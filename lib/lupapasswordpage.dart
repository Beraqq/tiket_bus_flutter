import 'package:flutter/material.dart';

class LupapasswordPage extends StatefulWidget {
  const LupapasswordPage({super.key});

  @override
  State<LupapasswordPage> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<LupapasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Set AppBar to blue
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.end, // Align logo and text to the right
          children: [
            // Logo image (you can replace with an actual image asset)
            Image.asset(
              'assets/images/gambar2.png', // Replace with the actual path to the logo
              width: 30, // Set the width for the logo
              height: 30, // Set the height for the logo
            ),
            const SizedBox(width: 8), // Space between logo and text
            const Text(
              'The_Buzee.com', // Text beside the logo
              style: TextStyle(
                fontSize: 20, // Adjust font size as needed
                fontWeight: FontWeight.bold, // Make text bold
                color: Colors.white, // Set text color to white
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Ubah Password', // Text for the password change
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Set text color to black
                  ),
                ),
              ),
              const Text(
                'Masukan email yang anda daftarkan pada aplikasi ini, sistem akan mengirimkan link form password baru.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Simulate sending the reset password request
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Tautan untuk mengubah password telah dikirimkan ke email Anda.',
                        ),
                      ),
                    );
                    // Implement logic to send email or navigate to another page if needed
                  }
                },
                child: const Text('Kirim'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
