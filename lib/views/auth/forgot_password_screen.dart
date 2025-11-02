import 'package:flutter/material.dart';
import '/controllers/auth_controller.dart';
import '/widgets/custom_textfield.dart';
import '/widgets/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authController = AuthController();

  bool _loading = false;
  String? _errorMessage;
  String? _successMessage;

  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!re.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();
    setState(() { _errorMessage = null; _successMessage = null; });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final ok = await _authController.forgotPassword(_emailController.text.trim());
      if (!mounted) return;

      if (ok == true) {
        setState(() => _successMessage = 'Password reset email sent! Check your inbox.');
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() => _errorMessage = (ok is String && ok.isNotEmpty) ? ok : 'Could not send reset email');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Forgot Password'),
        centerTitle: true,
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top icon + titles
                Icon(Icons.lock_reset_rounded, size: 72, color: Colors.purple[400]),
                const SizedBox(height: 16),
                const Text(
                  'Forgot Your Password?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter your email and we will send you a reset link.',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // The white card with shadow
                Card(
                  elevation: 8,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          // Input inside card with inner outline
                          Theme(
                            data: Theme.of(context).copyWith(
                              inputDecorationTheme: InputDecorationTheme(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                                ),
                              ),
                            ),
                            child: CustomTextField(
                              controller: _emailController,
                              hint: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined),
                              validator: _validateEmail,
                              onSubmitted: (_) => _loading ? null : _resetPassword(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (_errorMessage != null)
                            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                          if (_successMessage != null)
                            Text(_successMessage!, style: const TextStyle(color: Colors.green)),
                          if (_errorMessage != null || _successMessage != null)
                            const SizedBox(height: 8),

                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              label: _loading ? 'Sending…' : 'Send Reset Link',
                              onPressed: _loading ? null : _resetPassword,
                              color: Colors.purple,
                              loading: _loading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: _loading ? null : () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Back to Login', style: TextStyle(color: Colors.purple)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
