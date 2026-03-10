import 'package:flutter/material.dart';
import 'package:my_app/admin/admin_teacher_page.dart';
import 'package:my_app/admin/admin_student_page.dart';
import 'package:my_app/pages/login_page.dart';
import 'package:my_app/components/button.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/config.dart';

class AdminApiService {
  static Future<Map<String, dynamic>> getJson(
    String endpoint, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint').replace(queryParameters: query);

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Server error');
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> fetchData({required String type}) async {
    return await getJson('admin_api.php', query: {'type': type});
  }
}

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final String userId = (args is Map && args['userId'] != null)
        ? args['userId'].toString()
        : '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;

            final double logoHeight =
    (screenHeight * 0.28).clamp(120.0, 260.0).toDouble();
            final buttonWidth = screenWidth > 600
                ? 350.0 // tablet
                : screenWidth * 0.7;

            return Column(
              children: [
                // ===== CONTENT =====
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 15),

                        // ===== LOGO =====
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/mainlogo.png',
                              height: logoHeight,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        // ===== BUTTON SECTION =====
                        SizedBox(
                          height: screenHeight * 0.35,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildRoleButton(
                                  text: 'นักศึกษา',
                                  width: buttonWidth,
                                  onPressed: () async {
                                    try {
                                      final json =
                                          await AdminApiService.fetchData(
                                            type: 'student_list',
                                          );

                                      if (json['success'] != true ||
                                          json['data'] == null) {
                                        throw Exception('โหลดข้อมูลไม่สำเร็จ');
                                      }

                                      final List<Map<String, dynamic>>
                                      studentList =
                                          List<Map<String, dynamic>>.from(
                                            json['data'],
                                          );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AdminStudentPage(
                                            data: studentList,
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  },
                                ),

                                const SizedBox(height: 30),

                                _buildRoleButton(
                                  text: 'อาจารย์',
                                  width: buttonWidth,
                                  onPressed: () async {
                                    try {
                                      final json =
                                          await AdminApiService.fetchData(
                                            type: 'teacher_list',
                                          );

                                      if (json['success'] != true ||
                                          json['data'] == null) {
                                        throw Exception('โหลดข้อมูลไม่สำเร็จ');
                                      }

                                      final List<Map<String, dynamic>>
                                      teacherList =
                                          List<Map<String, dynamic>>.from(
                                            json['data'],
                                          );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AdminTeacherPage(
                                            data: teacherList,
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== BOTTOM BAR =====
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFA6CAFA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                          text: 'ออกจากระบบ',
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          backgroundColor: const Color(0xFF84A9EA),
                          textColor: Colors.white,
                          fontSize: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String text,
    required VoidCallback onPressed,
    required double width,
  }) {
    return SizedBox(
    width: width,
    height: 55,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(
            color: Color(0xFF84A9EA),
            width: 1.5,
          ),
        ),
        shadowColor: Colors.grey,
        elevation: 3,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
  }
}
