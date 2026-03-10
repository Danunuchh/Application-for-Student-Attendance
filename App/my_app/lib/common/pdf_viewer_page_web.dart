import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'dart:html' as html;

class PdfViewerPage extends StatelessWidget {
  final String url;

  const PdfViewerPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    html.window.open(url, '_blank');

    return Scaffold(
      appBar: const CustomAppBar(title: 'ดูเอกสาร'),
      body: const Center(
        child: Text('กำลังเปิดเอกสารในแท็บใหม่...'),
      ),
    );
  }
}
