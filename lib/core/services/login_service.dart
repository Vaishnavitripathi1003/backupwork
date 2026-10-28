/*
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/signUpResponses.dart';
import '../../data/models/user_models.dart';
import '../database/database_helper.dart';
import '../enums/subscription_level.dart';
import '../network/api_service.dart';
import '../storage/user_pref.dart';

class LoginService {
  final ApiService _apiService;

  LoginService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  String? jwtToken;
  SignUpResponseData? adminProfileData;
  List<User> candidateUsers = [];

  // ==========================================
  // COMPLETE LOGIN FLOW (Steps 1 to 4)
  // ==========================================
  Future<bool> loginUserAndLoadHome({
    required String mobile,
    required String password,
  }) async {
    try {
      // ----------------------------------------------------
      // STEP 1: Login Request (GET /login)
      // ----------------------------------------------------
      final response =
          await _apiService.login(mobile: mobile, password: password);

      if (response.statusCode != 200 || response.data == null) {
        debugPrint("Step 1 Failed: Login Invalid Credentials");
        return false;
      }

      final loginData = response.data;
      if (loginData['token'] == null) {
        debugPrint("Step 1 Failed: No Token in response");
        return false;
      }

      jwtToken = loginData['token'].toString();
      final userData = loginData['data'];

      final prefs = await SharedPreferences.getInstance();
      final userPref = UserPref(prefs);
      await userPref.setToken(jwtToken);

      if (userData != null) {
        adminProfileData = SignUpResponseData.fromJson(userData);
        await DatabaseHelper.instance.insertOrUpdateAdminData(adminProfileData!);

        if (userData['subscriptionLevel'] != null) {
          final subLevelStr = userData['subscriptionLevel'].toString();
          final subLevel = SubscriptionLevel.fromValue(subLevelStr) ??
              SubscriptionLevel.level1;
          await userPref.setSubscription(subLevel);
        }
      }

      debugPrint("Step 1 Success: JWT Token Saved -> $jwtToken");

      // ----------------------------------------------------
      // STEP 2: Optional Check (PATCH /updateRegister)
      // ----------------------------------------------------
      final String? userType = userData?['userType']?.toString();
      final String? adminId = userData?['_id']?.toString();

      if (userType == null && adminId != null) {
        debugPrint("Step 2: userType is null, updating userType to 'daksh'...");
        await _apiService.updateRegister(
          auth: jwtToken!,
        );
      }

      // ----------------------------------------------------
      // STEP 3: Admin Profile Data (GET /findAdminByLoginId) -> SQLite Save
      // ----------------------------------------------------
      final adminResponse =
          await _apiService.findAdminByLoginId(auth: jwtToken!);
      if (adminResponse.statusCode == 200 && adminResponse.data != null) {
        final response2 = SignUpResponse2.fromJson(adminResponse.data);
        if (response2.data != null) {
          adminProfileData = response2.data;
          await DatabaseHelper.instance.insertOrUpdateAdminData(adminProfileData!);
          debugPrint(
              "Step 3 Success: Admin Profile Saved to SQLite -> ${adminProfileData?.firstName} ${adminProfileData?.lastName}");
        }
      }

      // ----------------------------------------------------
      // STEP 4: Candidates List Sync (GET /findFingerprintscanByAdmin) -> SQLite Save
      // ----------------------------------------------------
      final candidatesResponse =
          await _apiService.findFingerPrintScanByAdmin(auth: jwtToken!);
      if (candidatesResponse.statusCode == 200 && candidatesResponse.data != null) {
        final candidatesList =
            candidatesResponse.data?['UserData'] as List<dynamic>?;

        if (candidatesList != null) {
          candidateUsers = candidatesList
              .whereType<Map<String, dynamic>>()
              .map((map) => User.fromJson(map))
              .toList();
          print(
              "Step 4 Success: ${candidateUsers.length} Candidates Saved to SQLite");

          await DatabaseHelper.instance.insertCandidateMembers(candidateUsers);
          debugPrint(
              "Step 4 Success: ${candidateUsers.length} Candidates Saved to SQLite");
        }
      }

      // ----------------------------------------------------
      // ALL STEPS SUCCESSFUL -> Dashboard open!
      // ----------------------------------------------------
      return true;
    } catch (e) {
      debugPrint("Error in Login Flow: $e");
      return false;
    }
  }
}

final loginService = LoginService();
*//*
*/
/*

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/signUpResponses.dart';
import '../../data/models/user_models.dart';
import '../Global/global_class.dart';
import '../database/database_helper.dart';
import '../enums/subscription_level.dart';
import '../network/api_service.dart';
import '../storage/user_pref.dart';
import 'dashboard_report_status_controller.dart';
import 'homedataPreloader.dart';

class LoginService {
  final ApiService _apiService;

  LoginService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  String? jwtToken;
  SignUpResponseData? adminProfileData;
  List<User> candidateUsers = [];

  // ==========================================
  // COMPLETE LOGIN FLOW (Steps 1 to 4)
  // ==========================================
  Future<bool> loginUserAndLoadHome({
    required String mobile,
    required String password,
  }) async {
    try {
      // ----------------------------------------------------
      // STEP 1: Login Request (GET /login)
      // ----------------------------------------------------
      final response =
      await _apiService.login(mobile: mobile, password: password);

      if (response.statusCode != 200 || response.data == null) {
        debugPrint("Step 1 Failed: Login Invalid Credentials");
        return false;
      }

      final loginData = response.data;
      if (loginData['token'] == null) {
        debugPrint("Step 1 Failed: No Token in response");
        return false;
      }

      jwtToken = loginData['token'].toString();
      final userData = loginData['data'];

      final prefs = await SharedPreferences.getInstance();
      final userPref = UserPref(prefs);
      await userPref.setToken(jwtToken);

      // New login -> clear previous user's cached data, SQLite tables, & global selection
      await DatabaseHelper.instance.clearAllData();
      GlobalClass.reset();
      await HomeDataPreloader.instance.clear();
      DashboardReportStatusController.instance.cancel();

      if (userData != null) {
        adminProfileData = SignUpResponseData.fromJson(userData);
       // await DatabaseHelper.instance.insertOrUpdateAdminData(adminProfileData!);

        if (userData['subscriptionLevel'] != null) {
          final subLevelStr = userData['subscriptionLevel'].toString();
          final subLevel = SubscriptionLevel.fromValue(subLevelStr) ??
              SubscriptionLevel.level1;
          await userPref.setSubscription(subLevel);
        }
      }

      debugPrint("Step 1 Success: JWT Token Saved -> $jwtToken");

      // ----------------------------------------------------
      // STEP 2: Optional Check (PATCH /updateRegister)
      // (only runs when needed; kept before steps 3 & 4)
      // ----------------------------------------------------
      final String? userType = userData?['userType']?.toString();
      final String? adminId = userData?['_id']?.toString();

      if (userType == null && adminId != null) {
        debugPrint("Step 2: userType is null, updating userType to 'daksh'...");
        await _apiService.updateRegister(
          auth: jwtToken!,
        );
      }

      // ----------------------------------------------------
      // STEP 3 + STEP 4 run IN PARALLEL (they don't depend on each other)
      // ----------------------------------------------------
      await Future.wait([
        _syncAdminProfile(),
        //_syncCandidates(),
      ]);

      // ----------------------------------------------------
      // ALL STEPS SUCCESSFUL -> Dashboard open!
      // ----------------------------------------------------
      return true;
    } catch (e) {
      debugPrint("Error in Login Flow: $e");
      return false;
    }
  }

  // STEP 3: Admin Profile Data (GET /findAdminByLoginId) -> SQLite Save
  Future<void> _syncAdminProfile() async {
    final adminResponse =
    await _apiService.findAdminByLoginId(auth: jwtToken!);
    if (adminResponse.statusCode == 200 && adminResponse.data != null) {
      final response2 = SignUpResponse2.fromJson(adminResponse.data);
      if (response2.data != null) {
        adminProfileData = response2.data;
      //  await DatabaseHelper.instance.insertOrUpdateAdminData(adminProfileData!);
        debugPrint(
            "Step 3 Success: Admin Profile Saved to SQLite -> ${adminProfileData?.firstName} ${adminProfileData?.lastName}");

       await  _syncCandidates(adminProfileData);


      }
    }
  }

  // STEP 4: Candidates List Sync (GET /findFingerprintscanByAdmin) -> SQLite Save
  Future<void> _syncCandidates(SignUpResponseData? adminProfileData) async {
    final candidatesResponse =
    await _apiService.findFingerPrintScanByAdmin(auth: jwtToken!);
    if (candidatesResponse.statusCode == 200 && candidatesResponse.data != null) {
      final candidatesList =
      candidatesResponse.data?['UserData'] as List<dynamic>?;

      if (candidatesList != null && candidatesList.isNotEmpty) {
        candidateUsers = candidatesList
            .whereType<Map<String, dynamic>>()
            .map((map) => User.fromJson(map))
            .toList();

        await DatabaseHelper.instance.insertCandidateMembers(candidateUsers);
        GlobalClass.selected_member = candidateUsers.first.id;
        debugPrint(
            "Step 4 Success: ${candidateUsers.length} Candidates Saved to SQLite");

        HomeDataPreloader.instance.seedCandidates(candidateUsers);
      }
      else if (adminProfileData != null) {
final response2 = await _apiService.createUserPersonal(auth: jwtToken!, firstName: adminProfileData!.firstName!, lastName: adminProfileData!.lastName!, mobile: adminProfileData!.mobile!,  dataName: '${adminProfileData!.firstName! ?? ''} ${adminProfileData!.lastName}');
if (response2.statusCode == 200 && response2.data != null)
{
final
response3
=
FingerScanResponse
.
fromJson
(
response2
.
data
);
if
(
response3
.
data
!=
null
)
{
User
adminProfileDatas
=
response3
.
data
!;
if
(
adminProfileDatas
!=
null
)
{

///dmiadminProfileData!.id,adminProfileDatas!.id
await
DatabaseHelper
.
instance
.
insertOrUpdateAdminDetails
(
adminProfileDatas
!
);
GlobalClass
.
selected_member
=
adminProfileDatas
.
id;
HomeDataPreloader
.
instance
.
seedCandidates
(
[
adminProfileDatas
]
);
}
}
}


    }
  }


final loginService = LoginService();*//*


import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/signUpResponses.dart';
import '../../data/models/user_models.dart';
import '../Global/global_class.dart';
import '../constants/api_constants.dart';
import '../database/database_helper.dart';
import '../enums/subscription_level.dart';
import '../network/api_service.dart';
import '../storage/user_pref.dart';
import 'dashboard_report_status_controller.dart';
import 'firebase_notification_manager.dart';
import 'homedataPreloader.dart';

class LoginService {
  final ApiService _apiService;

  LoginService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  String? jwtToken;
  SignUpResponseData? adminProfileData;
  List<User> candidateUsers = [];

  // ==========================================
  // COMPLETE LOGIN FLOW (Steps 1 to 4)
  // ==========================================
  Future<bool> loginUserAndLoadHome({
    required String mobile,
    required String password,
  }) async {
    try {
      // ----------------------------------------------------
      // STEP 1: Login Request (GET /login)
      // ----------------------------------------------------
      final response = await _apiService.login(
        mobile: mobile,
        password: password,
      );

      if (response.statusCode != 200 || response.data == null) {
        debugPrint("Step 1 Failed: Login Invalid Credentials");
        return false;
      }

      final loginData = response.data;

      if (loginData['token'] == null) {
        debugPrint("Step 1 Failed: No Token in response");
        return false;
      }

      jwtToken = loginData['token'].toString();
      final userData = loginData['data'];

      final prefs = await SharedPreferences.getInstance();
      final userPref = UserPref(prefs);

      await userPref.setToken(jwtToken);

      try {
        await FirebaseNotificationManager().initialize(
          baseUrl: ApiConstants.baseUrl,
          userAuthToken: jwtToken!,
        );
      } catch (e) {
        debugPrint("Error initializing Firebase notification on login: $e");
      }

      // New login -> clear previous user's cached data,
      // SQLite tables, & global selection
      await DatabaseHelper.instance.clearAllData();
      GlobalClass.reset();
      await HomeDataPreloader.instance.clear();
      DashboardReportStatusController.instance.cancel();

      if (userData != null) {
        adminProfileData = SignUpResponseData.fromJson(userData);

        // await DatabaseHelper.instance
        //     .insertOrUpdateAdminData(adminProfileData!);

        if (userData['subscriptionLevel'] != null) {
          final subLevelStr =
          userData['subscriptionLevel'].toString();
          debugPrint("subscriptionLevel-> $subLevelStr");
          final subLevel =
              SubscriptionLevel.fromValue(subLevelStr) ??
                  SubscriptionLevel.level1;

          await userPref.setSubscription(subLevel);
        }
      }

      debugPrint("Step 1 Success: JWT Token Saved -> $jwtToken");

      // ----------------------------------------------------
      // STEP 2: Optional Check (PATCH /updateRegister)
      // ----------------------------------------------------
      final String? userType =
      userData?['userType']?.toString();

      final String? adminId =
      userData?['_id']?.toString();

      if (userType == null && adminId != null) {
        debugPrint(
          "Step 2: userType is null, updating userType to 'daksh'...",
        );

        await _apiService.updateRegister(
          auth: jwtToken!,
        );
      }

      // ----------------------------------------------------
      // STEP 3 + STEP 4
      // ----------------------------------------------------
      await Future.wait([
        _syncAdminProfile(),
        // _syncCandidates(),
      ]);

      // ----------------------------------------------------
      // ALL STEPS SUCCESSFUL -> Dashboard open!
      // ----------------------------------------------------
      return true;
    } catch (e) {
      debugPrint("Error in Login Flow: $e");
      return false;
    }
  }

  // ==========================================
  // STEP 3: Admin Profile Data
  // GET /findAdminByLoginId
  // ==========================================
  Future<void> _syncAdminProfile() async {
    final adminResponse =
    await _apiService.findAdminByLoginId(
      auth: jwtToken!,
    );

    if (adminResponse.statusCode == 200 &&
        adminResponse.data != null) {
      final response2 =
      SignUpResponse2.fromJson(adminResponse.data);

      if (response2.data != null) {
        adminProfileData = response2.data;

        // await DatabaseHelper.instance
        //     .insertOrUpdateAdminData(adminProfileData!);

        debugPrint(
          "Step 3 Success: Admin Profile Saved to SQLite -> "
              "${adminProfileData?.firstName} "
              "${adminProfileData?.lastName}",
        );

        await _syncCandidates(adminProfileData);
      }
    }
  }

  // ==========================================
  // STEP 4: Candidates List Sync
  // GET /findFingerprintscanByAdmin
  // ==========================================
  Future<void> _syncCandidates(SignUpResponseData? adminProfileData) async {
    final candidatesResponse =
    await _apiService.findFingerPrintScanByAdmin(
      auth: jwtToken!,
    );

    if (candidatesResponse.statusCode == 200 &&
        candidatesResponse.data != null) {
      final candidatesList =
      candidatesResponse.data?['UserData']
      as List<dynamic>?;

      // ======================================
      // CASE 1: Candidates Already Exist
      // ======================================
      if (candidatesList != null &&
          candidatesList.isNotEmpty) {
        candidateUsers = candidatesList
            .whereType<Map<String, dynamic>>()
            .map((map) => User.fromJson(map))
            .toList();

        await DatabaseHelper.instance.insertCandidateMembers(candidateUsers);

        for (final c in candidateUsers) {
          GlobalClass.scanStatus[c.id] = (c.isReportGenerated == true) ? "1" : "0";
        }







        GlobalClass.selected_member = candidateUsers.first.id;

        debugPrint("Step 4 Success: ""${candidateUsers.length} Candidates Saved to SQLite",
        );

        HomeDataPreloader.instance.seedCandidates(candidateUsers);
      }



      ///
      ///
      // ======================================
      // CASE 2: Create Personal User
      // ======================================
      else if (adminProfileData != null) {
        final response2 =
        await _apiService.createUserPersonal(
          auth: jwtToken!,
          firstName: adminProfileData.firstName!,
          lastName: adminProfileData.lastName!,
          mobile: adminProfileData.mobile!,
          dataName:
          '${adminProfileData.firstName! ?? ''} '
              '${adminProfileData.lastName}',
        );

        if (response2.statusCode == 200 &&
            response2.data != null) {
          final response3 =
          FingerScanResponse.fromJson(response2.data);

          if (response3.data != null) {
            User adminProfileDatas = response3.data!;

            if (adminProfileDatas != null) {
              /// dmiadminProfileData!.id, adminProfileDatas!.id

              await DatabaseHelper.instance
                  .insertOrUpdateAdminDetails(
                adminProfileDatas,
              );

              GlobalClass.scanStatus[adminProfileDatas.id] = (adminProfileDatas.isReportGenerated == true) ? "1" : "0";
              GlobalClass.selected_member =
                  adminProfileDatas.id;

              HomeDataPreloader.instance
                  .seedCandidates([adminProfileDatas]);
            } // if (adminProfileDatas != null)
          } // if (response3.data != null)
        } // if (response2.statusCode == 200)
      } // else if (adminProfileData != null)
    } // if (candidatesResponse.statusCode == 200)
  } // _syncCandidates()
} // LoginService class

final loginService = LoginService();
*/
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/signUpResponses.dart';
import '../../data/models/user_models.dart';
import '../Global/global_class.dart';
import '../database/database_helper.dart';
import '../enums/subscription_level.dart';
import '../network/api_service.dart';
import '../storage/user_pref.dart';
import 'dashboard_report_status_controller.dart';
import 'homedataPreloader.dart';

class LoginService {
  final ApiService _apiService;

  LoginService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  String? jwtToken;
  SignUpResponseData? adminProfileData;
  List<User> candidateUsers = [];

  // ==========================================
  // COMPLETE LOGIN FLOW (Steps 1 to 4)
  // ==========================================
  Future<bool> loginUserAndLoadHome({
    required String mobile,
    required String password,
  }) async {
    try {
      // ----------------------------------------------------
      // STEP 1: Login Request (GET /login)
      // ----------------------------------------------------
      final response = await _apiService.login(
        mobile: mobile,
        password: password,
      );

      if (response.statusCode != 200 || response.data == null) {
        debugPrint("Step 1 Failed: Login Invalid Credentials");
        return false;
      }

      final loginData = response.data;

      if (loginData['token'] == null) {
        debugPrint("Step 1 Failed: No Token in response");
        return false;
      }

      jwtToken = loginData['token'].toString();
      final userData = loginData['data'];

      final prefs = await SharedPreferences.getInstance();
      final userPref = UserPref(prefs);

      await userPref.setToken(jwtToken);

      // New login -> clear previous user's cached data,
      // SQLite tables, & global selection
      await DatabaseHelper.instance.clearAllData();
      GlobalClass.reset();
      await HomeDataPreloader.instance.clear();
      DashboardReportStatusController.instance.cancel();

      if (userData != null) {
        adminProfileData = SignUpResponseData.fromJson(userData);

        // await DatabaseHelper.instance
        //     .insertOrUpdateAdminData(adminProfileData!);

        if (userData['subscriptionLevel'] != null) {
          final subLevelStr = userData['subscriptionLevel'].toString();
          debugPrint("subscriptionLevel-> $subLevelStr");
          final subLevel = SubscriptionLevel.fromValue(subLevelStr) ??
              SubscriptionLevel.level1;

          await userPref.setSubscription(subLevel);
        }
      }

      debugPrint("Step 1 Success: JWT Token Saved -> $jwtToken");

      // ----------------------------------------------------
      // STEP 2: Optional Check (PATCH /updateRegister)
      // ----------------------------------------------------
      final String? userType = userData?['userType']?.toString();

      final String? adminId = userData?['_id']?.toString();

      if (userType == null && adminId != null) {
        debugPrint(
          "Step 2: userType is null, updating userType to 'daksh'...",
        );

        await _apiService.updateRegister(
          auth: jwtToken!,
        );
      }

      // ----------------------------------------------------
      // STEP 3 + STEP 4
      // ----------------------------------------------------
      await Future.wait([
        _syncAdminProfile(),
        // _syncCandidates(),
      ]);

      // ----------------------------------------------------
      // ALL STEPS SUCCESSFUL -> Dashboard open!
      // ----------------------------------------------------
      return true;
    } catch (e) {
      debugPrint("Error in Login Flow: $e");
      return false;
    }
  }

  // ==========================================
  // STEP 3: Admin Profile Data
  // GET /findAdminByLoginId
  // ==========================================
  Future<void> _syncAdminProfile() async {
    final adminResponse = await _apiService.findAdminByLoginId(
      auth: jwtToken!,
    );

    if (adminResponse.statusCode == 200 && adminResponse.data != null) {
      final response2 = SignUpResponse2.fromJson(adminResponse.data);

      if (response2.data != null) {
        adminProfileData = response2.data;

        // await DatabaseHelper.instance
        //     .insertOrUpdateAdminData(adminProfileData!);

        debugPrint(
          "Step 3 Success: Admin Profile Saved to SQLite -> "
              "${adminProfileData?.firstName} "
              "${adminProfileData?.lastName}",
        );

        await _syncCandidates(adminProfileData);
      }
    }
  }

  // ==========================================
  // STEP 4: Candidates List Sync
  // GET /findFingerprintscanByAdmin
  // ==========================================
  Future<void> _syncCandidates(SignUpResponseData? adminProfileData) async {
    final candidatesResponse = await _apiService.findFingerPrintScanByAdmin(
      auth: jwtToken!,
    );

    if (candidatesResponse.statusCode == 200 &&
        candidatesResponse.data != null) {
      final candidatesList =
      candidatesResponse.data?['UserData'] as List<dynamic>?;

      // ======================================
      // CASE 1: Candidates Already Exist
      // ======================================
      if (candidatesList != null && candidatesList.isNotEmpty) {
        candidateUsers = candidatesList
            .whereType<Map<String, dynamic>>()
            .map((map) => User.fromJson(map))
            .toList();

        // ---------- DEBUG: candidates ka poora data ----------
        debugPrint(
            '===== CANDIDATES RAW RESPONSE START (${candidatesList.length}) =====');
        for (int i = 0; i < candidatesList.length; i++) {
          // Raw server data (har field jo API se aaya)
          debugPrint('[$i] RAW -> ${jsonEncode(candidatesList[i])}');
        }
        debugPrint('===== CANDIDATES RAW RESPONSE END =====');

        debugPrint('===== PARSED USER MODEL START =====');
        for (int i = 0; i < candidateUsers.length; i++) {
          final c = candidateUsers[i];
          debugPrint(
            '[$i] PARSED -> id: ${c.id}, '
                'adminId: ${c.adminId}, '
                'firstName: ${c.firstName}, '
                'lastName: ${c.lastName}, '
                'dataName: ${c.dataName}, '
                'class: ${c.studdingClass}, '
                'status: ${c.status}, '
                'isReportGenerated: ${c.isReportGenerated}',
          );
        }
        debugPrint('===== PARSED USER MODEL END =====');
        // -----------------------------------------------------

        await DatabaseHelper.instance.insertCandidateMembers(candidateUsers);

        // ---------- DEBUG: SQLite me kya save hua ----------
        final saved = await DatabaseHelper.instance.getCandidateMembers();
        debugPrint('===== SQLITE SAVED START (${saved.length}) =====');
        for (final c in saved) {
          debugPrint(
            'SQLITE -> id: ${c.id}, '
                'status: ${c.status}, '
                'isReportGenerated: ${c.isReportGenerated}',
          );
        }
        debugPrint('===== SQLITE SAVED END =====');
        // ---------------------------------------------------

        for (final c in candidateUsers) {
          GlobalClass.scanStatus[c.id] =
          (c.isReportGenerated == true) ? "1" : "0";
        }

        GlobalClass.selected_member = candidateUsers.first.id;

        debugPrint(
          "Step 4 Success: "
              "${candidateUsers.length} Candidates Saved to SQLite",
        );

        HomeDataPreloader.instance.seedCandidates(candidateUsers);
      }


      else if (adminProfileData != null) {
        final response2 = await _apiService.createUserPersonal(
          auth: jwtToken!,
          firstName: adminProfileData.firstName!,
          lastName: adminProfileData.lastName!,
          mobile: adminProfileData.mobile!,
          dataName: '${adminProfileData.firstName! ?? ''} '
              '${adminProfileData.lastName}',
        );

        if (response2.statusCode == 200 && response2.data != null) {
          final response3 = FingerScanResponse.fromJson(response2.data);

          if (response3.data != null) {
            User adminProfileDatas = response3.data!;

            /// dmiadminProfileData!.id, adminProfileDatas!.id

            await DatabaseHelper.instance.insertOrUpdateAdminDetails(
              adminProfileDatas,
            );

            GlobalClass.scanStatus[adminProfileDatas.id] =
            (adminProfileDatas.isReportGenerated == true) ? "1" : "0";
            GlobalClass.selected_member = adminProfileDatas.id;

            HomeDataPreloader.instance.seedCandidates([adminProfileDatas]);
          } // if (response3.data != null)
        } // if (response2.statusCode == 200)
      } // else if (adminProfileData != null)
    } // if (candidatesResponse.statusCode == 200)
  } // _syncCandidates()
} // LoginService class

final loginService = LoginService();