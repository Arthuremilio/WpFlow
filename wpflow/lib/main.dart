import 'package:wpflow/features/home/data/home_user.dart';
import 'package:flutter/material.dart';
import 'package:wpflow/features/message/data/send_buck_message_excel.dart';
import 'package:wpflow/features/message/data/send_message.dart';
import 'package:wpflow/features/wpp_session/controllers/session_manager.dart';
import 'package:wpflow/features/message/presentation/buck_message_excel.dart';
import 'features/auth/data/auth.dart';
import 'features/home/presentation/home_principal.dart';
import 'features/auth/presentation/auth_page.dart';
import 'features/home/presentation/home_user_page.dart';
import 'core/routes/app-routes.dart';
import 'package:provider/provider.dart';
import 'settings/presentation/settings_page.dart';
import 'features/auth/presentation/forgot_password_page.dart';
import 'features/message/presentation/simple_message.dart';
import 'core/utils/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => SessionManagerProvider()),
        ChangeNotifierProvider(create: (_) => SendMessageProvider()),
        ChangeNotifierProvider(create: (_) => SendBuckMessageExcelProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WpFlow',
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF000000),
            secondary: const Color(0xFF00c95E),
            surface: const Color(0xFF171717),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF000000)),
            bodyMedium: TextStyle(color: Color(0xFFF5F5F5)),
            bodySmall: TextStyle(color: Color(0xFFF5F5F5)),
          ),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.HOME,
        routes: {
          AppRoutes.HOME: (ctx) => const HomePrincipal(),
          AppRoutes.AUTH: (ctx) => const AuthPage(),
          AppRoutes.HOMEUSER: (ctx) => const HomeUserPage(),
          AppRoutes.FORGOT_PASSWORD: (ctx) => ForgotPasswordPage(),
          AppRoutes.SETTINGS: (ctx) => const SettingsPage(),
          AppRoutes.SIMPLE_MESSAGE: (ctx) => const SimpleMessagePage(),
          AppRoutes.BUCK_MESSAGE_EXCEL: (ctx) => const BuckMessageExcel(),
        },
      ),
    );
  }
}
