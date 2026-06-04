import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _nameController.text = prefs.getString('name') ?? '';
        _emailController.text = prefs.getString('email') ?? '';
        _phoneController.text = prefs.getString('phone') ?? '';
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text.trim());
    await prefs.setString('email', _emailController.text.trim());
    await prefs.setString('phone', _phoneController.text.trim());
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1F2BDB),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            tr(context, '✅ تم حفظ البيانات بنجاح', '✅ Profile saved successfully'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF1F2B63),
            foregroundColor: Colors.white,
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'تعديل',
                  onPressed: () => setState(() => _isEditing = true),
                )
              else
                TextButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          tr(context, 'حفظ', 'Save'),
                          style: const TextStyle(
                            color: Color(0xFFF2C230),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1F2BDB), Color(0xFF1F2B63)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Avatar circle with initials
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF2C230),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF1F2B63),
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nameController.text.isEmpty
                          ? tr(context, 'مستخدم', 'User')
                          : _nameController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _emailController.text.isEmpty
                          ? tr(context, 'لا يوجد بريد إلكتروني', 'No email set')
                          : _emailController.text,
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Personal Info Card ──────────────────────────────────
                  _sectionLabel(context, tr(context, 'البيانات الشخصية', 'Personal Info')),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isDark ? [] : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _profileField(
                          context,
                          icon: Icons.person_outline_rounded,
                          label: tr(context, 'الاسم الكامل', 'Full Name'),
                          controller: _nameController,
                          enabled: _isEditing,
                          keyboardType: TextInputType.name,
                          isFirst: true,
                        ),
                        _divider(),
                        _profileField(
                          context,
                          icon: Icons.email_outlined,
                          label: tr(context, 'البريد الإلكتروني', 'Email'),
                          controller: _emailController,
                          enabled: _isEditing,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _divider(),
                        _profileField(
                          context,
                          icon: Icons.phone_outlined,
                          label: tr(context, 'رقم الهاتف', 'Phone Number'),
                          controller: _phoneController,
                          enabled: _isEditing,
                          keyboardType: TextInputType.phone,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Account Actions ─────────────────────────────────────
                  _sectionLabel(context, tr(context, 'الحساب', 'Account')),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isDark ? [] : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _actionTile(
                          context,
                          icon: Icons.lock_outline_rounded,
                          iconColor: const Color(0xFF1F2BDB),
                          label: tr(context, 'تغيير كلمة المرور', 'Change Password'),
                          onTap: () => _showChangePasswordDialog(context),
                          isFirst: true,
                        ),
                        _divider(),
                        _actionTile(
                          context,
                          icon: Icons.notifications_outlined,
                          iconColor: const Color(0xFF27AE60),
                          label: tr(context, 'إشعارات', 'Notifications'),
                          onTap: () {},
                        ),
                        _divider(),
                        _actionTile(
                          context,
                          icon: Icons.logout_rounded,
                          iconColor: Colors.red,
                          label: tr(context, 'تسجيل الخروج', 'Sign Out'),
                          onTap: () => _confirmSignOut(context),
                          isLast: true,
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      tr(context, 'مواصلاتي v1.0.0', 'Mawasalaty v1.0.0'),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF9EA4B5),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _divider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 0,
      color: isDark ? Colors.white12 : const Color(0xFFF3F4F8),
    );
  }

  Widget _profileField(
    BuildContext context, {
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? 4 : 0,
        bottom: isLast ? 4 : 0,
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : const Color(0xFFF3F4F8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1F2BDB), size: 20),
        ),
        title: enabled
            ? TextField(
                controller: controller,
                keyboardType: keyboardType,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1F2B63),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle:
                      const TextStyle(color: Color(0xFF9EA4B5), fontSize: 12),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style:
                        const TextStyle(color: Color(0xFF9EA4B5), fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.text.isEmpty
                        ? tr(context, 'غير محدد', 'Not set')
                        : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty
                          ? Colors.grey[400]
                          : (isDark ? Colors.white : const Color(0xFF1F2B63)),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
        trailing: enabled
            ? const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF9EA4B5))
            : null,
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDestructive
                      ? Colors.red
                      : (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1F2B63)),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            if (!isDestructive)
              const Icon(Icons.chevron_right, color: Color(0xFF9EA4B5)),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr(context, 'تغيير كلمة المرور', 'Change Password')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: tr(context, 'كلمة المرور الحالية', 'Current Password'),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: tr(context, 'كلمة المرور الجديدة', 'New Password'),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr(context, 'إلغاء', 'Cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F2BDB),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final saved = prefs.getString('password') ?? '';
              if (oldCtrl.text == saved && newCtrl.text.isNotEmpty) {
                await prefs.setString('password', newCtrl.text);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(tr(
                          context, 'تم تغيير كلمة المرور', 'Password changed')),
                    ),
                  );
                }
              } else {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(tr(context, 'كلمة المرور الحالية غير صحيحة',
                          'Incorrect current password')),
                    ),
                  );
                }
              }
            },
            child: Text(tr(context, 'حفظ', 'Save'),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr(context, 'تسجيل الخروج', 'Sign Out')),
        content: Text(
          tr(context, 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
              'Are you sure you want to sign out?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr(context, 'إلغاء', 'Cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('email');
              await prefs.remove('password');
              await prefs.remove('name');
              await prefs.remove('phone');
              if (ctx.mounted) {
                Navigator.of(ctx).popUntil((route) => route.isFirst);
              }
            },
            child: Text(tr(context, 'خروج', 'Sign Out'),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
