import 'package:flutter/material.dart';
import '/controllers/auth_controller.dart';
import '/widgets/custom_button.dart';
import '/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = AuthController();

  bool _loading = false;
  bool _obscure = true;

  String? _errorMessage; // <-- inline error (no SnackBar)

  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Email required';
    final re = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!re.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Password required';
    if (value.length < 8) return 'Use at least 8 characters';
    return null;
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null); // clear previous error

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final ok = await _authController.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (ok == true) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Show a friendly inline message
        final msg = (ok is String && ok.isNotEmpty)
            ? ok
            : 'Invalid email or password. Please try again.';
        setState(() => _errorMessage = msg);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToRegister() => Navigator.pushReplacementNamed(context, '/register');
  void _goToForgot() => Navigator.pushNamed(context, '/forgot-password');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_run, color: Colors.purple, size: 48),
                  const SizedBox(height: 8),
                  const Text('Runner',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Welcome Back!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 24),

                  // --- Form ---
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          hint: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 22),

                        CustomTextField(
                          controller: _passwordController,
                          hint: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: _validatePassword,
                          obscure: _obscure,
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscure = !_obscure),
                            tooltip: _obscure ? 'Show password' : 'Hide password',
                            splashRadius: 20,
                          ),
                          onSubmitted: (_) => _loading ? null : _login(),
                        ),
                        const SizedBox(height: 20),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            label: _loading ? 'Logging in...' : 'Login',
                            onPressed: _loading ? null : _login,
                            color: Colors.purple,
                            loading: _loading,
                          ),
                        ),

                        // Inline error message (no SnackBar)
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.redAccent),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Register button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              side: const BorderSide(
                                  color: Colors.purple, width: 1.5),
                            ),
                            onPressed: _loading ? null : _goToRegister,
                            child: const Text('Register',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Forgot Password (below Register)
                  TextButton(
                    onPressed: _loading ? null : _goToForgot,
                    child: const Text('Forgot Password?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
