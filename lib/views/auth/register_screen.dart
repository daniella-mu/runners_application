// lib/views/auth/register_screen.dart
import 'package:flutter/material.dart';
import '/controllers/auth_controller.dart';
import '/controllers/user_controller.dart';
import '/models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthController _authController = AuthController();
  final UserController _userController = UserController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _isLoading = true;
    });

    // Local validation
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = "Please enter your full name";
        _isLoading = false;
      });
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailError = "Email required";
        _isLoading = false;
      });
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _passwordError = "Password required";
        _isLoading = false;
      });
      return;
    }
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      setState(() {
        _confirmPasswordError = "Passwords don’t match";
        _isLoading = false;
      });
      return;
    }

    try {
      final result = await _authController.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim()
      );

      if (!mounted) return;

      if (result == true) {
        // 🚀 Go to home immediately after successful registration
        Navigator.pushReplacementNamed(context, '/home');

        // Try to create profile in the background (don’t block navigation)
        final userId = _authController.getCurrentUser()?.id;
        if (userId != null) {
          await _userController.createUserProfile(
            UserModel(
              id: userId,
              fullName: _nameController.text.trim(),
              email: _emailController.text.trim(),
            ),
          );
        }
      } else {
        setState(() {
          _emailError = result.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _emailError = "Unexpected error: $e";
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, color: Colors.purple, size: 48),
              const SizedBox(height: 8),
              const Text(
                "Create Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Full Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Full Name",
                  errorText: _nameError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 24),

              // Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  errorText: _emailError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 18),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  errorText: _passwordError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 18),

              // Confirm Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Confirm Password",
                  errorText: _confirmPasswordError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 18),

              // Register button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Register",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Back to Login
              TextButton(
                onPressed: _isLoading ? null : _goToLogin,
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
