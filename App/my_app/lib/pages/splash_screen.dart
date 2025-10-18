import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'login_page.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // รูปอยู่ด้านบน
          Image.asset(
            'assets/unicheck1.png',
            width: 300, // ลดขนาดลงหน่อย
          ),

          const SizedBox(height: 50), // เว้นระยะห่างจากรูปกับ animation

          // animation อยู่ด้านล่าง
          Lottie.asset(
            'assets/loader.json',
            width: 100,
            height: 100,
          ),
        ],
      ),
      nextScreen: const LoginPage(),
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      backgroundColor: Colors.white,
      splashIconSize: 400, // ขยายให้พอดีกับ Column
    );
  }
}
