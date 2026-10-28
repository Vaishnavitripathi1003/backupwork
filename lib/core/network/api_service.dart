import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'dio_client.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Map<String, String> _buildAuthHeader(String auth) {
    final token = auth.startsWith('Bearer ') ? auth : 'Bearer $auth';
    return {'Authorization': token};
  }

  /// 1. signupOTP: GET("admin/sendSignUpVeri?mobile=...")
  Future<Response> sendSignUpVerification({
    required String mobile,
  }) async {
    return _dio.get(
      'sendSignUpVeri',
      queryParameters: {'mobile': mobile},
    );
  }


  void logRequest(String url, Map<String, dynamic> body, Map<String, dynamic> headers) {
    const encoder = JsonEncoder.withIndent('  ');
    debugPrint('[AUTH] URL: $url');
    debugPrint('[AUTH] Headers: ${encoder.convert(headers)}');
    debugPrint('[AUTH] Body:\n${encoder.convert(body)}');
    // Show the type of each value, since "278352" and 278352 are different
    body.forEach((k, v) => debugPrint('[AUTH]   $k -> ${v.runtimeType}: "$v"'));
  }
  /// 2. signup: POST("admin/register")
/*  Future<Response> signUp({
    required String auth,
    required Map<String, dynamic> signUpRequest,
  }) async {
    logRequest('${_dio.options.baseUrl}register', signUpRequest, auth);

    return _dio.post(
      'register',
      data: signUpRequest,
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }*/
  Future<Response> signUp({
    required String auth,
    required Map<String, dynamic> signUpRequest,
  }) async {
    final headers = _buildAuthHeader(auth);   // Map, e.g. {'Authorization': 'Bearer ...'}

    logRequest('${_dio.options.baseUrl}register', signUpRequest, headers);

    return _dio.post(
      'register',
      data: signUpRequest,
      options: Options(headers: headers),
    );
  }

  /// 3. login / login vendor: GET("admin/login?mobile=...&password=...")
  Future<Response> login({
    required String mobile,
    required String password,
  }) async {
    return _dio.get(
      'login',
      queryParameters: {
        'mobile': mobile,
        'password': password,
      },
    );
  }

  /// 4. findAdminByLoginId: GET("admin/findAdminByLoginId")
  Future<Response> findAdminByLoginId({
    required String auth,
  }) async {
    return _dio.get(
      'findAdminByLoginId',
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  /// 5. updateRegister: PATCH("admin/updateRegister")
  Future<Response> updateRegister({
    required String auth,
    String? firstName,
    String? lastName,
    String? subscriptionLevel,
    String? userImagePath,
  }) async {
    final Map<String, dynamic> map = {};
    if (firstName != null) map['firstName'] = firstName;
    if (lastName != null) map['lastName'] = lastName;
    if (subscriptionLevel != null) map['subscriptionLevel'] = subscriptionLevel;
    if (userImagePath != null) {
      map['userImage'] = await MultipartFile.fromFile(userImagePath);
    }

    final formData = FormData.fromMap(map);

    return _dio.patch(
      'updateRegister',
      data: formData,
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  /// 6. findFingerprintscanByAdmin: GET("admin/findFingerprintscanByAdmin")
  Future<Response> findFingerPrintScanByAdmin({
    required String auth,
  }) async {
    return _dio.get(
      'findFingerprintscanByAdmin',
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  /// 7. createUserData: POST("admin/fingerprintscan")
  Future<Response> createUserData({
    required String auth,
    required String firstName,
    String? lastName,
    String? mobile,
    String? dataName,
  }) async {
    final map = {
      'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (mobile != null) 'mobile': mobile,
      if (dataName != null) 'dataName': dataName,
    };

    return _dio.post(
      'fingerprintscan',
      data: map,
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  /// 8. fingerprintscan: POST("admin/fingerprintscan?userData_id=...")
  Future<Response> fingerprintScan({
    required String auth,
    required String userDataId,
    required Map<String, dynamic> fingerData,
  }) async {
    return _dio.post(
      'fingerprintscan',
      data: fingerData,
      queryParameters: {'userData_id': userDataId},
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  /// 9. fingerprintscan1: POST("admin/fingerprintscan1?userData_id=...")
  Future<Response> fingerPrintScan1({
    required String auth,
    required String userDataId,
    required Map<String, dynamic> fingerPrintScan1Request,
  }) async {
    return _dio.post(
      'fingerprintscan1',
      data: fingerPrintScan1Request,
      queryParameters: {'userData_id': userDataId},
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  /// 10. fingerprintscanImage: PATCH("admin/fingerprintscanImage?userData_id=...")
  Future<Response> fingerprintscanImage({
    required String auth,
    required String userDataId,
    String? leftThumbPath,
    String? leftIndexPath,
    String? leftMiddlePath,
    String? leftRingPath,
    String? leftLittlePath,
    String? rightThumbPath,
    String? rightIndexPath,
    String? rightMiddlePath,
    String? rightRingPath,
    String? rightLittlePath,
  }) async {
    final Map<String, dynamic> map = {};

    Future<void> addIfNotNull(String key, String? path) async {
      if (path != null) {
        map[key] = await MultipartFile.fromFile(path);
      }
    }

    await addIfNotNull('leftThumb', leftThumbPath);
    await addIfNotNull('leftIndex', leftIndexPath);
    await addIfNotNull('leftMiddle', leftMiddlePath);
    await addIfNotNull('leftRing', leftRingPath);
    await addIfNotNull('leftLittle', leftLittlePath);
    await addIfNotNull('rightThumb', rightThumbPath);
    await addIfNotNull('rightIndex', rightIndexPath);
    await addIfNotNull('rightMiddle', rightMiddlePath);
    await addIfNotNull('rightRing', rightRingPath);
    await addIfNotNull('rightLittle', rightLittlePath);

    final formData = FormData.fromMap(map);

    return _dio.patch(
      'fingerprintscanImage',
      data: formData,
      queryParameters: {'userData_id': userDataId},
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  /// 11. fingerprintscanImageSave: PATCH("admin/fingerprintscanImageSave?userData_id=...")
  Future<Response> fingerprintscanImageRaw({
    required String auth,
    required String userDataId,
    required String leftThumbOrgPath,
    required String leftIndexOrgPath,
    required String leftMiddleOrgPath,
    required String leftRingOrgPath,
    required String leftLittleOrgPath,
    required String rightThumbOrgPath,
    required String rightIndexOrgPath,
    required String rightMiddleOrgPath,
    required String rightRingOrgPath,
    required String rightLittleOrgPath,
  }) async {
    final formData = FormData.fromMap({
      'leftThumbOrg': await MultipartFile.fromFile(leftThumbOrgPath),
      'leftIndexOrg': await MultipartFile.fromFile(leftIndexOrgPath),
      'leftMiddleOrg': await MultipartFile.fromFile(leftMiddleOrgPath),
      'leftRingOrg': await MultipartFile.fromFile(leftRingOrgPath),
      'leftLittleOrg': await MultipartFile.fromFile(leftLittleOrgPath),
      'rightThumbOrg': await MultipartFile.fromFile(rightThumbOrgPath),
      'rightIndexOrg': await MultipartFile.fromFile(rightIndexOrgPath),
      'rightMiddleOrg': await MultipartFile.fromFile(rightMiddleOrgPath),
      'rightRingOrg': await MultipartFile.fromFile(rightRingOrgPath),
      'rightLittleOrg': await MultipartFile.fromFile(rightLittleOrgPath),
    });

    return _dio.patch(
      'fingerprintscanImageSave',
      data: formData,
      queryParameters: {'userData_id': userDataId},
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  /// 12. delete user: DELETE("admin/deleteFingerprintscan?userData_id=...")
  Future<Response> deleteUsers({
    required String auth,
    required List<String> userDataIdList,
  }) async {
    return _dio.delete(
      'deleteFingerprintscan',
      queryParameters: {'userData_id': userDataIdList},
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  /// 13. delete account: DELETE("admin/deleteAdmin")
  Future<Response> deleteAccount({
    required String auth,
  }) async {
    return _dio.delete(
      'deleteAdmin',
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  /// 14. resetPassword1: GET("admin/sendOtp?mobile=...")
  Future<Response> resetPasswordVerification({
    required String mobile,
  }) async {
    return _dio.get(
      'sendOtp',
      queryParameters: {'mobile': mobile},
    );
  }

  /// 15. verifyOtp: POST("admin/verifyOtp")
  Future<Response> verifyOtp({
    required String auth,
    required String password,
    required String otp,
    required String token,
  }) async {
    return _dio.post(
      'verifyOtp',
      data: {
        'password': password,
        'otp': otp,
        'token': token,
      },
      options: Options(
        headers: _buildAuthHeader(auth),
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
  }

  /// 16. createReport: POST("admin/createReport")
  Future<Response> createReport({
    required String auth,
    required String userDataId,
    bool isNotificationSend = false,
  }) async {
    return _dio.post(
      'createReport',
      data: {
        'userDataId': userDataId,
        'isNotificationSend': isNotificationSend,
      },
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  /// 17. findReportByUserDataId: GET("admin/findReportByUserDataId?userDataId=...")
  Future<Response> findReportByUserDataId({
    required String auth,
    required String userDataId,
  }) async {
    return _dio.get(
      'findReportByUserDataId',
      queryParameters: {'userDataId': userDataId},
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  /// 18. vendor find user data: GET("admin/findFingerprintscanByVendor")
  Future<Response> findFingerprintscanByVendor({
    required String auth,
    String? schoolId,
  }) async {
    return _dio.get(
      'findFingerprintscanByVendor',
      queryParameters: {
        if (schoolId != null) 'schoolId': schoolId,
      },
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  /// 19. find schools by vendor token: GET("admin/findAdminByVendor")
  Future<Response> findAdminByVendor({
    required String auth,
  }) async {
    return _dio.get(
      'findAdminByVendor',
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  /// 20. updateFirebaseToken: PATCH("admin/updateFirebaseToken")
  Future<Response> updateFirebaseToken({
    required String auth,
    required String token,
  }) async {
    return _dio.patch(
      'updateFirebaseToken',
      data: {'token': token},
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  /// 21. findAdminByRole: GET("admin/findAdminByRole?role=...")
  Future<Response> findAdminByRole({
    required String auth,
    required String role,
    int? page,
    int? limit,
  }) async {
    return _dio.get(
      'findAdminByRole',
      queryParameters: {
        'role': role,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  /// 22. OTP Bulk SMS External Gateway
  Future<Response> sendBulkSms({
    required String mobile,
    required String message,
    String username = 'PSPURSUEE',
    String password = 'gate123',
    String type = 'EXT',
    String sender = 'PRSUED',
    String peid = '1201170911499745122',
    String headerId = '1705175776794337940',
  }) async {
    return _dio.get(
      'https://bulksms.analyticsmantra.com/sendsms/sendsms.php',
      queryParameters: {
        'username': username,
        'password': password,
        'type': type,
        'sender': sender,
        'mobile': mobile,
        'message': message,
        'PEID': peid,
        'HeaderId': headerId,
        'templateId': '',
      },
    );
  }

  Future<Response> findReportByUserParam({
    required String auth,
    required String userParam,
    required String userDataId,
  }) async {
    return _dio.get(
      'findReportByUserParam',
      queryParameters: {
        'user_param': userParam,
        'userDataId': userDataId,
      },
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }



  Future<Response> fetchReportStatus({
    required String auth,
    required String userDataId,
  }) async {
    return _dio.get(
      'findIsReportGeneratedByUserDataId',
      queryParameters: {
        'userDataId': userDataId,
      },
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  /// 7b. createUserPersonal: POST("admin/fingerprintscan") as multipart/form-data
  Future<Response> createUserPersonal({
    required String auth,
    required String firstName,
    required String lastName,
    required String mobile,
    required String dataName,
  }) async {
    final formData = FormData.fromMap({
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'mobile': mobile.trim(),
      'dataName': '$firstName $lastName'.trim()
    });

    return _dio.post(
      'fingerprintscan',
      data: formData,
      options: Options(
        headers: _buildAuthHeader(auth),
        contentType: 'multipart/form-data',
      ),
    );
  }


  ////todo disc personality work
  Future<Response> findDiscPersonalityLifeStagesGuideByUserDataId({
    required String auth,
    required String userDataId,
  }) async {
    return _dio.get(
      'findDiscPersonalityLifeStagesGuideByUserDataId',
      queryParameters: {'userDataId': userDataId},
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  Future<Response> findDiscPersonalityCombinationsSwotAnalysisByUserDataId({
    required String auth,
    required String userDataId,
  }) async {
    return _dio.get(
      'findDiscPersonalityCombinationsSwotAnalysisByUserDataId',
      queryParameters: {'userDataId': userDataId},
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }

  Future<Response> findDiscPersonalityCombinationsRecommendationsByUserDataId({
    required String auth,
    required String userDataId,
  }) async {
    return _dio.get(
      'findDiscPersonalityCombinationsRecommendationsByUserDataId',
      queryParameters: {'userDataId': userDataId},
      options: Options(headers: _buildAuthHeader(auth)),
    );
  }
}

///new one to take report
/// 23. findReportByUserParam: GET("admin/findReportByUserParam?user_param=...&userDataId=...")
