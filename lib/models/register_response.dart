class RegisterResponse {
  final String status;
  final String message;
  final RegisterData? data;

  RegisterResponse({required this.status, required this.message, this.data});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? 'Unknown error',
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
    );
  }

  bool get isSuccess => status == 'success';
}

class RegisterData {
  final int userId;
  final String username;
  final String email;
  final String role;
  final String? fotoProfil;
  final bool isVerified;

  RegisterData({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    this.fotoProfil,
    required this.isVerified,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      userId: json['user_id'] ?? json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      fotoProfil: json['foto_profil'],
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'role': role,
      'foto_profil': fotoProfil,
      'is_verified': isVerified,
    };
  }
}
