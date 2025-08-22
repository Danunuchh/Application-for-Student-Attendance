import 'package:flutter/material.dart';
import 'book_icon.dart';

class LogoArea extends StatelessWidget {
  const LogoArea({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const SizedBox(height: 110),
          ),
          Positioned(
            right: 26,
            top: 10,
            child: BookIcon(coverColor: cs.primary, pageColor: Colors.white),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Uni",
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
                ),
                Text(
                  "Check",
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
