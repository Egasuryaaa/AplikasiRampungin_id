import 'package:flutter/material.dart';
import 'Auth_screens/welcome.dart';
import 'Auth_screens/login.dart';
import 'package:rampungin_id_userside/Auth_screens/register.dart';
import 'client_screens/detail/topup_screen.dart';
import 'tukang_screens/form/form_tukang.dart';
import 'client_screens/Widgets/bottom_navigation.dart';
import 'client_screens/detail/notification.dart';
import 'tukang_screens/detail/notification_tk.dart';
import 'tukang_screens/tukang_main.dart';
import 'client_screens/detail/detail_order.dart';
import 'tukang_screens/detail/edit_profile.dart';
import 'tukang_screens/detail/ubahpassword.dart';
import 'tukang_screens/content_bottom/profile.dart';
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
      initialRoute: '/',
      routes: {
        '/': (context) => const Welcome(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const Register(),
        '/formtukang': (context) => const FormTukang(),
        
        // Main screen dengan bottom navigation
        '/HomeScreen': (context) => const BottomNavigation(currentIndex: 0),
        
        // Other screens
        '/TopUpScreen': (context) => const TopUpScreen(),
        '/tukang_main': (context) => const TukangMain(),
        '/detail_order': (context) => DetailOrder(technicianData: {}),
        '/profile': (context) => const Profile(),
        '/notification': (context) => const NotificationScreen(),
        '/edit_profile': (context) => const EditProfile(),
        '/ubahpassword': (context) => const UbahPassword(),
        '/notification_tk': (context) => const Notificationtk(),
        '/setting': (context) => Setting(),
      },
    );
  }
}