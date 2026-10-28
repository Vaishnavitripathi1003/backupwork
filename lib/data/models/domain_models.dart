/*
// ==========================================
// ADDITIONAL REQUEST / RESPONSE MODELS
// ==========================================

class MobileRequest {
  final String mobile;

  MobileRequest({required this.mobile});

  Map<String, dynamic> toJson() => {
        'mobile': mobile,
      };
}

class TempSignUpRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String password;

  TempSignUpRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'mobile': mobile,
        'password': password,
      };
}

// ==========================================
// ENUMS
// ==========================================

enum Finger {
  fingerLeftThumb('fingerLeftThumb'),
  fingerLeftIndex('fingerLeftIndex'),
  fingerLeftMiddle('fingerLeftMiddle'),
  fingerLeftRing('fingerLeftRing'),
  fingerLeftLittle('fingerLeftLittle'),
  fingerRightThumb('fingerRightThumb'),
  fingerRightIndex('fingerRightIndex'),
  fingerRightMiddle('fingerRightMiddle'),
  fingerRightRing('fingerRightRing'),
  fingerRightLittle('fingerRightLittle');

  final String value;
  const Finger(this.value);

  static Finger? fromValue(String value) {
    return Finger.values
        .firstWhere((e) => e.value == value, orElse: () => Finger.fingerLeftThumb);
  }
}

enum FingerImageState {
  notClick(0),
  click(1),
  process(2),
  failedProcess(3);

  final int code;
  const FingerImageState(this.code);

  static FingerImageState fromIndex(int code) {
    return FingerImageState.values.firstWhere(
      (e) => e.code == code,
      orElse: () => FingerImageState.notClick,
    );
  }
}

enum CareerOptions {
  medical('Medical'),
  engineering('Engineering'),
  music('Music'),
  lifeScience('Life Science'),
  designing('Designing'),
  weather('Weather & Environment Science'),
  banking('Banking & Finance'),
  mass('Mass & Media Communication'),
  literature('Literature'),
  maths('Mathematics & Analyst'),
  management('Management'),
  publicAffairs('Public & Political Affairs'),
  psychology('Psychology'),
  foreignLanguage('Foreign Language'),
  sports('Sports'),
  defence('Defence');

  final String value;
  const CareerOptions(this.value);
}

enum PersonalityType {
  dominant("Dominant", "Eagle"),
  influential("Influential", "Peacock"),
  compliant("Compliant", "Owl"),
  steady("Steady", "Pigeon"),
  unknown("Unknown", "");

  final String english;
  final String animalName;
  const PersonalityType(this.english, this.animalName);

  static PersonalityType fromValue(String? value) {
    return PersonalityType.values.firstWhere(
      (e) => e.english == value,
      orElse: () => PersonalityType.unknown,
    );
  }
}

// ==========================================
// LOCAL DATABASE ENTITIES (For Sqflite in Flutter)
// ==========================================

class UserTable {
  final String userId;
  final String? adminId;
  final String? dataName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobile;
  final bool isReportGenerated;
  final bool isPhotosUploaded;

  UserTable({
    required this.userId,
    this.adminId,
    this.dataName,
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.isReportGenerated = false,
    this.isPhotosUploaded = false,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'adminId': adminId,
        'dataName': dataName,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'mobile': mobile,
        'isReportGenerated': isReportGenerated ? 1 : 0,
        'isPhotosUploaded': isPhotosUploaded ? 1 : 0,
      };

  factory UserTable.fromMap(Map<String, dynamic> map) => UserTable(
        userId: map['userId'] ?? '',
        adminId: map['adminId'],
        dataName: map['dataName'],
        firstName: map['firstName'],
        lastName: map['lastName'],
        email: map['email'],
        mobile: map['mobile'],
        isReportGenerated: map['isReportGenerated'] == 1,
        isPhotosUploaded: map['isPhotosUploaded'] == 1,
      );
}

class FingerprintTable {
  final int? id;
  final String fingerprintImagePath;
  final String enhancedFingerprintPath;
  final String pattern;
  final String patternCode;
  final int ridgeCount;

  FingerprintTable({
    this.id,
    required this.fingerprintImagePath,
    required this.enhancedFingerprintPath,
    required this.pattern,
    required this.patternCode,
    required this.ridgeCount,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'fingerprintImagePath': fingerprintImagePath,
        'enhancedFingerprintPath': enhancedFingerprintPath,
        'pattern': pattern,
        'patternCode': patternCode,
        'ridgeCount': ridgeCount,
      };

  factory FingerprintTable.fromMap(Map<String, dynamic> map) => FingerprintTable(
        id: map['id'] as int?,
        fingerprintImagePath: map['fingerprintImagePath'] ?? '',
        enhancedFingerprintPath: map['enhancedFingerprintPath'] ?? '',
        pattern: map['pattern'] ?? '',
        patternCode: map['patternCode'] ?? '',
        ridgeCount: map['ridgeCount'] ?? 0,
      );
}
*/
