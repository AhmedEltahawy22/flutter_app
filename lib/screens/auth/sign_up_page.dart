import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../core/localization.dart';
import '../home_page.dart';
import '../../widgets/google_logo_painter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}
class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Stack(
              children: [
                Container(
                  height: size.height * 0.30,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1F2B63), Color(0xFFF6C63B)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 8,
                  child: BackButton(
                    color: Colors.white,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.14),
                              blurRadius: 16,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            logoAsset,
                            width: 64,
                            height: 64,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Text(
                              'مواصلاتي',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF1F2B63),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.18, left: 16, right: 16, bottom: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '✨',
                              style: TextStyle(fontSize: 26),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              tr(context, 'إنشاء حساب جديد', 'Create Account'),
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF1F2B63),
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr(context, 'انضم إلينا وابدأ رحلتك', 'Join us and start your journey'),
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 22),
                        // Full Name
                        Form(
                          key: _formKey,
                          child: AutofillGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Full Name
                                TextFormField(
                                  controller: _nameController,
                                  autofillHints: const [AutofillHints.name],
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                  validator: (value) => value == null || value.trim().isEmpty ? tr(context, 'الاسم مطلوب', 'Name is required') : null,
                                  decoration: InputDecoration(
                                    labelText: tr(context, 'الاسم الكامل', 'Full Name'),
                                    labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                    prefixIcon: const Icon(Icons.person_outline),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF7F9FE),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                // Email
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.newUsername, AutofillHints.email],
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) return tr(context, 'البريد مطلوب', 'Email is required');
                                    if (!value.contains('@')) return tr(context, 'بريد غير صالح', 'Invalid email');
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: tr(context, 'البريد الإلكتروني', 'Email Address'),
                                    labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                    prefixIcon: const Icon(Icons.email_outlined),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF7F9FE),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                // Password
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  autofillHints: const [AutofillHints.newPassword],
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                  validator: (value) => value != null && value.length < 6 ? tr(context, 'كلمة المرور قصيرة', 'Password is too short') : null,
                                  decoration: InputDecoration(
                                    labelText: tr(context, 'كلمة المرور', 'Password'),
                                    labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF7F9FE),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                // Confirm Password
                                TextFormField(
                                  controller: _confirmController,
                                  obscureText: _obscureConfirm,
                                  autofillHints: const [AutofillHints.newPassword],
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                  validator: (value) => value != _passwordController.text ? tr(context, 'غير متطابق', 'Does not match') : null,
                                  decoration: InputDecoration(
                                    labelText: tr(context, 'تأكيد كلمة المرور', 'Confirm Password'),
                                    labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscureConfirm
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined),
                                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                    ),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF7F9FE),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        // Sign Up Button
                        ElevatedButton(
                          onPressed: () async {
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            
                            final email = _emailController.text.trim();
                            final password = _passwordController.text;
                            final name = _nameController.text.trim();

                            try {
                              final credential = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                    email: email,
                                    password: password,
                                  );
                              // حفظ الاسم في Firebase profile
                              await credential.user?.updateDisplayName(name);
                              // حفظ الاسم في SharedPreferences للعرض في الهوم
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('name', name);

                              TextInput.finishAutofillContext();
                              if (context.mounted) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const HomePage()),
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              if (!context.mounted) return;
                              final msg = switch (e.code) {
                                'email-already-in-use' => tr(context, 'البريد مسجّل بالفعل', 'Email already in use'),
                                'weak-password'        => tr(context, 'كلمة المرور ضعيفة جداً (6 أحرف أدنى)', 'Password too weak (min 6 chars)'),
                                'invalid-email'        => tr(context, 'بريد غير صالح', 'Invalid email format'),
                                _                      => tr(context, 'حدث خطأ، حاول مرة أخرى', 'An error occurred'),
                              };
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.red.shade700,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  content: Text(msg),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF2C230),
                            foregroundColor: const Color(0xFF1F2B63),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            shadowColor: const Color(0xFFF2C230).withOpacity(0.4),
                          ),
                          child: Text(
                            tr(context, 'إنشاء الحساب', 'Create Account'),
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                tr(context, 'أو تابع مع', 'or continue with'),
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  side: const BorderSide(color: Color(0xFF1F2B63)),
                                  backgroundColor: const Color(0xFF1F2B63),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('G',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17)),
                                    const SizedBox(width: 8),
                                    Text(tr(context, 'جوجل', 'Google'),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  side: const BorderSide(color: Color(0xFF1F2B63)),
                                  backgroundColor: const Color(0xFF1F2B63),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('f',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17)),
                                    const SizedBox(width: 8),
                                    Text(tr(context, 'فيسبوك', 'Facebook'),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tr(context, 'لديك حساب بالفعل؟', 'Already have an account?'),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                tr(context, 'تسجيل الدخول', 'Sign In'),
                                style: const TextStyle(
                                  color: Color(0xFF1F2B63),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}