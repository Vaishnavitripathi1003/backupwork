class SignUpRequestModel {
  final String firstName;
  final String lastName;
  final String mobile;
  final String password;
  final String otp;

  SignUpRequestModel({
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.password,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'mobile': mobile,
        'password': password,
        'otp': otp,
      };
}

class PasswordResetRequestModel {
  final String password;
  final String otp;
  final String token;

  PasswordResetRequestModel({
    required this.password,
    required this.otp,
    required this.token,
  });

  Map<String, dynamic> toJson() => {
        'password': password,
        'otp': otp,
        'token': token,
      };
}

class CreateUserDataRequestModel {
  final String firstName;
  final String? lastName;
  final String? mobile;
  final String? dataName;

  CreateUserDataRequestModel({
    required this.firstName,
    this.lastName,
    this.mobile,
    this.dataName,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (mobile != null) 'mobile': mobile,
        if (dataName != null) 'dataName': dataName,
      };
}

class FingerprintPatternData {
  final String? fingerprintPattern;
  final String? patternCode;
  final int ridgeCount;
  final String? xPatternType;
  final String? xCode;
  final int? xCount;

  FingerprintPatternData({
    this.fingerprintPattern,
    this.patternCode,
    required this.ridgeCount,
    this.xPatternType,
    this.xCode,
    this.xCount,
  });

  Map<String, dynamic> toJson() => {
        if (fingerprintPattern != null)
          'fingerprint_pattern': fingerprintPattern,
        if (patternCode != null) 'pattern_code': patternCode,
        'ridge_count': ridgeCount,
        if (xPatternType != null) 'x_pattern_type': xPatternType,
        if (xCode != null) 'x_code': xCode,
        if (xCount != null) 'x_count': xCount,
      };
}

class CreateReportRequestModel {
  final String userDataId;
  final bool isNotificationSend;

  CreateReportRequestModel({
    required this.userDataId,
    this.isNotificationSend = false,
  });

  Map<String, dynamic> toJson() => {
        'userDataId': userDataId,
        'isNotificationSend': isNotificationSend,
      };
}

class UpdateFirebaseTokenRequestModel {
  final String token;

  UpdateFirebaseTokenRequestModel({required this.token});

  Map<String, dynamic> toJson() => {
        'token': token,
      };
}
