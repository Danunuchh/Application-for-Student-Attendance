import 'package:flutter/material.dart';
import '../models/course.dart';
import '../teacher/course_card.dart';

class CourseHistoryPage extends StatelessWidget {
  const CourseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'ประวัติการเข้าเรียน',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: mockCourses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final course = mockCourses[i];
          return CourseCard(
            course: course,
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('เลือก ${course.name}')));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {},
        child: const Icon(Icons.qr_code_rounded, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home_rounded),
                onPressed: () {},
              ),
              const SizedBox(width: 48),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
