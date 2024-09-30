import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isAuthenticated = false;
  LoginPage({super.key});

  Future<void> _login(BuildContext context) async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();
    SharedPreferences preferences = await SharedPreferences.getInstance();

    final responselogin = await http.post(
        Uri.parse('https://fakestoreapi.com/auth/login'),
        body: {"username": username, "password": password});

    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/users'));

    if (responselogin.statusCode == 200) {
      var jsonlogin = jsonDecode(responselogin.body);
      preferences.setString("token", jsonlogin['token']);
      print(preferences.getString("token"));
      GoRouter.of(context).go('/');
      print('Login successful');
      final users = jsonDecode(response.body) as List;
      final user = users.firstWhere(
        (u) => u['username'] == username,
        orElse: () => null, // En caso de que no se encuentre el usuario
      );
      final userId = user['id'];
      preferences.setString("userId", userId.toString());
      print(preferences.getString("userId"));
    } else {
      print('Error fetching users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
