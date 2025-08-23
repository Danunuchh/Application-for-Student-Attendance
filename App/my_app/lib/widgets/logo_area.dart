import 'package:flutter/material.dart';

class LogoArea extends StatelessWidget {
  final String assetPath;
  const LogoArea({
    super.key,
    this.assetPath = 'assets/images/unicheck_header.png', // แก้เป็นพาธรูปของคุณ
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Image.asset(
        assetPath,
        height: 210, // ปรับให้ใกล้ภาพ mock
        fit: BoxFit.contain,
      ),
    );
  }
}
