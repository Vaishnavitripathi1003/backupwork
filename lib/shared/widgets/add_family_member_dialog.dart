import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/database_helper.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/user_pref.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/user_models.dart';

class AddFamilyMemberDialog extends StatefulWidget {
  final ValueChanged<User>? onMemberAdded;

  const AddFamilyMemberDialog({
    super.key,
    this.onMemberAdded,
  });

  static Future<void> show(BuildContext context,
      {ValueChanged<User>? onMemberAdded}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddFamilyMemberDialog(onMemberAdded: onMemberAdded),
    );
  }

  @override
  State<AddFamilyMemberDialog> createState() => _AddFamilyMemberDialogState();
}

class _AddFamilyMemberDialogState extends State<AddFamilyMemberDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  int _selectedAvatarIndex = 2; // Default selected avatar
  String _selectedRole = 'Class 9 (High School)';
  bool _isAdding = false;

  final List<String> _avatars = ['👦', '👧', '👱‍♂️', '👶', '👨', '🧔', '👩', '👵'];

  final List<String> _roles = [
    'Class 6 (Middle School)',
    'Class 7 (Middle School)',
    'Class 8 (Middle School)',
    'Class 9 (High School)',
    'Class 10 (Board Exam)',
    'Class 11 (Senior Secondary)',
    'Class 12 (Career Prep)',
    'College Student',
    'Parent / Guardian',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleAddMember() async {
    final String name = _nameController.text.trim();
    final String mobile = _mobileController.text.trim();

    if (name.isEmpty) {
      _showSnack('Please enter a member name');
      return;
    }
    if (mobile.length != 10) {
      _showSnack('Please enter a valid 10 digit mobile number');
      return;
    }

    final String fullMobile = '+91$mobile';

    setState(() {
      _isAdding = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userPref = UserPref(prefs);
      final token = userPref.getToken() ?? '';

      User? newMemberUser;

      if (token.isNotEmpty) {
        // Step 1: Call API POST /fingerprintscan
        final response = await ApiService().createUserData(
          auth: token,
          firstName: name,
          lastName: '',
          mobile: fullMobile,
          dataName: name,
        );

        if (response.statusCode == 200 && response.data != null) {
          debugPrint('createUserData response: ${response.data}');
          final scanResponse = FingerScanResponse.fromJson(response.data);
          newMemberUser = scanResponse.data;
        }
      }

      // API failed / no token -> do not pretend it worked
      if (newMemberUser == null) {
        if (mounted) {
          setState(() => _isAdding = false);
        }
        _showSnack('Could not add member. Please try again.');
        return;
      }

      // Step 2: Save new member User into SQLite user_table
      final inserted =
      await DatabaseHelper.instance.insertCandidateMembers([newMemberUser]);

      if (inserted <= 0) {
        debugPrint('SQLite insert failed (result: $inserted)');
        if (mounted) {
          setState(() => _isAdding = false);
        }
        _showSnack('Could not save member locally. Please try again.');
        return;
      }

      debugPrint('Member saved successfully: ${newMemberUser.id}');

      if (mounted) {
        setState(() => _isAdding = false);

        // Step 3: tell HomeScreen to reload its list (this was missing before)
        widget.onMemberAdded?.call(newMemberUser);

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name added successfully')),
        );
      }
    } catch (e) {
      debugPrint('Add Member Error: $e');
      if (mounted) {
        setState(() => _isAdding = false);
      }
      _showSnack('Failed to add $name. Please try again.');
    }
  }

  InputDecoration _fieldDecoration({
    required String hint,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      counterText: '',
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = context.isNarrowMobile;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isNarrow ? 16 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Family Member',
                  style: TextStyle(
                    fontSize: context.scaleFont(18),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded,
                      size: 20, color: Color(0xFF94A3B8)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // 2. Select Avatar Section
            Text(
              'Select Avatar',
              style: TextStyle(
                fontSize: context.scaleFont(13),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(_avatars.length, (index) {
                    final bool isSelected = _selectedAvatarIndex == index;
                    return InkWell(
                      onTap: () => setState(() => _selectedAvatarIndex = index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4F46E5)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _avatars[index],
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. Member Name Input
            Text(
              'Member Name',
              style: TextStyle(
                fontSize: context.scaleFont(13),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: _fieldDecoration(hint: 'e.g. Rohan'),
            ),

            const SizedBox(height: 16),

            // 4. Mobile Number Input
            Text(
              'Mobile Number',
              style: TextStyle(
                fontSize: context.scaleFont(13),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: _fieldDecoration(
                hint: 'Enter Mobile number',
              //  prefixText: '+91  ',
              ),
            ),

            const SizedBox(height: 16),

            // 5. Role / Class Dropdown Input
          /*  Text(
              'Role / Class',
              style: TextStyle(
                fontSize: context.scaleFont(13),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),*/
          /*  Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF4F46E5), width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textPrimary),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                  items: _roles.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),*/

            // 6. Action Buttons (Cancel / Add Member)
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: const Color(0xFF334155),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isAdding ? null : _handleAddMember,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isAdding
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Add Member',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}