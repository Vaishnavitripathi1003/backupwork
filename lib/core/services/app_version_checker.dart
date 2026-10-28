import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateManager {
  // 📦 Application Package ID
  static const String appPackageName = "com.daksh.daksh";

  // 🌐 Backend API Version Check Endpoint
  static const String serverApiUrl = "https://apidaksh.dakshtest.com/api/admin/getByKey?key=app_version";

  // 🛒 Play Store Intent URLs
  static const String playStoreUrl = "market://details?id=$appPackageName";
  static const String fallbackPlayStoreUrl = "https://play.google.com/store/apps/details?id=$appPackageName";

  /// Main Entry Point: Call this inside initState() or postFrameCallback of your Home Screen
  static Future<void> checkForUpdates(BuildContext context) async {
    // Layer 1: Check Google Play Native In-App Immediate Update API
    bool googlePlayUpdateStarted = await _checkGooglePlayInAppUpdate();

    // Layer 2: If Google Play API didn't trigger an update, check backend version API
    if (!googlePlayUpdateStarted) {
      await _checkServerVersion(context);
    }
  }

  // ---------------------------------------------------------------------------
  // LAYER 1: Google Play In-App Immediate Update Overlay
  // ---------------------------------------------------------------------------
  static Future<bool> _checkGooglePlayInAppUpdate() async {
    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate(); // Full screen Play Store update overlay
          return true;
        }
      }
    } catch (e) {
      debugPrint("Google Play InAppUpdate Info Error: $e");
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // LAYER 2: Server API Version Key Check (`getByKey?key=app_version`)
  // ---------------------------------------------------------------------------
  static Future<void> _checkServerVersion(BuildContext context) async {
    try {
      // 1. Read local app version from package_info_plus (e.g. "2.1.9")
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String installedVersion = packageInfo.version;

      // 2. Query backend server for required version
      final response = await http.get(Uri.parse(serverApiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String serverVersion = data['value'] ?? data['version'];

        // 3. Compare installed vs required version
        if (_isVersionLower(installedVersion, serverVersion)) {
          if (context.mounted) {
            _showCustomUpdateDialog(context);
          }
        }
      }
    } catch (e) {
      debugPrint("Server Version Check Error: $e");
    }
  }

  // Version Comparison Helper ("2.1.9" vs "2.2.0")
  static bool _isVersionLower(String current, String required) {
    List<int> currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> requiredParts = required.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < requiredParts.length; i++) {
      int curr = i < currentParts.length ? currentParts[i] : 0;
      if (curr < requiredParts[i]) return true;
      if (curr > requiredParts[i]) return false;
    }
    return false;
  }

  // Redirect to Play Store (`market://details?id=com.daksh.daksh`)
  static Future<void> _goToPlayStore() async {
    try {
      final Uri playStoreUri = Uri.parse(playStoreUrl);
      if (await canLaunchUrl(playStoreUri)) {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(Uri.parse(fallbackPlayStoreUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      await launchUrl(Uri.parse(fallbackPlayStoreUrl), mode: LaunchMode.externalApplication);
    }
  }

  // ---------------------------------------------------------------------------
  // Custom Dialog (Replicating dialog_update.xml & 10-tap Developer Override!)
  // ---------------------------------------------------------------------------
  static void _showCustomUpdateDialog(BuildContext context) {
    int tapCount = 0;
    bool showSecretInput = false;
    final TextEditingController secretTokenController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Non-dismissible forced update
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return PopScope(
              canPop: false, // Disables back button
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: GestureDetector(
                  onTap: () {
                    tapCount++;
                    if (tapCount == 10) {
                      setState(() {
                        showSecretInput = true; // Secret 10-tap developer login
                      });
                    }
                  },
                  child: const Text(
                    "Update Required 🚀",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "A new version of Daksh is available on the Play Store. Please update to continue using the application.",
                    ),
                    if (showSecretInput) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: secretTokenController,
                        decoration: const InputDecoration(
                          hintText: "Enter Developer Token...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (tapCount < 10) {
                        _goToPlayStore();
                      } else {
                        // Developer Override Mode
                        String token = secretTokenController.text;
                        debugPrint("Developer Token Entered: $token");
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    child: Text(
                      tapCount < 10 ? "Update Now" : "Developer Login",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}