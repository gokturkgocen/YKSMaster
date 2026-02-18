import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_profile_provider.dart';

class PersonalInfoPage extends ConsumerStatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  ConsumerState<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends ConsumerState<PersonalInfoPage> {
  late TextEditingController _nameController;
  late Branch? _selectedBranch;

  @override
  void initState() {
    super.initState();
    final userProfile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: userProfile.name);
    _selectedBranch = userProfile.selectedBranch;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final notifier = ref.read(userProfileProvider.notifier);

    if (_nameController.text.isNotEmpty) {
      await notifier.updateName(_nameController.text);
    }

    if (_selectedBranch != null &&
        _selectedBranch != ref.read(userProfileProvider).selectedBranch) {
      await notifier.selectBranch(_selectedBranch!);
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bilgiler güncellendi.')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'Kişisel Bilgilerim',
          style: TextStyle(color: theme.text, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.surface,
        iconTheme: IconThemeData(color: theme.text),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, size: 60, color: theme.accent),
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              Text(
                'AD SOYAD',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: TextStyle(color: theme.text),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Branch Selection
              Text(
                'ALAN',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: Branch.values.map((branch) {
                    final isSelected = _selectedBranch == branch;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedBranch = branch;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: isSelected
                                    ? theme.accent
                                    : theme.textSecondary,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                branch.displayName,
                                style: TextStyle(
                                  color: theme.text,
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const Spacer(),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'KAYDET',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
