import 'package:flutter/material.dart';
import '../../data/api/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final res = await ApiService.register(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Kayıt başarılı ✅')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt hatası: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Text('Kayıt Ol', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 30),

              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Ad Soyad'),
                validator: (v) => v!.isEmpty ? 'Bu alan zorunlu' : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'E-posta'),
                validator: (v) => v!.isEmpty ? 'Bu alan zorunlu' : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Şifre'),
                validator: (v) => v!.length < 4 ? 'En az 4 karakter' : null,
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _loading ? null : _register,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: Text(_loading ? 'Kaydediliyor...' : 'Kayıt Ol'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text('Zaten hesabın var mı? Giriş Yap'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );

  }
}
