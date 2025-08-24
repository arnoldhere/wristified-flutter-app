import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

import '../../constants/env.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool isLoading = false;
  String? phoneNumber;
  int _timerSeconds = 30;
  Timer? _timer;
  bool _canResend = false;

  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;

  static final String baseUrl = API_URL;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTimer();

    // Auto-focus first field
    Future.delayed(const Duration(milliseconds: 500), () {
      _focusNodes[0].requestFocus();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _animationController.forward();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timerSeconds = 30;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    final prefs = await SharedPreferences.getInstance();
    phoneNumber = prefs.getString("reset_phone");
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpValue {
    return _otpControllers.map((c) => c.text).join();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Check if all fields are filled
    if (_otpValue.length == 6) {
      _verifyOtp();
    }
  }

  void _shake() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpValue.length != 6) {
      _shake();
      _showErrorSnackBar("Please enter complete OTP");
      return;
    }

    setState(() => isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      final response = await http.post(
        Uri.parse("$baseUrl/auth/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phoneNumber,
          "otp": _otpValue,
        }),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
      _showSuccessSnackBar("OTP verified successfully!");
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pushNamed(context, '/new-password', arguments: phoneNumber);
      } else {
        _shake();
        _showErrorSnackBar("Invalid OTP. Please try again.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      _shake();
      _showErrorSnackBar("Network error. Please check your connection.");
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    try {
      // TODO: Implement resend OTP API call
      _showSuccessSnackBar("OTP resent successfully!");
      _startTimer();

      // Clear all fields
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    } catch (e) {
      _showErrorSnackBar("Failed to resend OTP");
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * (index.isEven ? 1 : -1), 0),
          child: child,
        );
      },
      child: Container(
        width: 50,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _focusNodes[index].hasFocus
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor.withOpacity(0.3),
            width: _focusNodes[index].hasFocus ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(
                _focusNodes[index].hasFocus ? 0.2 : 0.05,
              ),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            counterText: "",
            border: InputBorder.none,
          ),
          onChanged: (value) => _onOtpChanged(value, index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withOpacity(0.1),
              theme.primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.08,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom Back Button
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: theme.primaryColor,
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/forgot-password',
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.05),

                  // Verification Icon Animation
                  Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.mark_email_read,
                            size: 50,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Title
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Center(
                        child: Text(
                          "Verify OTP",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.headlineLarge?.color,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),

                  // Subtitle
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Center(
                        child: Text(
                          "Enter the 6-digit code sent to\n${phoneNumber ?? 'your phone'}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.05),

                  // OTP Input Fields
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          6,
                          (index) => _buildOtpField(index),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Timer and Resend
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Center(
                        child: _canResend
                            ? TextButton(
                                onPressed: _resendOtp,
                                child: Text(
                                  "Resend OTP",
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : Text(
                                "Resend OTP in $_timerSeconds seconds",
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Verify Button
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: isLoading ? 0 : 8,
                            shadowColor: theme.primaryColor.withOpacity(0.5),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    "Verify",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),

                  // Help Text
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            // Handle help
                          },
                          child: Text(
                            "Didn't receive the code?",
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
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
