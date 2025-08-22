import 'package:flutter/material.dart';

class BookIcon extends StatelessWidget {
  final Color coverColor;
  final Color pageColor;
  const BookIcon({
    super.key,
    required this.coverColor,
    required this.pageColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 64,
      child: Stack(
        children: [
          Positioned(
            left: 14,
            top: 18,
            child: _book(coverColor.withOpacity(0.9)),
          ),
          Positioned(left: 0, top: 0, child: _book(coverColor)),
        ],
      ),
    );
  }

  Widget _book(Color cover) {
    return Container(
      width: 58,
      height: 42,
      decoration: BoxDecoration(
        color: pageColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black12),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 16,
              decoration: BoxDecoration(
                color: cover,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
