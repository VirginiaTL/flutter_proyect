import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isAuthenticated = false;
  LoginPage({super.key});

  Future<void> _login(BuildContext context) async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/users'));

    if (response.statusCode == 200) {
      final List users = json.decode(response.body);

      print('Usuarios: $response');

      final user = users.firstWhere(
        (user) => user['username'] == username && user['password'] == password,
        orElse: () => null,
      );

      if (user != null) {
        isAuthenticated = true; // Actualizar la variable global
        print('Login successful');
        // Redirigir a la página principal
        GoRouter.of(context).go('/');
      } else {
        print('Invalid username or password');
      }
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
