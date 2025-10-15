// lib/models/user_profile.dart
class UserProfile {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String address;

  // เฉพาะนักศึกษาอาจมี
  final String? studentId;

  // เฉพาะอาจารย์อาจมี
  final String? teacherCode;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
    this.studentId,
    this.teacherCode,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: (json['id'] ?? '').toString(),
    username: (json['username'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    firstName: (json['firstName'] ?? '').toString(),
    lastName: (json['lastName'] ?? '').toString(),
    phone: (json['phone'] ?? '').toString(),
    address: (json['address'] ?? '').toString(),
    studentId: json['studentId']?.toString(),
    teacherCode: json['teacherCode']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'address': address,
    if (studentId != null) 'studentId': studentId,
    if (teacherCode != null) 'teacherCode': teacherCode,
  };
}
