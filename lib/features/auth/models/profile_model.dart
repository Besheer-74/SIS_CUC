class ProfileModel {
  final String id;
  final String role;
  final String? email;
  final String? fullName;
  final String? fullNameAr;

  ProfileModel({
    required this.id,
    required this.role,
    this.email,
    this.fullName,
    this.fullNameAr,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      role: json['role'],
      email: json['email'],
      fullName: json['full_name'],
      fullNameAr: json['full_name_ar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'full_name': fullName,
      'email': email,
      'full_name_ar': fullNameAr,
    };
  }
}
