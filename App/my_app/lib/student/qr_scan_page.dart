import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
// --------- ถ้าจะเปิดสแกนจริง ให้เอาคอมเมนต์ด้านล่างออก และเพิ่ม dependency ใน pubspec.yaml ---------
// dependencies:
//   mobile_scanner: ^6.0.2   // (หรือเวอร์ชันล่าสุด)
// import 'package:mobile_scanner/mobile_scanner.dart';
// -------------------------------------------------------------------------------------------------

class QRScanPage extends StatelessWidget {
  const QRScanPage({super.key});

  // สีฟ้าอ่อนตามตัวอย่าง
  static const Color _blue = Color(0xFFA6CAFA);

  @override
  Widget build(BuildContext context) {
    // ======== โหมด UI อย่างเดียว (ยังไม่เปิดกล้อง) ========
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: ''),
      body: LayoutBuilder(
        builder: (context, c) {
          final double boxSize = c.maxWidth * 0.74; // กรอบ ~3/4 ของความกว้าง
          final double topSpacing = c.maxHeight * 0.10; // ระยะจากบนลงมาให้โปร่ง

          return Column(
            children: [
              SizedBox(height: topSpacing),
              Center(
                child: SizedBox(
                  width: boxSize,
                  height: boxSize,
                  child: CustomPaint(
                    painter: _ScanFramePainter(
                      color: _blue,
                      cornerStroke: 9, // ความหนาเส้นตามมุม
                      laserStroke: 6, // ความหนาเส้นกลาง
                      cornerLen: 54, // ความยาวแขนมุม
                      inset: 18, // ระยะห่างจากขอบกรอบ
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),

      // ======== (ทางเลือก) เปิดกล้องสแกนจริง — คอมเมนต์ไว้ให้พร้อมใช้งาน ========
      /*
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1) พื้นหลังเป็นกล้อง
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
              facing: CameraFacing.back,
              torchEnabled: false,
            ),
            onDetect: (capture) {
              final codes = capture.barcodes;
              if (codes.isNotEmpty) {
                final value = codes.first.rawValue;
                if (value != null) {
                  // TODO: ทำสิ่งที่ต้องการเมื่อสแกนสำเร็จ เช่น:
                  // Navigator.pop(context, value);
                }
              }
            },
          ),
          // 2) วาดกรอบทับกล้อง
          IgnorePointer(
            child: LayoutBuilder(
              builder: (context, c) {
                final double boxSize = c.maxWidth * 0.74;
                final double topSpacing = c.maxHeight * 0.10;
                return Column(
                  children: [
                    SizedBox(height: topSpacing),
                    Center(
                      child: SizedBox(
                        width: boxSize,
                        height: boxSize,
                        child: CustomPaint(
                          painter: _ScanFramePainter(
                            color: _blue,
                            cornerStroke: 9,
                            laserStroke: 6,
                            cornerLen: 54,
                            inset: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      */
    );
  }
}

/// วาดมุม L ทั้งสี่ + เส้นแนวนอนกลาง ให้โทนเดียวกับภาพตัวอย่าง
class _ScanFramePainter extends CustomPainter {
  final Color color;
  final double cornerStroke; // ความหนามุม
  final double laserStroke; // ความหนาเส้นกลาง
  final double cornerLen; // ความยาวแขนมุม
  final double inset; // ระยะร่นจากขอบกรอบ

  _ScanFramePainter({
    required this.color,
    required this.cornerStroke,
    required this.laserStroke,
    required this.cornerLen,
    required this.inset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pCorner = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerStroke
      ..strokeCap = StrokeCap.round;

    final Paint pLaser = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = laserStroke
      ..strokeCap = StrokeCap.round;

    final double w = size.width;
    final double h = size.height;

    // กำหนดจุดอ้างอิง (ล-ซ้าย, ข-ขวา, บ-บน, ล่-ล่าง)
    final double l = inset;
    final double r = w - inset;
    final double t = inset;
    final double b = h - inset;

    // helper วาดแขนมุม (แนวนอน + แนวตั้ง) ด้วยปลายมน
    void drawCorner({
      required Offset hStart,
      required bool toRight, // แนวนอน: true=ขวา, false=ซ้าย
      required Offset vStart,
      required bool toDown, // แนวตั้ง: true=ลง, false=ขึ้น
    }) {
      // แนวนอน
      canvas.drawLine(
        hStart,
        hStart + Offset(toRight ? cornerLen : -cornerLen, 0),
        pCorner,
      );
      // แนวตั้ง
      canvas.drawLine(
        vStart,
        vStart + Offset(0, toDown ? cornerLen : -cornerLen),
        pCorner,
      );
    }

    // มุมซ้ายบน
    drawCorner(
      hStart: Offset(l, t),
      toRight: true,
      vStart: Offset(l, t),
      toDown: true,
    );
    // มุมขวาบน
    drawCorner(
      hStart: Offset(r, t),
      toRight: false,
      vStart: Offset(r, t),
      toDown: true,
    );
    // มุมซ้ายล่าง
    drawCorner(
      hStart: Offset(l, b),
      toRight: true,
      vStart: Offset(l, b),
      toDown: false,
    );
    // มุมขวาล่าง
    drawCorner(
      hStart: Offset(r, b),
      toRight: false,
      vStart: Offset(r, b),
      toDown: false,
    );

    // เส้นเลเซอร์ตรงกลาง (แนวนอน)
    final double midY = h / 2;
    canvas.drawLine(Offset(l, midY), Offset(r, midY), pLaser);
  }

  @override
  bool shouldRepaint(covariant _ScanFramePainter old) {
    return color != old.color ||
        cornerStroke != old.cornerStroke ||
        laserStroke != old.laserStroke ||
        cornerLen != old.cornerLen ||
        inset != old.inset;
  }
}
