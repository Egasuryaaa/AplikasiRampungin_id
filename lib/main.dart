import 'package:flutter/material.dart';
import 'Auth_screens/welcome.dart';
import 'Auth_screens/login.dart';
import 'package:rampungin_id_userside/Auth_screens/register.dart';
import 'client_screens/content_bottom/home_screen.dart';
import 'client_screens/client_screen.dart';
import 'client_screens/content_bottom/topup_screen.dart';
import 'tukang_screens/form/form_tukang.dart';
import 'client_screens/Widgets/bottom_navigation.dart';
import 'client_screens/detail/notification.dart';
import 'tukang_screens/detail/notification_tk.dart';
import 'tukang_screens/tukang_main.dart';
import 'client_screens/detail/detail_order.dart';
import 'client_screens/detail/profile_screen.dart';
import 'tukang_screens/detail/profile.dart';
import 'client_screens/detail/setting.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // halaman pertama
      routes: {
        '/': (context) => const Welcome(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const Register(),
        '/formtukang': (context) => const FormTukang(),
        '/HomeScreen': (context) => const HomeScreen(),
        '/TopUpScreen': (context) => const TopUpScreen(),
        '/bottom_navigation': (context) => const BottomNavigation(),
        '/tukang_main': (context) => const TukangMain(),
        '/detail_order': (context) => DetailOrder(technicianData: {}),
        '/profile': (context) => const Profile(),
        '/profile_screen': (context) => ProfileScreen(),
        '/notification': (context) => const NotificationScreen(),
        '/notification_tk': (context) => const Notificationtk(),
        '/client_screen': (context) => const ClientScreen(),
        '/setting': (context) => Setting(),
      },
    );
  }
}
