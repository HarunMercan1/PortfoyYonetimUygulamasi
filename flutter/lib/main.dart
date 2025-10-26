import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'screens/main_page.dart';
import 'screens/auth/login_screen.dart'; // 👈 login sayfasını ekledik

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 🔐 Token kontrolü (kullanıcı giriş yapmış mı?)
  Future<bool> _isLoggedIn() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Portföy Yönetim Sistemi',
      themeMode: ThemeMode.dark,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (context, snapshot) {
          // Henüz sonuç gelmediyse loading spinner
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Token varsa MainPage, yoksa LoginScreen
          return snapshot.data! ? const MainPage() : const LoginScreen();
        },
      ),
    );
  }
}
