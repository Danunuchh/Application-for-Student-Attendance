import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerPage extends StatelessWidget {
  final String url;

  const PdfViewerPage({super.key, required this.url});

  Future<void> _openPdf() async {
    final uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('ไม่สามารถเปิด PDF ได้');
    }
  }

  @override
  Widget build(BuildContext context) {
    _openPdf();

    return Scaffold(
      appBar: const CustomAppBar(title: 'ดูเอกสาร'),
      body: const Center(
        child: Text('กำลังเปิดเอกสาร...'),
      ),
    );
  }
}
