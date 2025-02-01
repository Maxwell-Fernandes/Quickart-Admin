import 'package:admin_quickart/pages/unauthorized_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:admin_quickart/pages/login_page.dart';
import 'package:admin_quickart/pages/dashboard_page.dart';
import 'package:admin_quickart/theme/color_theme.dart';
import 'package:provider/provider.dart';
import 'package:admin_quickart/services/auth_service.dart';
import 'package:admin_quickart/services/product_service.dart';
import 'package:admin_quickart/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    checkAdminStatus();
  }

  void checkAdminStatus() {
    FirebaseAuth.instance.currentUser?.getIdTokenResult().then((idTokenResult) {
      print('Admin claim: ${idTokenResult.claims?['admin']}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ProductService()),
      ],
      child: MaterialApp(
        title: 'Quickart Admin',
        theme: AppTheme.themeData,
        home: Consumer<AuthService>(
          builder: (context, authService, _) {
            if (authService.currentUser == null) {
              return const LoginPage();
            } else if (authService.isAdmin()) {
              return const DashboardPage();
            } else {
              return const UnauthorizedPage();
            }
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
