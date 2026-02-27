// import 'package:flutter/material.dart';
// import '/controllers/auth_controller.dart';
// import '/widgets/custom_textfield.dart';
// import '/widgets/custom_button.dart';

// class ResetPasswordScreen extends StatefulWidget {
//   const ResetPasswordScreen({super.key});

//   @override
//   State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final _newPasswordController = TextEditingController();
//   final _confirmController = TextEditingController();
//   final _authController = AuthController();

//   bool _loading = false;
//   bool _obscureNew = true;
//   bool _obscureConfirm = true;

//   String? _errorMessage;
//   String? _successMessage;

//   String? _validatePassword(String? v) {
//     final value = v?.trim() ?? '';
//     if (value.isEmpty) {
//       return 'New password required';
//     }
//     if (value.length < 8) {
//       return 'Use at least 8 characters';
//     }
//     return null;
//   }

//   String? _validateConfirm(String? v) {
//     final value = v?.trim() ?? '';
//     if (value.isEmpty) {
//       return 'Please confirm your password';
//     }
//     if (value != _newPasswordController.text.trim()) {
//       return "Passwords don't match";
//     }
//     return null;
//   }

//   Future<void> _reset() async {
//     FocusScope.of(context).unfocus();
//     setState(() {
//       _errorMessage = null;
//       _successMessage = null;
//     });

//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() => _loading = true);
//     try {
//       final result = await _authController.updatePassword(
//         _newPasswordController.text.trim(),
//       );

//       if (!mounted) {
//         return;
//       }

//       if (result == true) {
//         setState(() {
//           _successMessage = 'Password updated successfully. Please log in.';
//         });

//         await Future.delayed(const Duration(seconds: 2));

//         if (mounted) {
//           Navigator.pushReplacementNamed(context, '/login');
//         }
//       } else {
//         final msg = (result is String && result.isNotEmpty)
//             ? result
//             : 'Failed to update password. Please try again.';
//         setState(() => _errorMessage = msg);
//       }
//     } catch (e) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {
//         _errorMessage = 'Something went wrong. Please try again.';
//       });
//     } finally {
//       if (mounted) {
//         setState(() => _loading = false);
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _newPasswordController.dispose();
//     _confirmController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text('Reset Password'),
//         centerTitle: true,
//         backgroundColor: Colors.purple,
//         elevation: 0,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 420),
//             child: Card(
//               elevation: 8,
//               shadowColor: Colors.black12,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
//                 child: Form(
//                   key: _formKey,
//                   autovalidateMode: AutovalidateMode.onUserInteraction,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.lock_reset_rounded,
//                         size: 64,
//                         color: Colors.purple[400],
//                       ),
//                       const SizedBox(height: 10),
//                       const Text(
//                         'Create a new password',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 6),
//                       const Text(
//                         'Enter and confirm your new password below.',
//                         style: TextStyle(fontSize: 14, color: Colors.black54),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 18),

//                       CustomTextField(
//                         controller: _newPasswordController,
//                         hint: 'New Password',
//                         prefixIcon: const Icon(Icons.lock_outline),
//                         validator: _validatePassword,
//                         obscure: _obscureNew,
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscureNew
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                           ),
//                           onPressed: () {
//                             setState(() => _obscureNew = !_obscureNew);
//                           },
//                         ),
//                       ),
//                       const SizedBox(height: 14),

//                       CustomTextField(
//                         controller: _confirmController,
//                         hint: 'Confirm Password',
//                         prefixIcon: const Icon(Icons.lock_person_outlined),
//                         validator: _validateConfirm,
//                         obscure: _obscureConfirm,
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscureConfirm
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                           ),
//                           onPressed: () {
//                             setState(() => _obscureConfirm = !_obscureConfirm);
//                           },
//                         ),
//                         onSubmitted: (_) {
//                           if (!_loading) {
//                             _reset();
//                           }
//                         },
//                       ),

//                       const SizedBox(height: 14),

//                       if (_errorMessage != null)
//                         Text(
//                           _errorMessage!,
//                           style: const TextStyle(color: Colors.red),
//                         ),
//                       if (_successMessage != null)
//                         Text(
//                           _successMessage!,
//                           style: const TextStyle(color: Colors.green),
//                         ),
//                       if (_errorMessage != null || _successMessage != null)
//                         const SizedBox(height: 8),

//                       SizedBox(
//                         width: double.infinity,
//                         child: CustomButton(
//                           label: _loading ? 'Updating…' : 'Reset Password',
//                           onPressed: _loading ? null : _reset,
//                           color: Colors.purple,
//                           loading: _loading,
//                         ),
//                       ),

//                       const SizedBox(height: 10),
//                       TextButton(
//                         onPressed: _loading
//                             ? null
//                             : () {
//                                 Navigator.pushReplacementNamed(
//                                   context,
//                                   '/login',
//                                 );
//                               },
//                         child: const Text(
//                           'Back to Login',
//                           style: TextStyle(color: Colors.purple),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
