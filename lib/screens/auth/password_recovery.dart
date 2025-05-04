import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartscalex/screens/auth.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _codeSent = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _userEmail;

  /* ───────────────────────── helper methods ───────────────────────── */

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Auth().sendPasswordResetEmail(_emailController.text.trim());

      if (mounted) {
        setState(() {
          _codeSent = true;
          _userEmail = _emailController.text.trim();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset link sent to $_userEmail'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.teal.shade600,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _parseFirebaseError(e));
    } catch (e) {
      setState(() => _errorMessage = 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCodeAndReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: _codeController.text.trim(),
        newPassword: _passwordController.text.trim(),
      );

      if (mounted) {
        setState(() => _codeSent = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password reset successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.teal.shade600,
          ),
        );
      }

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _parseFirebaseError(e));
    } catch (e) {
      setState(() => _errorMessage = 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _parseFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'invalid-email':
        return 'Email address is invalid.';
      case 'expired-action-code':
        return 'Code has expired – request a new one.';
      case 'invalid-action-code':
        return 'Reset code is invalid.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      default:
        return 'Error: ${e.message}';
    }
  }

  /* ───────────────────────── UI  ───────────────────────── */

  @override
  Widget build(BuildContext context) {
    const Color _kPrimary = Color(0xFF1565C0); // blue 800
    const Color _kSecondary = Color(0xFF2E7D32); // green 600
    const Color _kCardBG = Colors.white;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Password Reset'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      extendBodyBehindAppBar: true,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1565C0), // blue 800
              Color(0xFF7B1FA2), // purple 600
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              color: _kCardBG,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_reset, size: 68, color: _kPrimary),
                      const SizedBox(height: 24),

                      /* ────────── STEP 1: email ────────── */
                      if (!_codeSent) ...[
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email,
                          keyBoard: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email.';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Enter a valid email address.';
                            }
                            return null;
                          },
                          iconColor: _kPrimary,
                        ),
                        const SizedBox(height: 24),
                        _buildWideButton(
                          text: 'Send Reset Link',
                          colour: const Color.fromARGB(255, 1, 6, 12),
                          onPressed: _sendResetLink,
                          busy: _isLoading,
                        ),
                      ],

                      /* ────────── STEP 2: code + new pwd ────────── */
                      if (_codeSent) ...[
                        Text(
                          'Enter the verification code sent to $_userEmail',
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: Colors.grey.shade700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        _buildTextField(
                          controller: _codeController,
                          label: 'Verification Code',
                          icon: Icons.code,
                          validator:
                              (v) =>
                                  (v == null || v.isEmpty)
                                      ? 'Please enter the code.'
                                      : null,
                          iconColor: _kPrimary,
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: _passwordController,
                          label: 'New Password',
                          icon: Icons.lock,
                          obscure: true,
                          validator:
                              (v) =>
                                  (v == null || v.length < 6)
                                      ? 'Minimum 6 characters.'
                                      : null,
                          iconColor: _kPrimary,
                        ),
                        const SizedBox(height: 28),

                        _buildWideButton(
                          text: 'Reset Password',
                          colour: _kSecondary,
                          onPressed: _verifyCodeAndReset,
                          busy: _isLoading,
                        ),
                      ],

                      /* ────────── error message ────────── */
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 18),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFD32F2F), // deep red
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /* ───────────────── reusable widgets ───────────────── */

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyBoard,
    String? Function(String?)? validator,
    bool obscure = false,
    required Color iconColor,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyBoard,
      obscureText: obscure,
      obscuringCharacter: '•',
      validator: validator,
      inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: iconColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildWideButton({
    required String text,
    required Color colour,
    required VoidCallback onPressed,
    required bool busy,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colour,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            busy
                ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
