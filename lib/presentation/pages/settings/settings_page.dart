import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_profile_provider.dart';
import 'package:yks_vision_tablet/data/datasources/seeding_script.dart';
import 'package:yks_vision_tablet/presentation/providers/question_provider.dart';
import 'personal_info_page.dart';
import 'static_content_page.dart';
import 'contact_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'Ayarlar',
          style: TextStyle(color: theme.text, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.text),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ), // Tablet optimization
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              // 1. Account Section
              _buildSectionTitle('HESAP', theme),
              _buildSettingsCard(
                theme,
                children: [
                  _buildSettingItem(
                    icon: CupertinoIcons.person,
                    title: 'Kişisel Bilgilerim',
                    theme: theme,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PersonalInfoPage(),
                      ),
                    ),
                  ),
                  _buildDivider(theme),
                  _buildSettingItem(
                    icon: CupertinoIcons.phone,
                    title: 'Bize Ulaşın',
                    theme: theme,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactPage()),
                    ),
                  ),
                  _buildDivider(theme),
                  _buildSettingItem(
                    icon: CupertinoIcons.chat_bubble,
                    title: 'Mesajlar (0)',
                    theme: theme,
                    onTap: () {
                      // Dummy implementation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Henüz yeni mesajınız yok.'),
                          backgroundColor: theme.surface,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Info Section
              _buildSectionTitle('HAKKINDA', theme),
              _buildSettingsCard(
                theme,
                children: [
                  _buildSettingItem(
                    icon: CupertinoIcons.question_circle,
                    title: 'Sıkça Sorulan Sorular',
                    theme: theme,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StaticContentPage(
                          title: 'Sıkça Sorulan Sorular',
                          contentId: 'faq',
                        ),
                      ),
                    ),
                  ),
                  _buildDivider(theme),
                  _buildSettingItem(
                    icon: CupertinoIcons.lock,
                    title: 'Gizlilik Politikası',
                    theme: theme,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StaticContentPage(
                          title: 'Gizlilik Politikası',
                          contentId: 'privacy',
                        ),
                      ),
                    ),
                  ),
                  _buildDivider(theme),
                  _buildSettingItem(
                    icon: CupertinoIcons.doc_text,
                    title: 'Kullanım Şartları',
                    theme: theme,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StaticContentPage(
                          title: 'Kullanım Şartları',
                          contentId: 'terms',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Developer Zone
              _buildSectionTitle('GELİŞTİRİCİ', theme),
              _buildSettingsCard(
                theme,
                children: [
                  _buildSettingItem(
                    icon: CupertinoIcons.cloud_upload,
                    title: 'Veritabanını Tohumla (Sorular)',
                    theme: theme,
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Tohumlama başladı...')),
                      );

                      try {
                        await seedDatabase(
                          ref.read(questionRepositoryProvider),
                        );
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Tohumlama tamamlandı!'),
                          ),
                        );
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('Hata: $e')),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Danger Zone
              _buildSectionTitle('GÜVENLİK', theme),
              _buildSettingsCard(
                theme,
                children: [
                  _buildSettingItem(
                    icon: CupertinoIcons.trash,
                    title: 'Verileri Temizle',
                    theme: theme,
                    onTap: () => _showClearDataDialog(context, ref, theme),
                  ),
                  _buildDivider(theme),
                  _buildSettingItem(
                    icon: CupertinoIcons.person_badge_minus,
                    title: 'Hesabımı Sil',
                    theme: theme,
                    isDestructive: true,
                    onTap: () => _showDeleteAccountDialog(context, ref, theme),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: theme.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(AppTheme theme, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required AppTheme theme,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? Colors.red.withValues(alpha: 0.1)
                      : theme.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDestructive ? Colors.red : theme.text,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDestructive ? Colors.red : theme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: theme.textSecondary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(AppTheme theme) {
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.divider.withValues(alpha: 0.5),
      indent: 60, // Align with text start
    );
  }

  void _showClearDataDialog(
    BuildContext context,
    WidgetRef ref,
    AppTheme theme,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text('Verileri Temizle?', style: TextStyle(color: theme.text)),
        content: Text(
          'Tüm çözdüğün soru istatistikleri ve ilerlemen silinecek. '
          'Ancak profil bilgilerin (isim, alan) korunacak. Emin misin?',
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', style: TextStyle(color: theme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(userProfileProvider.notifier).clearData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veriler temizlendi.')),
              );
            },
            child: const Text('Temizle', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    WidgetRef ref,
    AppTheme theme,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text(
          'Hesabımı Sil?',
          style: TextStyle(color: theme.text, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bu işlem geri alınamaz! Tüm verilerin, ayarların ve ilerlemen kalıcı olarak silinecek. '
          'Uygulama ilk haline dönecek.',
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Vazgeç', style: TextStyle(color: theme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.read(userProfileProvider.notifier).deleteAccount();
              // Navigate to initial state or restart app logic
              // Since we don't have a full auth flow reset, we just pop everything
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                ); // Assuming '/' is main
              }
            },
            child: const Text('SİL', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
