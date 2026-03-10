import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';

class ImageViewerPage extends StatelessWidget {
  final String url;

  const ImageViewerPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'ดูรูปภาพ'),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
