import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/user_profile_provider.dart';
import 'main_screen.dart';

/// Branch selection screen shown on first launch
class BranchSelectionPage extends ConsumerWidget {
  const BranchSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final nicknameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                'Branşını Seç',
                style: TextStyle(
                  color: theme.text,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'YKS\'de hangi alanda sınava gireceksin?',
                style: TextStyle(color: theme.textSecondary, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Nickname Input
              Form(
                key: formKey,
                child: SizedBox(
                  width: 400,
                  child: TextFormField(
                    controller: nicknameController,
                    style: TextStyle(color: theme.text),
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı Adın',
                      labelStyle: TextStyle(color: theme.textSecondary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: const Color(0xFF3B82F6)),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Lütfen bir isim belirle'
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Branch cards
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _BranchCard(
                      branch: Branch.sayisal,
                      icon: CupertinoIcons.function,
                      color: const Color(0xFF3B82F6),
                      theme: theme,
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          _selectBranch(
                            context,
                            ref,
                            Branch.sayisal,
                            nicknameController.text,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _BranchCard(
                      branch: Branch.ea,
                      icon: CupertinoIcons.equal_square,
                      color: const Color(0xFF8B5CF6),
                      theme: theme,
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          _selectBranch(
                            context,
                            ref,
                            Branch.ea,
                            nicknameController.text,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _BranchCard(
                      branch: Branch.sozel,
                      icon: CupertinoIcons.book_fill,
                      color: const Color(0xFFF59E0B),
                      theme: theme,
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          _selectBranch(
                            context,
                            ref,
                            Branch.sozel,
                            nicknameController.text,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectBranch(
    BuildContext context,
    WidgetRef ref,
    Branch branch,
    String nickname,
  ) async {
    await ref.read(userProfileProvider.notifier).updateName(nickname);
    await ref.read(userProfileProvider.notifier).selectBranch(branch);
    if (context.mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }
}

class _BranchCard extends StatelessWidget {
  final Branch branch;
  final IconData icon;
  final Color color;
  final AppTheme theme;
  final VoidCallback onTap;

  const _BranchCard({
    required this.branch,
    required this.icon,
    required this.color,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.divider.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.displayName,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getSubjectsText(branch),
                    style: TextStyle(color: theme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: theme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _getSubjectsText(Branch branch) {
    switch (branch) {
      case Branch.sayisal:
        return 'Matematik, Fen Bilimleri';
      case Branch.ea:
        return 'Matematik, Türk Dili, Sosyal';
      case Branch.sozel:
        return 'Türk Dili, Tarih, Coğrafya';
    }
  }
}
