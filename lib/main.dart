import 'package:flutter/material.dart';
import 'client_screens/Widgets/welcome.dart';
import 'Auth_screens/login.dart';
import 'client_screens/content_bottom/home_screen.dart';
import 'client_screens/content_bottom/payment_screen.dart';
import 'client_screens/content_bottom/chat_screen.dart';
import 'tukang_screens/form/form_tukang.dart';
import 'client_screens/Widgets/bottom_navigation.dart';
import 'tukang_screens/main_container.dart';
import 'client_screens/detail/detail_order.dart';
import 'tukang_screens/detail/profile.dart';
import 'tukang_screens/detail/notification.dart';
import 'tukang_screens/detail/setting.dart';

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
        '/formtukang': (context) => const FormTukang(),
        '/HomeScreen': (context) => const HomeScreen(),
        '/ChatScreen': (context) => const ChatScreen(),
        '/PaymentScreen': (context) => const PaymentScreen(),
        '/bottom_navigation': (context) => const BottomNavigation(),
        '/main_container': (context) => const MainContainer(),
        '/detail_order': (context) => DetailOrder(technicianData: {}),
        '/profile': (context) => Profile(),
        '/notification': (context) => const NotificationScreen(),
        '/setting': (context) => Setting(),
      },
    );
  }
}
