import 'dart:convert';

// ============================================================================
// SignUpResponse (Used for Login & Registration API responses)
// ============================================================================
class SignUpResponse {
  String? message;
  int? statusCode;
  String? token;
  SignUpResponseData? data;

  SignUpResponse({
    this.message,
    this.statusCode,
    this.token,
    this.data,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      message: json['message'] as String?,
      statusCode: json['status_code'] as int?,
      token: json['token'] as String?,
      data: json['data'] != null
          ? SignUpResponseData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status_code': statusCode,
      'token': token,
      'data': data?.toJson(),
    };
  }
}

// ============================================================================
// SignUpResponseData (Holds Admin / User Profile Details)
// ============================================================================
class SignUpResponseData {
  String? id;
  String? subscriptionLevel;
  String? userType;
  String? role;
  bool? status;
  bool? isChecked;
  String? firstName;
  String? lastName;
  String? email;
  String? profileImage;
  String? mobile;
  String? password;
  String? createdAt;
  String? updatedAt;
  int? v;

  SignUpResponseData({
    this.id,
    this.subscriptionLevel,
    this.userType,
    this.role,
    this.status,
    this.isChecked,
    this.firstName,
    this.lastName,
    this.email,
    this.profileImage,
    this.mobile,
    this.password,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory SignUpResponseData.fromJson(Map<String, dynamic> json) {
    return SignUpResponseData(
      id: json['_id'] as String?,
      subscriptionLevel: json['subscriptionLevel'] as String?,
      userType: json['userType'] as String?,
      role: json['role'] as String?,
      status: json['status'] as bool?,
      isChecked: json['isChecked'] as bool?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      profileImage: json['profileImage'] as String?,
      mobile: json['mobile'] as String?,
      password: json['password'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      v: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'subscriptionLevel': subscriptionLevel,
      'userType': userType,
      'role': role,
      'status': status,
      'isChecked': isChecked,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profileImage': profileImage,
      'mobile': mobile,
      'password': password,
      'created_at': createdAt,
      'updated_at': updatedAt,
      '__v': v,
    };
  }
}

// ============================================================================
// SignUpResponse2 (Used for /findAdminByLoginId API response)
// ============================================================================
class SignUpResponse2 {
  String? message;
  int? statusCode;
  String? token;
  SignUpResponseData? data;

  SignUpResponse2({
    this.message,
    this.statusCode,
    this.token,
    this.data,
  });

  factory SignUpResponse2.fromJson(Map<String, dynamic> json) {
    return SignUpResponse2(
      message: json['message'] as String?,
      statusCode: json['status_code'] as int?,
      token: json['token'] as String?,
      data: json['admin'] != null
          ? SignUpResponseData.fromJson(json['admin'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status_code': statusCode,
      'token': token,
      'admin': data?.toJson(),
    };
  }
}