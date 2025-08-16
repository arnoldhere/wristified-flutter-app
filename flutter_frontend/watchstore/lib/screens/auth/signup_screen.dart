import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE0C3FC), // light purple
              Color(0xFF8EC5FC), // soft blue
            ],
          ),
        ),
        child: const Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: SignupForm(),
          ),
        ),
      ),
    );
  }
}

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _fname = TextEditingController();
  final _lname = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false; // <-- Loading state

  // Method to handle signup
  Future<void> _handleSignup() async {
    // Prevent multiple submissions
    if (_isLoading) return;

    setState(() => _isLoading = true);

    // Call backend signup API
    final result = await AuthService.signup(
      _fname.text.trim(),
      _lname.text.trim(),
      _email.text.trim(),
      _phone.text.trim(),
      _password.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      // ✅ Signup successful
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful! Please login.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // ❌ Signup failed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Signup failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size.width < 500 ? size.width * 0.9 : 400,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Signup",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // First Name
          TextField(
            controller: _fname,
            decoration: const InputDecoration(
              labelText: 'First Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Last Name
          TextField(
            controller: _lname,
            decoration: const InputDecoration(
              labelText: 'Last Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Email
          TextField(
            controller: _email,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),

          // Phone
          TextField(
            controller: _phone,
            decoration: const InputDecoration(
              labelText: 'Phone',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),

          // Password
          TextField(
            controller: _password,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Signup Button
          ElevatedButton(
            onPressed: _handleSignup,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: const Color(0xFF6A11CB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Signup"),
          ),
          const SizedBox(height: 8),

          // Already have account? Login link
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: const Text("Already have an account? Login"),
          ),
        ],
      ),
    );
  }
}
