import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class ContactPage extends ConsumerStatefulWidget {
  const ContactPage({super.key});

  @override
  ConsumerState<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends ConsumerState<ContactPage> {
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
      );
      return;
    }

    // Dummy send action
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mesajınız alındı! En kısa sürede döneceğiz.'),
          backgroundColor: Colors.green,
        ),
      );
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
          'Bize Ulaşın',
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
              Text(
                'Görüş, öneri veya şikayetlerinizi bizimle paylaşın.',
                style: TextStyle(color: theme.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Email Field
              Text(
                'E-POSTA ADRESİNİZ',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: TextStyle(color: theme.text),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'ornek@email.com',
                  hintStyle: TextStyle(
                    color: theme.textSecondary.withValues(alpha: 0.5),
                  ),
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

              // Message Field
              Text(
                'MESAJINIZ',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                style: TextStyle(color: theme.text),
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Buraya yazın...',
                  hintStyle: TextStyle(
                    color: theme.textSecondary.withValues(alpha: 0.5),
                  ),
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

              const Spacer(),

              // Send Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sendMessage,
                  icon: const Icon(
                    CupertinoIcons.paperplane_fill,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'GÖNDER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
