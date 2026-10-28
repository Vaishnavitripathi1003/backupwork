import '../../domain/entities/sign_up_entity.dart';

class SignUpModel extends SignUpEntity {
  const SignUpModel({
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.mobile,
    required super.password,
    required super.otp,
    super.userType = 'daksh',
  });

  factory SignUpModel.fromJson(Map<String, dynamic> json) {
    return SignUpModel(
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      otp: json['otp']?.toString() ?? '',
      userType: json['userType']?.toString() ?? 'daksh',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobile': mobile,
      'password': password,
      'otp': otp,
      'userType': userType,
    };
  }

  factory SignUpModel.fromEntity(SignUpEntity entity) {
    return SignUpModel(
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      mobile: entity.mobile,
      password: entity.password,
      otp: entity.otp,
      userType: entity.userType,
    );
  }
}