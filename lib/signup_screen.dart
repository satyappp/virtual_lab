// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:math';
import 'member.dart';
import 'login_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, size: 100),
              const SizedBox(height: 20),
              SignupForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupForm extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _signup(BuildContext context) {
    final String name = _nameController.text;
    final String year = _yearController.text;
    final String password = _passwordController.text;
    final String id = _generateRandomId();

    final member = Member()
      ..id = id
      ..name = name
      ..year = year
      ..password = password;

    final memberBox = Hive.box<Member>('members');
    memberBox.add(member);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signup Successful'),
        content: Text('Your ID is $id. Please save this ID for login.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _generateRandomId() {
    const length = 8;
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();

    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _yearController,
            decoration: const InputDecoration(labelText: 'Year'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your year';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _signup(context);
              }
            },
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}
