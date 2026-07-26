import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isOtpSent = false;
  bool _isLoading = false;
  int _timerSeconds = 30;

  void _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      _isOtpSent = true;
    });
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _timerSeconds > 0 && _isOtpSent) {
        setState(() => _timerSeconds--);
        _startTimer();
      }
    });
  }

  void _verifyOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);
    // Simulate verification
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16.0 : 24.0,
              vertical: 24.0,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              width: double.infinity,
              padding: EdgeInsets.all(isSmallScreen ? 20.0 : 32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13), // Approx 0.05 opacity
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Branding Section
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF003366).withAlpha(26), // 0.1 opacity
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.account_balance, color: Color(0xFF003366), size: 28),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'RP MITRA',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003366),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Minerva Resolution LLP',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isOtpSent ? 'Enter the 6-digit code sent to your mobile' : 'IBC Claim Filing Portal - Secure Login',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 32),

                    if (!_isOtpSent) ...[
                      // Email Field
                      const Text('Email Address *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'e.g. name@company.com',
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                        ),
                        validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 20),

                      // Mobile Field
                      const Text('Mobile Number *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            width: 90,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: Image.network(
                                    'https://flagcdn.com/w20/in.png',
                                    width: 20,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 20),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('+91', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 4),
                                Text('|', style: TextStyle(color: Colors.grey.shade400)),
                              ],
                            ),
                          ),
                          hintText: '10-digit number',
                        ),
                        validator: (value) => value == null || value.length != 10 ? 'Enter 10-digit mobile number' : null,
                      ),
                      const SizedBox(height: 20),

                      // Captcha Section
                      const Text('Captcha Verification *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _captchaController,
                              decoration: const InputDecoration(hintText: 'Enter code'),
                              validator: (value) => value != '541218' ? 'Invalid Captcha' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '541218',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF003366),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const Text('One Time Password (OTP) *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: '000000',
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _isOtpSent = false),
                            child: const Text('Change Number', style: TextStyle(fontSize: 12)),
                          ),
                          TextButton(
                            onPressed: _timerSeconds == 0 ? () {
                              setState(() {
                                _timerSeconds = 30;
                                _startTimer();
                              });
                            } : null,
                            child: Text(
                              _timerSeconds == 0 ? 'Resend OTP' : 'Resend in ${_timerSeconds}s',
                              style: TextStyle(fontSize: 12, color: _timerSeconds == 0 ? Colors.blue : Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 32),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : (_isOtpSent ? _verifyOtp : _sendOtp),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                        ),
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              _isOtpSent ? 'VERIFY & LOGIN' : 'GET OTP',
                              style: const TextStyle(letterSpacing: 1, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Column(
                        children: [
                          const Text(
                            'By logging in, you agree to our Terms & Privacy Policy',
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12),
                          const Text(
                            'Powered by @Dcirrus',
                            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
