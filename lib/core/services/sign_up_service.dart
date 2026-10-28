/*
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/signUpResponses.dart';
import '../../data/models/user_models.dart';
import '../Global/global_class.dart';
import '../database/database_helper.dart';
import '../network/api_service.dart';
import '../storage/user_pref.dart';
import 'dashboard_report_status_controller.dart';
import 'homedataPreloader.dart';

class SignUpService {
  final ApiService _apiService;

  SignUpService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  String? tempToken;
  String? finalToken;
  String? receivedOtp;
  SignUpResponseData? adminProfileData;
  User? adminProfileDatas;
  List<User> candidateUsers = [];

  // ==========================================
  // STEP 1: OTP भेजें (GET /sendSignUpVeri)
  // ==========================================
*/
/*  Future<bool> sendOtp(String rawMobile) async {
    // Sanitize mobile: remove country code, spaces, leading 0 to get clean 10-digit number
  *//*
*/
/*  final digits = rawMobile.replaceAll(RegExp(r'\D'), '');
    final mobile = digits.length > 10 ? digits.substring(digits.length - 10) : digits;*//*
*/
/*

    try {
      final response = await _apiService.sendSignUpVerification(mobile: rawMobile);

      if (response.statusCode == 200) {
        debugPrint(
            "Step 1 Success: ${response.data}");
        final data = response.data;
        if (data != null) {
          if (data['token'] != null) {
            tempToken = data['token'].toString();
          }
          if (data['otp'] != null) {
            receivedOtp = data['otp'].toString();
          } else if (data['otpSession'] != null) {
            receivedOtp = data['otpSession'].toString();
          }


          debugPrint(
              "Step 1 Success: Temp Token -> $tempToken, Received OTP -> $receivedOtp");
          return true;
        }
      }
      else{
        debugPrint("Step 1 Failed: ${response.data}");
        return false;
      }
      debugPrint("Step 1 Failed: ${response.data}");
      return false;
    } catch (e) {
      debugPrint("Error in Step 1: $e");
      return false;
    }
  }*//*





// Add this field to the same class (provider/controller)
  String? errorMessage;
  bool isAlreadyRegistered = false;

  Future<bool> sendOtp(String rawMobile) async {
    errorMessage = null;
    isAlreadyRegistered = false;

    try {
      final response =
      await _apiService.sendSignUpVerification(mobile: rawMobile);

      final data = response.data;
      if (response.statusCode == 200 && data != null) {
        if (data['token'] != null) {
          tempToken = data['token'].toString();
        }
        if (data['otp'] != null) {
          receivedOtp = data['otp'].toString();
        } else if (data['otpSession'] != null) {
          receivedOtp = data['otpSession'].toString();
        }

        debugPrint("Step 1 Success: Temp Token -> $tempToken, OTP -> $receivedOtp");
        return true;
      }

      errorMessage = 'Unexpected response from server';
      debugPrint("Step 1 Failed: ${response.data}");
      return false;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;

      if (status == 400 || status == 409) {
        // Server sent {"error": "User allready exit"}
        final serverMsg = (body is Map ? body['error']?.toString() : null) ?? '';

        if (serverMsg.toLowerCase().contains('exit') ||
            serverMsg.toLowerCase().contains('exist')) {
          isAlreadyRegistered = true;
          errorMessage = 'This number is already registered. Please sign in.';
        } else {
          errorMessage = serverMsg.isNotEmpty ? serverMsg : 'Invalid request';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        errorMessage = 'Network problem. Please check your connection.';
      } else {
        errorMessage = 'Something went wrong. Please try again.';
      }

      debugPrint("Error in Step 1: status=$status body=$body");
      return false;
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
      debugPrint("Error in Step 1: $e");
      return false;
    }
  }

  // ==========================================
  // STEP 2: OTP वेरिफाई करके Register करें (POST /register)
  // ==========================================
  Future<bool> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
    required String otp,
  }) async {
    if (tempToken == null) {
      debugPrint("Error: tempToken is missing. Call sendOtp first.");
      return false;
    }

    try {
      final signUpRequest = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'mobile': mobile,
        'password': password,
        'otp': otp,
        'userType': 'daksh',
      };

      final response = await _apiService.signUp(
        auth: tempToken!,
        signUpRequest: signUpRequest,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint("Response data: $data");
        if (data != null && data['token'] != null) {
          finalToken = data['token'].toString();

          final prefs = await SharedPreferences.getInstance();
          final userPref = UserPref(prefs);
          await userPref.setToken(finalToken);

          debugPrint("Step 2 Success: Final JWT Token Saved -> $finalToken");
          return true;
        }
      }
      debugPrint("Step 2 Failed: ${response.data}");
      return false;
    } catch (e) {
      debugPrint("Error in Step 2: $e");
      return false;
    }
  }

  // ==========================================
  // STEP 3: Admin Data लोड करें (GET /findAdminByLoginId) -> SQLite Save
  // ==========================================
  Future<User?> fetchAdminData() async {
    if (finalToken == null) return null;

    try {








      final response = await _apiService.findAdminByLoginId(auth: finalToken!);

      if (response.statusCode == 200 && response.data != null) {
        final response2 = SignUpResponse2.fromJson(response.data);
        adminProfileData = response2.data;
        if (adminProfileData != null) {
          await DatabaseHelper.instance.insertOrUpdateAdminData(adminProfileData!);

          final response2 = await _apiService.createUserPersonal(auth: finalToken!, firstName: adminProfileData!.firstName!, lastName: adminProfileData!.lastName!, mobile: adminProfileData!.mobile!,  dataName: '${adminProfileData!.firstName! ?? ''} ${adminProfileData!.lastName}');
if (response2.statusCode == 200 && response2.data != null) {
  final response23= FingerScanResponse.fromJson(response2.data);
  if (response23.data != null) {
    User adminProfileDatas = response23.data!;
    if (adminProfileDatas != null) {
      ///dmiadminProfileData!.id,adminProfileDatas!.id
      await DatabaseHelper.instance.updateUserId(adminProfileData!.id!, adminProfileDatas!.id!);
    }
  }
}else{
      debugPrint("Step 3 Failed: ${response2.data}");
}

          debugPrint("Step 3 Success: Admin Data Saved to SQLite -> ${adminProfileData?.firstName} ${adminProfileData?.lastName}");
        }
        return adminProfileDatas;
      }
      return null;
    } catch (e) {
      debugPrint("Error in Step 3: $e");
      return null;
    }
  }

  // ==========================================
  // STEP 4: Candidate User List लोड करें (GET /findFingerprintscanByAdmin) -> SQLite Save
  // ==========================================
  Future<List<User>?> fetchUserCandidates() async {
    if (finalToken == null) return null;

    try {
      final response =
          await _apiService.findFingerPrintScanByAdmin(auth: finalToken!);

      if (response.statusCode == 200 && response.data != null) {
        final candidatesList =
            response.data?['UserData'] as List<dynamic>?;

        if (candidatesList != null) {
          candidateUsers = candidatesList
              .whereType<Map<String, dynamic>>()
              .map((map) => User.fromJson(map))
              .toList();

          await DatabaseHelper.instance.insertCandidateMembers(candidateUsers);
          debugPrint(
              "Step 4 Success: ${candidateUsers.length} Candidates Saved to SQLite");
          return candidateUsers;
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error in Step 4: $e");
      return null;
    }
  }

  // ==========================================
  // COMPLETE FLOW CALL (एक साथ पूरा प्रोसेस चलाने के लिए)
  // ==========================================
  Future<bool> completeSignupAndLoadHome({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
    required String otp,
  }) async {
    // 1. Clear previous session data
    await DatabaseHelper.instance.clearAllData();
    GlobalClass.reset();
    await HomeDataPreloader.instance.clear();
    DashboardReportStatusController.instance.cancel();

    // 2. Register User
    bool isRegistered = await registerUser(
      firstName: firstName,
      lastName: lastName,
      email: email,
      mobile: mobile,
      password: password,
      otp: otp,
    );

    if (!isRegistered) return false;

    // 3. Load Admin Profile Data & Save to SQLite
    final adminData = await fetchAdminData();

    // Bind newly registered user as primary candidate in SQLite
    final primaryCandidate = User(
      id: adminData?.adminId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      adminId: adminData?.id ?? '',
      firstName: adminData?.firstName ?? firstName,
      lastName: adminData?.lastName ?? lastName,
      dataName: '${adminData?.firstName ?? firstName} ${adminData?.lastName ?? lastName}'.trim(),
      email: adminData?.email ?? email,
      mobile: adminData?.mobile ?? mobile,
      isReportGenerated: false,
    );

    await DatabaseHelper.instance.insertCandidateMembers([primaryCandidate]);
    GlobalClass.selected_member = primaryCandidate.id;

    // 4. Load Candidates List Data from server (if available)
    final serverCandidates = await fetchUserCandidates();

    if (serverCandidates != null && serverCandidates.isNotEmpty) {
      await DatabaseHelper.instance.insertCandidateMembers(serverCandidates);
      GlobalClass.selected_member = serverCandidates.first.id;
      HomeDataPreloader.instance.seedCandidates(serverCandidates);
    } else {
      HomeDataPreloader.instance.seedCandidates([primaryCandidate]);
    }

    // Everything Done -> Ready to open Dashboard!
    return true;
  }
}

final signUpService = SignUpService();
*/

/*import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/signUpResponses.dart';
import '../../data/models/user_models.dart';
import '../Global/global_class.dart';
import '../database/database_helper.dart';
import '../network/api_service.dart';
import '../storage/user_pref.dart';
import 'dashboard_report_status_controller.dart';
import 'homedataPreloader.dart';

class SignUpService {
  final ApiService _apiService;

  SignUpService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  String? tempToken;
  String? finalToken;
  String? receivedOtp;

  SignUpResponseData? adminProfileData;
  User? adminProfileDatas;
  List<User> candidateUsers = [];

  String? errorMessage;
  bool isAlreadyRegistered = false;

  // ==========================================
  // STEP 1: SEND OTP
  // GET /sendSignUpVeri
  // ==========================================
  Future<bool> sendOtp(String rawMobile) async {
    errorMessage = null;
    isAlreadyRegistered = false;
    tempToken = null;
    receivedOtp = null;

    try {
      final response =
      await _apiService.sendSignUpVerification(
        mobile: rawMobile,
      );

      final data = response.data;

      if (response.statusCode == 200 && data != null) {
        if (data['token'] != null) {
          tempToken = data['token'].toString();
        }

        if (data['otp'] != null) {
          receivedOtp = data['otp'].toString();
        } else if (data['otpSession'] != null) {
          receivedOtp = data['otpSession'].toString();
        }

        debugPrint("Step 1 Success: OTP Request Completed");
        return true;
      }

      errorMessage = 'Unexpected response from server';

      debugPrint("Step 1 Failed: ${response.data}");
      return false;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;

      if (status == 400 || status == 409) {
        final serverMsg =
            (body is Map ? body['error']?.toString() : null) ??
                '';

        if (serverMsg.toLowerCase().contains('exit') ||
            serverMsg.toLowerCase().contains('exist')) {
          isAlreadyRegistered = true;
          errorMessage =
          'This number is already registered. Please sign in.';
        } else {
          errorMessage = serverMsg.isNotEmpty
              ? serverMsg
              : 'Invalid request';
        }
      } else if (
      e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        errorMessage =
        'Network problem. Please check your connection.';
      } else {
        errorMessage =
        'Something went wrong. Please try again.';
      }

      debugPrint("Error in Step 1: status=$status");
      return false;
    } catch (e) {
      errorMessage =
      'Something went wrong. Please try again.';

      debugPrint("Error in Step 1: $e");
      return false;
    }
  }

  // ==========================================
  // STEP 2: REGISTER USER
  // POST /register
  // ==========================================
  Future<bool> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
    required String otp,
  }) async {
    if (tempToken == null) {
      debugPrint(
        "Error: tempToken is missing. Call sendOtp first.",
      );
      return false;
    }

    try {
      final signUpRequest = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'mobile': mobile,
        'password': password,
        'otp': otp,
        'userType': 'daksh',
      };

      final response = await _apiService.signUp(
        auth: tempToken!,
        signUpRequest: signUpRequest,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final data = response.data;

        if (data != null && data['token'] != null) {
          finalToken = data['token'].toString();

          final prefs =
          await SharedPreferences.getInstance();

          final userPref = UserPref(prefs);

          await userPref.setToken(finalToken);

          debugPrint(
            "Step 2 Success: Final JWT Token Saved",
          );

          return true;
        }
      }

      debugPrint("Step 2 Failed: ${response.data}");
      return false;
    } catch (e) {
      debugPrint("Error in Step 2: $e");
      return false;
    }
  }

  // ==========================================
  // STEP 3: FETCH ADMIN PROFILE
  // GET /findAdminByLoginId
  //
  // NO CANDIDATE INSERTION HERE
  // NO createUserPersonal CALL HERE
  // ==========================================
  Future<SignUpResponseData?> fetchAdminData() async {
    if (finalToken == null) {
      debugPrint("Admin Fetch Failed: Token Missing");
      return null;
    }

    try {
      final response =
      await _apiService.findAdminByLoginId(
        auth: finalToken!,
      );

      if (response.statusCode == 200 &&
          response.data != null) {
        final result =
        SignUpResponse2.fromJson(response.data);

        adminProfileData = result.data;

        if (adminProfileData != null) {
          debugPrint(
            "Step 3 Success: Admin Profile Fetched",
          );

          debugPrint(
            "Admin ID: ${adminProfileData?.id}",
          );

          return adminProfileData;
        }
      }

      debugPrint("Step 3 Failed: Admin Data Missing");
      return null;
    } catch (e) {
      debugPrint("Error in Step 3: $e");
      return null;
    }
  }

  // ==========================================
  // STEP 4: FETCH CANDIDATE LIST
  // GET /findFingerprintscanByAdmin
  //
  // FETCH ONLY - NO SQLITE INSERTION
  // ==========================================
  Future<List<User>?> fetchUserCandidates() async {
    if (finalToken == null) {
      debugPrint("Candidate Fetch Failed: Token Missing");
      return null;
    }

    try {
      final response =
      await _apiService.findFingerPrintScanByAdmin(
        auth: finalToken!,
      );

      if (response.statusCode != 200 ||
          response.data == null) {
        debugPrint("Candidate API Failed");
        return null;
      }

      final candidatesList =
      response.data['UserData'];

      // Null/missing list is not treated as empty.
      if (candidatesList is! List) {
        debugPrint("Invalid Candidate List Response");
        return null;
      }

      // Remove duplicates based on actual server User ID
      final uniqueCandidates = <String, User>{};

      for (final item in candidatesList) {
        if (item is Map<String, dynamic>) {
          final candidate = User.fromJson(item);

          final candidateId =
          candidate.id.toString().trim();

          if (candidateId.isNotEmpty &&
              candidateId.toLowerCase() != 'null') {
            uniqueCandidates[candidateId] = candidate;
          }
        }
      }

      candidateUsers =
          uniqueCandidates.values.toList();

      debugPrint(
        "Step 4: API Candidates = ${candidatesList.length}",
      );

      debugPrint(
        "Step 4: Unique Candidates = ${candidateUsers.length}",
      );

      // Do not insert here.
      return candidateUsers;
    } catch (e) {
      debugPrint("Error in Step 4: $e");
      return null;
    }
  }

  // ==========================================
  // STEP 5: COMPLETE SIGNUP FLOW
  //
  // REGISTER
  //    |
  // CHECK CANDIDATES
  //    |
  //    |-- EXIST -> SAVE EXISTING CANDIDATES
  //    |
  //    |-- EMPTY -> FETCH ADMIN
  //                    |
  //                    CREATE PERSONAL USER
  //                    |
  //                    SAVE CREATED USER
  //    |
  // SET SELECTED MEMBER
  //    |
  // OPEN DASHBOARD
  // ==========================================
  Future<bool> completeSignupAndLoadHome({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
    required String otp,
  }) async {
    try {
      // --------------------------------------
      // STEP 1: Register user
      // --------------------------------------
      final isRegistered = await registerUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        mobile: mobile,
        password: password,
        otp: otp,
      );

      if (!isRegistered) {
        debugPrint("Signup Failed");
        return false;
      }

      // --------------------------------------
      // STEP 2: Clear previous local session
      // --------------------------------------
      await DatabaseHelper.instance.clearAllData();

      GlobalClass.reset();

      await HomeDataPreloader.instance.clear();

      DashboardReportStatusController.instance.cancel();

      candidateUsers = [];
      adminProfileData = null;
      adminProfileDatas = null;

      // --------------------------------------
      // STEP 3: Check candidates FIRST
      // --------------------------------------
      final serverCandidates =
      await fetchUserCandidates();

      if (serverCandidates == null) {
        debugPrint(
          "Candidate API Failed. Skipping User Creation.",
        );
        return false;
      }

      // ======================================
      // CASE 1: EXISTING CANDIDATES FOUND
      // ======================================
      if (serverCandidates.isNotEmpty) {
        candidateUsers = serverCandidates;

        debugPrint(
          "Existing Candidates Found: "
              "${candidateUsers.length}",
        );

        // Only ONE SQLite insertion
        await DatabaseHelper.instance
            .insertCandidateMembers(candidateUsers);

        debugPrint(
          "Existing Candidates Saved to SQLite",
        );
      }

      // ======================================
      // CASE 2: CANDIDATE LIST EMPTY
      // ======================================
      else {
        debugPrint(
          "Candidate List Empty -> Fetching Admin",
        );

        // STEP A: Fetch admin details
        final adminData = await fetchAdminData();

        if (adminData == null) {
          debugPrint("Admin Data Not Found");
          return false;
        }

        debugPrint(
          "Admin ID: ${adminData.id}",
        );

        // STEP B: Create personal user
        final createResponse =
        await _apiService.createUserPersonal(
          auth: finalToken!,
          firstName:
          adminData.firstName ?? firstName,
          lastName:
          adminData.lastName ?? lastName,
          mobile:
          adminData.mobile ?? mobile,
          dataName:
          '${adminData.firstName ?? firstName} '
              '${adminData.lastName ?? lastName}'
              .trim(),
        );

        if ((createResponse.statusCode != 200 &&
            createResponse.statusCode != 201) ||
            createResponse.data == null) {
          debugPrint(
            "createUserPersonal API Failed",
          );
          return false;
        }

        // STEP C: Parse actual User response
        final createResult =
        FingerScanResponse.fromJson(
          createResponse.data,
        );

        final User? createdUser =
            createResult.data;

        if (createdUser == null) {
          debugPrint(
            "Created User Response Missing",
          );
          return false;
        }

        final createdUserId =
        createdUser.id.toString().trim();

        if (createdUserId.isEmpty ||
            createdUserId.toLowerCase() == 'null') {
          debugPrint(
            "Created User ID Missing",
          );
          return false;
        }

        debugPrint(
          "Actual Created User ID: $createdUserId",
        );

        // STEP D: Save actual created user
        // Keep your existing SQLite method.
        await DatabaseHelper.instance
            .insertOrUpdateAdminDetails(
          createdUser,
        );

        adminProfileDatas = createdUser;

        candidateUsers = [createdUser];

        debugPrint(
          "New Personal User Saved to SQLite",
        );
      }

      // --------------------------------------
      // STEP 6: Validate candidate
      // --------------------------------------
      if (candidateUsers.isEmpty) {
        debugPrint(
          "No Candidate Available After Signup",
        );
        return false;
      }

      // --------------------------------------
      // STEP 7: Set actual candidate User ID
      // --------------------------------------
      GlobalClass.selected_member =
          candidateUsers.first.id;

      debugPrint(
        "Selected Candidate ID: "
            "${GlobalClass.selected_member}",
      );

      // --------------------------------------
      // STEP 8: Update HomeDataPreloader
      // --------------------------------------
      HomeDataPreloader.instance
          .seedCandidates(candidateUsers);

      debugPrint(
        "Signup Flow Completed Successfully",
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        "Complete Signup Flow Error: $e",
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }
}

// Singleton instance
final signUpService = SignUpService();*/

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/signUpResponses.dart';
import '../../data/models/user_models.dart';
import '../Global/global_class.dart';
import '../database/database_helper.dart';
import '../network/api_service.dart';
import '../storage/user_pref.dart';
import 'dashboard_report_status_controller.dart';
import 'homedataPreloader.dart';

class SignUpService {
  final ApiService _apiService;

  SignUpService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  String? tempToken;
  String? finalToken;
  String? receivedOtp;
  String? errorMessage;

  bool isAlreadyRegistered = false;

  SignUpResponseData? adminProfileData;
  User? adminProfileDatas;
  List<User> candidateUsers = [];

  // ==========================================
  // STEP 1: SEND OTP
  // GET /sendSignUpVeri
  // ==========================================
  Future<bool> sendOtp(String rawMobile) async {
    errorMessage = null;
    isAlreadyRegistered = false;
    tempToken = null;
    finalToken = null;
    receivedOtp = null;

    try {
      final response =
      await _apiService.sendSignUpVerification(
        mobile: rawMobile,
      );

      final data = response.data;

      if (response.statusCode == 200 && data != null) {
        tempToken = data['token']?.toString();

        receivedOtp =
            (data['otp'] ?? data['otpSession'])?.toString();

        if (tempToken == null || tempToken!.isEmpty) {
          errorMessage = 'OTP session token missing.';
          return false;
        }

        debugPrint('SIGNUP 1: OTP requested');
        return true;
      }

      errorMessage = 'Unexpected response from server';
      return false;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;

      final serverMsg =
          (body is Map ? body['error']?.toString() : null) ?? '';

      if (status == 400 || status == 409) {
        if (serverMsg.toLowerCase().contains('exist') ||
            serverMsg.toLowerCase().contains('exit')) {
          isAlreadyRegistered = true;

          errorMessage =
          'This number is already registered. Please sign in.';
        } else {
          errorMessage = serverMsg.isNotEmpty
              ? serverMsg
              : 'Invalid request';
        }
      } else if (
      e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        errorMessage =
        'Network problem. Please check your connection.';
      } else {
        errorMessage =
        'Something went wrong. Please try again.';
      }

      debugPrint('SIGNUP 1: OTP request failed ($status)');
      return false;
    } catch (e) {
      errorMessage =
      'Something went wrong. Please try again.';

      debugPrint('SIGNUP 1: $e');
      return false;
    }
  }

  // ==========================================
  // STEP 2: REGISTER USER
  // POST /register
  // ==========================================
  Future<bool> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
    required String otp,
  }) async {
    if (tempToken == null || tempToken!.isEmpty) {
      errorMessage =
      'OTP session expired. Request a new OTP.';
      return false;
    }

    try {
      final response = await _apiService.signUp(
        auth: tempToken!,
        signUpRequest: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'mobile': mobile,
          'password': password,
          'otp': otp,
          'userType': 'daksh',
        },
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        errorMessage = 'Registration failed.';
        return false;
      }

      final token = response.data?['token']?.toString();

      if (token == null || token.isEmpty) {
        errorMessage = 'Registration token missing.';
        return false;
      }

      finalToken = token;

      final prefs = await SharedPreferences.getInstance();

      final userPref = UserPref(prefs);

      await userPref.setToken(finalToken);

      debugPrint('SIGNUP 2: Registration succeeded');

      return true;
    } catch (e) {
      errorMessage =
      'Registration failed. If the account was created, sign in.';

      debugPrint('SIGNUP 2: $e');
      return false;
    }
  }

  // ==========================================
  // STEP 3: FETCH ADMIN PROFILE
  // GET /findAdminByLoginId
  //
  // Same as SignIn admin fetching
  // No candidate insertion here
  // ==========================================
  Future<SignUpResponseData?> fetchAdminData() async {
    if (finalToken == null) return null;

    try {
      final response =
      await _apiService.findAdminByLoginId(
        auth: finalToken!,
      );

      if (response.statusCode != 200 ||
          response.data == null) {
        debugPrint('SIGNUP 3: Admin API failed');
        return null;
      }

      final result =
      SignUpResponse2.fromJson(response.data);

      adminProfileData = result.data;

      debugPrint(
        'SIGNUP 3: Admin found = ${adminProfileData != null}',
      );

      debugPrint(
        'SIGNUP 3: Admin ID = ${adminProfileData?.id}',
      );

      return adminProfileData;
    } catch (e) {
      debugPrint('SIGNUP 3: Admin fetch error: $e');
      return null;
    }
  }

  // ==========================================
  // STEP 4: FETCH CANDIDATE LIST
  // GET /findFingerprintscanByAdmin
  //
  // Only fetch candidates
  // No SQLite insertion here
  // ==========================================
  Future<List<User>?> fetchUserCandidates() async {
    if (finalToken == null) return null;

    try {
      final response =
      await _apiService.findFingerPrintScanByAdmin(
        auth: finalToken!,
      );

      if (response.statusCode != 200 ||
          response.data == null) {
        debugPrint('SIGNUP 4: Candidate API failed');
        return null;
      }

      final rawCandidates = response.data['UserData'];

      // Missing list should not be considered empty
      if (rawCandidates is! List) {
        debugPrint(
          'SIGNUP 4: UserData missing or invalid',
        );
        return null;
      }

      // Remove duplicate candidates using actual User ID
      final uniqueCandidates = <String, User>{};

      for (final raw in rawCandidates) {
        if (raw is Map) {
          final user = User.fromJson(
            Map<String, dynamic>.from(raw),
          );

          final id = user.id.toString().trim();

          if (id.isNotEmpty &&
              id.toLowerCase() != 'null') {
            uniqueCandidates[id] = user;
          }
        }
      }

      // Do not create a new user if server returned
      // candidates but their IDs failed to parse
      if (rawCandidates.isNotEmpty &&
          uniqueCandidates.isEmpty) {
        debugPrint(
          'SIGNUP 4: API had candidates but no valid User IDs',
        );
        return null;
      }

      candidateUsers =
          uniqueCandidates.values.toList();

      debugPrint(
        'SIGNUP 4: API candidates = ${rawCandidates.length}',
      );

      debugPrint(
        'SIGNUP 4: Unique candidates = ${candidateUsers.length}',
      );

      return candidateUsers;
    } catch (e) {
      debugPrint(
        'SIGNUP 4: Candidate fetch error: $e',
      );
      return null;
    }
  }

  // ==========================================
  // STEP 5: SYNC PROFILE AND CANDIDATES
  //
  // Follow SignIn sequence:
  // Fetch Admin
  //     |
  // Fetch Candidates
  //     |
  // Existing -> Insert candidates
  // Empty -> Create user -> Insert created user
  //     |
  // Set selected_member
  //     |
  // Seed HomeDataPreloader
  // ==========================================
  Future<bool> _syncProfileAndCandidates() async {
    // STEP A: Fetch Admin
    final admin = await fetchAdminData();

    if (admin == null) {
      errorMessage =
      'Admin profile could not be loaded. Please sign in.';
      return false;
    }

    debugPrint(
      'SIGNUP 5: Admin fetched successfully',
    );

    // STEP B: Check candidates
    final existingCandidates =
    await fetchUserCandidates();

    if (existingCandidates == null) {
      errorMessage =
      'Candidate list could not be loaded. Please sign in.';
      return false;
    }

    // ======================================
    // CASE 1: CANDIDATES ALREADY EXIST
    // ======================================
    if (existingCandidates.isNotEmpty) {
      debugPrint(
        'SIGNUP 5: Existing candidates found: '
            '${existingCandidates.length}',
      );

      // Same method as working SignIn
      await DatabaseHelper.instance
          .insertCandidateMembers(existingCandidates);

      candidateUsers = existingCandidates;

      debugPrint(
        'SIGNUP 5: Existing candidates saved to SQLite',
      );
    }

    // ======================================
    // CASE 2: CANDIDATE LIST EMPTY
    // ======================================
    else {
      debugPrint(
        'SIGNUP 5: Candidate list empty',
      );

      final first = admin.firstName?.trim() ?? '';
      final last = admin.lastName?.trim() ?? '';
      final phone = admin.mobile?.trim() ?? '';

      if (first.isEmpty || phone.isEmpty) {
        errorMessage =
        'Admin profile is missing required details.';
        return false;
      }

      debugPrint(
        'SIGNUP 5: Creating personal user',
      );

      // STEP C: Create user personal
      final createResponse =
      await _apiService.createUserPersonal(
        auth: finalToken!,
        firstName: first,
        lastName: last,
        mobile: phone,
        dataName: '$first $last'.trim(),
      );

      if ((createResponse.statusCode != 200 &&
          createResponse.statusCode != 201) ||
          createResponse.data == null) {
        errorMessage =
        'Personal user creation failed. Please sign in.';
        return false;
      }

      // STEP D: Parse actual User response
      final createdResult =
      FingerScanResponse.fromJson(
        createResponse.data,
      );

      final User? createdUser = createdResult.data;

      final id =
          createdUser?.id.toString().trim() ?? '';

      if (createdUser == null ||
          id.isEmpty ||
          id.toLowerCase() == 'null') {
        errorMessage =
        'Created user response did not contain a valid ID.';
        return false;
      }

      debugPrint(
        'SIGNUP 5: New personal user created',
      );

      debugPrint(
        'SIGNUP 5: Actual User ID = $id',
      );

      // STEP E: Save actual created user in SQLite
      // Same method as working SignIn
      await DatabaseHelper.instance
          .insertOrUpdateAdminDetails(
        createdUser,
      );

      adminProfileDatas = createdUser;

      candidateUsers = [createdUser];

      debugPrint(
        'SIGNUP 5: Created personal user saved to SQLite',
      );
    }

    // ======================================
    // STEP F: Set candidate selection
    // ======================================
    if (candidateUsers.isEmpty) {
      errorMessage =
      'No candidate available after profile setup.';
      return false;
    }

    // Set actual User ID, not Admin ID
    GlobalClass.selected_member =
        candidateUsers.first.id;

    debugPrint(
      'SIGNUP 6: Selected User ID = '
          '${GlobalClass.selected_member}',
    );

    // ======================================
    // STEP G: Seed dashboard data
    // ======================================
    HomeDataPreloader.instance
        .seedCandidates(candidateUsers);

    debugPrint(
      'SIGNUP 6: Candidates seeded successfully',
    );

    return true;
  }

  // ==========================================
  // STEP 6: COMPLETE SIGNUP AND LOAD HOME
  //
  // Called from OtpDialog
  // ==========================================
  Future<bool> completeSignupAndLoadHome({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
    required String otp,
  }) async {
    errorMessage = null;

    try {
      // STEP 1: Register
      final registered = await registerUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        mobile: mobile,
        password: password,
        otp: otp,
      );

      if (!registered) {
        debugPrint(
          'SIGNUP: Registration failed',
        );
        return false;
      }
      else
        {
       /*   await DatabaseHelper.instance.clearAllData();

          GlobalClass.reset();

          await HomeDataPreloader.instance.clear();

          DashboardReportStatusController.instance.cancel();*/
          return true;
        }

      // STEP 2: Clear previous session


    /*  adminProfileData = null;
      adminProfileDatas = null;
      candidateUsers = [];

      // STEP 3: Sync admin + candidates
      final synced =
      await _syncProfileAndCandidates();

      if (!synced) {
        debugPrint(
          'SIGNUP: Profile setup failed after registration',
        );
        return false;
      }*/

      debugPrint(
        'SIGNUP: Registration + Profile Setup Complete',
      );

      return true;
    } catch (e, stackTrace) {
      errorMessage =
      'Registration or profile setup failed. '
          'If registered, please sign in.';

      debugPrint(
        'SIGNUP ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return false;
    }
  }
}

// Singleton instance
final signUpService = SignUpService();
