// ============================================================================
// FingerScanResponse Model Class (Returned by POST /fingerprintscan)
// ============================================================================
class FingerScanResponse {
  String? message;
  int? statusCode;
  User? data;

  FingerScanResponse({
    this.message,
    this.statusCode,
    this.data,
  });

  factory FingerScanResponse.fromJson(Map<String, dynamic> json) {
    return FingerScanResponse(
      message: json['message'] as String?,
      statusCode: json['status_code'] as int? ?? json['statusCode'] as int?,
      data: json['data'] != null
          ? User.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status_code': statusCode,
      'data': data?.toJson(),
    };
  }
}

// ============================================================================
// CandidateListResponse Model Class (Returned by GET /findFingerprintscanByAdmin)
// ============================================================================
class CandidateListResponse {
  String? message;
  int? statusCode;
  List<User>? data;

  CandidateListResponse({
    this.message,
    this.statusCode,
    this.data,
  });

  factory CandidateListResponse.fromJson(Map<String, dynamic> json) {
    return CandidateListResponse(
      message: json['message'] as String?,
      statusCode: json['status_code'] as int? ?? json['statusCode'] as int?,
      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List)
              .map((item) => User.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status_code': statusCode,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

// ============================================================================
// User Model Class (Candidate Profile)
// ============================================================================
/*class User {
  String adminId;
  String id;
  String? dataName;
  String? firstName;
  String? lastName;
  String? fatherName;
  String? email;
  String? mobile;
  String? studdingClass;
  String? dob;
  bool isReportGenerated;
  String? reportUpdatedAt;

  // Finger Data Objects for 10 fingers
  FingerData? fingerLeftThumb;
  FingerData? fingerLeftIndex;
  FingerData? fingerLeftMiddle;
  FingerData? fingerLeftRing;
  FingerData? fingerLeftLittle;
  FingerData? fingerRightThumb;
  FingerData? fingerRightIndex;
  FingerData? fingerRightMiddle;
  FingerData? fingerRightRing;
  FingerData? fingerRightLittle;

  bool? isChecked;
  bool? isComplete;
  bool? status;
  bool? isSubmitted;
  String? address1;
  String? address2;
  String? landmark;
  String? city;
  String? state;
  String? country;
  String? pinCode;
  String? profileImage;
  String? profileImageName;
  String? createdAt;
  String? updatedAt;

  User({
    required this.adminId,
    required this.id,
    this.dataName,
    this.firstName,
    this.lastName,
    this.fatherName,
    this.email,
    this.mobile,
    this.studdingClass,
    this.dob,
    this.isReportGenerated = false,
    this.reportUpdatedAt,
    this.fingerLeftThumb,
    this.fingerLeftIndex,
    this.fingerLeftMiddle,
    this.fingerLeftRing,
    this.fingerLeftLittle,
    this.fingerRightThumb,
    this.fingerRightIndex,
    this.fingerRightMiddle,
    this.fingerRightRing,
    this.fingerRightLittle,
    this.isChecked,
    this.isComplete,
    this.status,
    this.address1,
    this.address2,
    this.landmark,
    this.city,
    this.state,
    this.country,
    this.pinCode,
    this.profileImage,
    this.profileImageName,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      adminId: json['adminId'] as String? ?? '',
      id: json['_id'] as String? ?? json['userId'] as String? ?? '',
      dataName: json['dataName'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      fatherName: json['father_name'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      studdingClass: json['class'] as String?,
      dob: json['dob'] as String?,
      isReportGenerated: json['isReportGenerated'] as bool? ?? false,
      reportUpdatedAt: json['report_updated_at'] as String?,

      fingerLeftThumb: json['fingerLeftThumb'] != null
          ? FingerData.fromJson(json['fingerLeftThumb'] as Map<String, dynamic>)
          : null,
      fingerLeftIndex: json['fingerLeftIndex'] != null
          ? FingerData.fromJson(json['fingerLeftIndex'] as Map<String, dynamic>)
          : null,
      fingerLeftMiddle: json['fingerLeftMiddle'] != null
          ? FingerData.fromJson(json['fingerLeftMiddle'] as Map<String, dynamic>)
          : null,
      fingerLeftRing: json['fingerLeftRing'] != null
          ? FingerData.fromJson(json['fingerLeftRing'] as Map<String, dynamic>)
          : null,
      fingerLeftLittle: json['fingerLeftLittle'] != null
          ? FingerData.fromJson(json['fingerLeftLittle'] as Map<String, dynamic>)
          : null,
      fingerRightThumb: json['fingerRightThumb'] != null
          ? FingerData.fromJson(json['fingerRightThumb'] as Map<String, dynamic>)
          : null,
      fingerRightIndex: json['fingerRightIndex'] != null
          ? FingerData.fromJson(json['fingerRightIndex'] as Map<String, dynamic>)
          : null,
      fingerRightMiddle: json['fingerRightMiddle'] != null
          ? FingerData.fromJson(json['fingerRightMiddle'] as Map<String, dynamic>)
          : null,
      fingerRightRing: json['fingerRightRing'] != null
          ? FingerData.fromJson(json['fingerRightRing'] as Map<String, dynamic>)
          : null,
      fingerRightLittle: json['fingerRightLittle'] != null
          ? FingerData.fromJson(json['fingerRightLittle'] as Map<String, dynamic>)
          : null,

      isChecked: json['isChecked'] as bool?,
      isComplete: json['isComplete'] as bool?,
      status: json['status'] as bool?,
      address1: json['address1'] as String?,
      address2: json['address2'] as String?,
      landmark: json['landmark'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      pinCode: json['pincode'] as String?,
      profileImage: json['profileImage'] as String?,
      profileImageName: json['profileImageName'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adminId': adminId,
      '_id': id,
      'dataName': dataName,
      'firstName': firstName,
      'lastName': lastName,
      'father_name': fatherName,
      'email': email,
      'mobile': mobile,
      'class': studdingClass,
      'dob': dob,
      'isReportGenerated': isReportGenerated,
      'report_updated_at': reportUpdatedAt,

      'fingerLeftThumb': fingerLeftThumb?.toJson(),
      'fingerLeftIndex': fingerLeftIndex?.toJson(),
      'fingerLeftMiddle': fingerLeftMiddle?.toJson(),
      'fingerLeftRing': fingerLeftRing?.toJson(),
      'fingerLeftLittle': fingerLeftLittle?.toJson(),
      'fingerRightThumb': fingerRightThumb?.toJson(),
      'fingerRightIndex': fingerRightIndex?.toJson(),
      'fingerRightMiddle': fingerRightMiddle?.toJson(),
      'fingerRightRing': fingerRightRing?.toJson(),
      'fingerRightLittle': fingerRightLittle?.toJson(),

      'isChecked': isChecked,
      'isComplete': isComplete,
      'status': status,
      'address1': address1,
      'address2': address2,
      'landmark': landmark,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pinCode,
      'profileImage': profileImage,
      'profileImageName': profileImageName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}*/
class User {
  String adminId;
  String id;
  String? dataName;
  String? firstName;
  String? lastName;
  String? fatherName;
  String? email;
  String? mobile;
  String? studdingClass;
  String? dob;

  bool isReportGenerated;
  String? reportUpdatedAt;

  // Finger Data Objects for 10 fingers
  FingerData? fingerLeftThumb;
  FingerData? fingerLeftIndex;
  FingerData? fingerLeftMiddle;
  FingerData? fingerLeftRing;
  FingerData? fingerLeftLittle;
  FingerData? fingerRightThumb;
  FingerData? fingerRightIndex;
  FingerData? fingerRightMiddle;
  FingerData? fingerRightRing;
  FingerData? fingerRightLittle;

  bool? isChecked;
  bool? isComplete;
  bool? status;

  // New field - default false
  bool isSubmitted;

  String? address1;
  String? address2;
  String? landmark;
  String? city;
  String? state;
  String? country;
  String? pinCode;
  String? profileImage;
  String? profileImageName;
  String? createdAt;
  String? updatedAt;

  User({
    required this.adminId,
    required this.id,
    this.dataName,
    this.firstName,
    this.lastName,
    this.fatherName,
    this.email,
    this.mobile,
    this.studdingClass,
    this.dob,
    this.isReportGenerated = false,
    this.reportUpdatedAt,

    // Finger Data
    this.fingerLeftThumb,
    this.fingerLeftIndex,
    this.fingerLeftMiddle,
    this.fingerLeftRing,
    this.fingerLeftLittle,
    this.fingerRightThumb,
    this.fingerRightIndex,
    this.fingerRightMiddle,
    this.fingerRightRing,
    this.fingerRightLittle,

    this.isChecked,
    this.isComplete,
    this.status,

    // Default false
    this.isSubmitted = false,

    this.address1,
    this.address2,
    this.landmark,
    this.city,
    this.state,
    this.country,
    this.pinCode,
    this.profileImage,
    this.profileImageName,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      adminId: json['adminId'] as String? ?? '',
      id: json['_id'] as String? ??
          json['userId'] as String? ??
          '',
      dataName: json['dataName'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      fatherName: json['father_name'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      studdingClass: json['class'] as String?,
      dob: json['dob'] as String?,

      isReportGenerated:
      json['isReportGenerated'] == true ||
          json['isReportGenerated'] == 1,

      reportUpdatedAt:
      json['report_updated_at'] as String?,

      // Finger Data
      fingerLeftThumb: json['fingerLeftThumb'] != null
          ? FingerData.fromJson(
          json['fingerLeftThumb'] as Map<String, dynamic>)
          : null,

      fingerLeftIndex: json['fingerLeftIndex'] != null
          ? FingerData.fromJson(
          json['fingerLeftIndex'] as Map<String, dynamic>)
          : null,

      fingerLeftMiddle: json['fingerLeftMiddle'] != null
          ? FingerData.fromJson(
          json['fingerLeftMiddle'] as Map<String, dynamic>)
          : null,

      fingerLeftRing: json['fingerLeftRing'] != null
          ? FingerData.fromJson(
          json['fingerLeftRing'] as Map<String, dynamic>)
          : null,

      fingerLeftLittle: json['fingerLeftLittle'] != null
          ? FingerData.fromJson(
          json['fingerLeftLittle'] as Map<String, dynamic>)
          : null,

      fingerRightThumb: json['fingerRightThumb'] != null
          ? FingerData.fromJson(
          json['fingerRightThumb'] as Map<String, dynamic>)
          : null,

      fingerRightIndex: json['fingerRightIndex'] != null
          ? FingerData.fromJson(
          json['fingerRightIndex'] as Map<String, dynamic>)
          : null,

      fingerRightMiddle: json['fingerRightMiddle'] != null
          ? FingerData.fromJson(
          json['fingerRightMiddle'] as Map<String, dynamic>)
          : null,

      fingerRightRing: json['fingerRightRing'] != null
          ? FingerData.fromJson(
          json['fingerRightRing'] as Map<String, dynamic>)
          : null,

      fingerRightLittle: json['fingerRightLittle'] != null
          ? FingerData.fromJson(
          json['fingerRightLittle'] as Map<String, dynamic>)
          : null,

      isChecked: json['isChecked'] as bool?,
      isComplete: json['isComplete'] as bool?,
      status: json['status'] as bool?,

      // isSubmitted - handles bool, integer and string
      isSubmitted: json['isSubmitted'] == true ||
          json['isSubmitted'] == 1 ||
          json['isSubmitted'] == 'true' ||
          json['isSubmitted'] == '1',

      address1: json['address1'] as String?,
      address2: json['address2'] as String?,
      landmark: json['landmark'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      pinCode: json['pincode'] as String?,
      profileImage: json['profileImage'] as String?,
      profileImageName: json['profileImageName'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adminId': adminId,
      '_id': id,
      'dataName': dataName,
      'firstName': firstName,
      'lastName': lastName,
      'father_name': fatherName,
      'email': email,
      'mobile': mobile,
      'class': studdingClass,
      'dob': dob,
      'isReportGenerated': isReportGenerated,
      'report_updated_at': reportUpdatedAt,

      // Finger Data
      'fingerLeftThumb': fingerLeftThumb?.toJson(),
      'fingerLeftIndex': fingerLeftIndex?.toJson(),
      'fingerLeftMiddle': fingerLeftMiddle?.toJson(),
      'fingerLeftRing': fingerLeftRing?.toJson(),
      'fingerLeftLittle': fingerLeftLittle?.toJson(),

      'fingerRightThumb': fingerRightThumb?.toJson(),
      'fingerRightIndex': fingerRightIndex?.toJson(),
      'fingerRightMiddle': fingerRightMiddle?.toJson(),
      'fingerRightRing': fingerRightRing?.toJson(),
      'fingerRightLittle': fingerRightLittle?.toJson(),

      'isChecked': isChecked,
      'isComplete': isComplete,
      'status': status,

      // New field
      'isSubmitted': isSubmitted,

      'address1': address1,
      'address2': address2,
      'landmark': landmark,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pinCode,
      'profileImage': profileImage,
      'profileImageName': profileImageName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// ============================================================================
// FingerData Model Class (Individual Fingerprint Scan Metadata)
// ============================================================================
class FingerData {
  int? ridgeCount;
  String? fingerprintPattern;
  String? fingerprintImage;
  String? patternCode;

  FingerData({
    this.ridgeCount,
    this.fingerprintPattern,
    this.fingerprintImage,
    this.patternCode,
  });

  factory FingerData.fromJson(Map<String, dynamic> json) {
    return FingerData(
      ridgeCount: json['ridge_count'] as int?,
      fingerprintPattern: json['fingerprint_pattern'] as String?,
      fingerprintImage: json['fingerprint_image'] as String?,
      patternCode: json['pattern_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ridge_count': ridgeCount,
      'fingerprint_pattern': fingerprintPattern,
      'fingerprint_image': fingerprintImage,
      'pattern_code': patternCode,
    };
  }
}

// ============================================================================
// FindFingerprintscanByIdResponse Model Class (Single User Response)
// ============================================================================
class FindFingerprintscanByIdResponse {
  String? message;
  User? user;

  FindFingerprintscanByIdResponse({
    this.message,
    this.user,
  });

  factory FindFingerprintscanByIdResponse.fromJson(Map<String, dynamic> json) {
    return FindFingerprintscanByIdResponse(
      message: json['message'] as String?,
      user: json['UserData'] != null
          ? User.fromJson(json['UserData'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'UserData': user?.toJson(),
    };
  }
}
