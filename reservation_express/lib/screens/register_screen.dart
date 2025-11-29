import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reservation_express/models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  bool _emailChecked = false;
  bool _emailAvailable = true;

  Future<void> _checkEmail() async {
    if (_emailController.text.isEmpty) return;

    try {
      final exists = await ApiService.checkEmailExists(_emailController.text.trim());
      setState(() {
        _emailChecked = true;
        _emailAvailable = !exists;
      });
    } catch (e) {
      _showError('Erreur de vérification email: $e');
    }
  }

  Future<void> _register() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Les mots de passe ne correspondent pas');
      return;
    }

    if (!_emailAvailable) {
      _showError('Cet email est déjà utilisé');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = User(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      final response = await ApiService.register(user);

      if (response.statusCode == 201) {
        final userData = json.decode(response.body);
        
        await AuthService.saveUserData(
          userData['id'],
          userData['email'],
          userData['fullName'],
          userData['phoneNumber'],
        );

        _showSuccess('Compte créé avec succès!');
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        final error = json.decode(response.body);
        _showError(error['message'] ?? 'Erreur lors de l\'inscription');
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Créer un compte')),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nom complet',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                suffixIcon: _emailChecked
                    ? Icon(
                        _emailAvailable ? Icons.check : Icons.close,
                        color: _emailAvailable ? Colors.green : Colors.red,
                      )
                    : null,
                errorText: _emailChecked && !_emailAvailable
                    ? 'Cet email est déjà utilisé'
                    : null,
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {
                  _emailChecked = false;
                });
              },
              onEditingComplete: _checkEmail,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(),
                errorText: _confirmPasswordController.text.isNotEmpty &&
                        _passwordController.text != _confirmPasswordController.text
                    ? 'Les mots de passe ne correspondent pas'
                    : null,
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      child: Text('Créer mon compte', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Déjà un compte? Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}