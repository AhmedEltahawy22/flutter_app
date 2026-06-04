import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization.dart';
import '../../providers/app_language_scope.dart';
import '../../providers/app_route_preference_scope.dart';
import '../../providers/app_theme_scope.dart';
import '../auth/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('name') ?? '';
        _userEmail = prefs.getString('email') ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageNotifier = AppLanguageScope.notifierOf(context);
    final routePreferenceNotifier = AppRoutePreferenceScope.notifierOf(context);
    final themeNotifier = AppThemeScope.notifierOf(context);
    
    final routePreference = routePreferenceNotifier.value;
    final language = languageNotifier.value;
    final themeMode = themeNotifier.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2BDB),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(context, 'الإعدادات', 'Settings'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tr(context, 'خصص تجربتك', 'Customize your experience'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _settingsSectionTitle(tr(context, 'تفضيلات المسار', 'Route Preferences')),
              _settingsCard(
                children: [
                  _selectableRow(
                    icon: Icons.flash_on_outlined,
                    text: tr(context, 'أسرع مسار', 'Fastest Route'),
                    selected: routePreference == 'fastest',
                    onTap: () => routePreferenceNotifier.value = 'fastest',
                  ),
                  _selectableRow(
                    icon: Icons.sell_outlined,
                    text: tr(context, 'أرخص مسار', 'Cheapest Route'),
                    selected: routePreference == 'cheapest',
                    onTap: () => routePreferenceNotifier.value = 'cheapest',
                  ),
                  _selectableRow(
                    icon: Icons.compare_arrows_outlined,
                    text: tr(context, 'أقل تبديلات', 'Least Transfers'),
                    selected: routePreference == 'least_transfers',
                    onTap: () => routePreferenceNotifier.value = 'least_transfers',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _settingsSectionTitle(tr(context, 'اللغة', 'Language')),
              _settingsCard(
                children: [
                  _selectableRow(
                    icon: Icons.language,
                    text: 'English',
                    selected: language == 'en',
                    onTap: () => languageNotifier.value = 'en',
                  ),
                  _selectableRow(
                    icon: Icons.language_outlined,
                    text: tr(context, 'العربية', 'Arabic'),
                    selected: language == 'ar',
                    onTap: () => languageNotifier.value = 'ar',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _settingsSectionTitle(tr(context, 'المظهر', 'Appearance')),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, currentThemeMode, _) {
                  return _settingsCard(
                    children: [
                      _selectableRow(
                        icon: Icons.light_mode_outlined,
                        text: tr(context, 'فاتح', 'Light'),
                        selected: currentThemeMode == ThemeMode.light,
                        onTap: () => themeNotifier.value = ThemeMode.light,
                      ),
                      _selectableRow(
                        icon: Icons.dark_mode_outlined,
                        text: tr(context, 'داكن', 'Dark'),
                        selected: currentThemeMode == ThemeMode.dark,
                        onTap: () => themeNotifier.value = ThemeMode.dark,
                      ),
                      _selectableRow(
                        icon: Icons.settings_brightness_outlined,
                        text: tr(context, 'تلقائي', 'System'),
                        selected: currentThemeMode == ThemeMode.system,
                        onTap: () => themeNotifier.value = ThemeMode.system,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              _settingsCard(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_none, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr(context, 'الإشعارات', 'Notifications'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1F2B63),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tr(context, 'استلام تحديثات المسارات', 'Get route updates'),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _notificationsEnabled,
                        activeColor: const Color(0xFFF2C230),
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _settingsCard(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF1F2BDB),
                        child: Icon(
                          Icons.person_outline,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName.isNotEmpty ? _userName : tr(context, 'الملف الشخصي', 'Profile'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF1F2B63),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userEmail.isNotEmpty ? _userEmail : tr(context, 'إدارة حسابك', 'Manage your account'),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF9CA3AF),
                        size: 28,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

    );
  }

  Widget _settingsSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _selectableRow({
    required IconData icon,
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected 
              ? const Color(0xFFF2C230) 
              : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF9FAFC)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? const Color(0xFF1F2B63) : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? const Color(0xFF1F2B63)
                      : (isDark ? Colors.white70 : const Color(0xFF374151)),
                ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: selected ? const Color(0xFF1F2B63) : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}