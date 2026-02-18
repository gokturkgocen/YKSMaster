import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../domain/models/user_model.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authRepo = ref.read(authRepositoryProvider);
        final user = await authRepo.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (user != null) {
          // Create user document in Firestore
          final userModel = UserModel(
            id: user.uid,
            email: user.email!,
            name: _nameController.text.trim(),
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(userModel.toMap());

          if (!mounted) return;
          Navigator.of(
            context,
          ).pop(); // Go back to login or let auth state handle it
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'İsim Soyisim'),
                validator: (value) =>
                    value != null && value.isNotEmpty ? null : 'İsim gerekli',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value != null && value.contains('@')
                    ? null
                    : 'Geçerli bir email girin',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true,
                validator: (value) => value != null && value.length >= 6
                    ? null
                    : 'En az 6 karakter gerekli',
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      child: const Text('Kayıt Ol'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
