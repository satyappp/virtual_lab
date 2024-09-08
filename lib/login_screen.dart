import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 240, 211), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/virtual_lab_logo.png',
              width: 300,
              height: 150,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12), 
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 16.0), 
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF8B4513)), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12), 
                  backgroundColor: Colors.white, 
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(color: Color(0xFF8B4513), fontSize: 16.0), 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
