import 'package:daksh/features/screens/widgets/upgrade_plan_modal.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/language_manager.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/add_family_member_dialog.dart';

class HomeTopBar extends StatelessWidget {
  final UserProfile currentProfile;
  final ValueChanged<UserProfile>? onProfileTap;
  final String adminname;
  final bool isHindi;
  final VoidCallback? onLanguageToggle;

  const HomeTopBar({
    super.key,
    required this.currentProfile,
    required this.adminname,
    this.onProfileTap,
    this.isHindi = false,
    this.onLanguageToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = context.isNarrowMobile;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Builder(
            builder: (scaffoldContext) {
              return IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.menu_rounded, color: AppTheme.textPrimary, size: 22),
                onPressed: () {
                  Scaffold.of(scaffoldContext).openDrawer();
                },
              );
            },
          ),
        ),
        const SizedBox(width: 6),

        // Profile Dropdown Selector
        Expanded(
          child: InkWell(
            onTap: () {
              // Candidate changes are managed by the API/SQLite candidate selector.
              if (onProfileTap != null) onProfileTap!(currentProfile);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  // Avatar with online status dot
                  Stack(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEF08A),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(currentProfile.emoji, style: const TextStyle(fontSize: 15)),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22D3EE),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                //////////////////////////////////
                                adminname,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppTheme.textSecondary),
                          ],
                        ),
                      /*  Text(
                          currentProfile.role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9.5, color: AppTheme.textSecondary),
                        ),*/
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 4),

        // Notification Bell Icon Button
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textPrimary, size: 18),
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 4),

        // Language Toggle Pill Button
        if (onLanguageToggle != null) ...[
          GestureDetector(
            onTap: onLanguageToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded, size: 14, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 3),
                  Text(
                    isHindi ? 'हिन्दी' : 'EN',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4338CA),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],

        // Upgrade Pill Button
        GestureDetector(
          onTap: () => UpgradePlanModal.show(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isNarrow ? 6 : 8,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('👑', style: TextStyle(fontSize: 11)),
                const SizedBox(width: 3),
                Text(
                  LanguageManager.instance.strings.upgradePlan,
                  style: TextStyle(
                    fontSize: context.scaleFont(10.5),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SwitchProfileSection extends StatelessWidget {
  final UserProfile currentProfile;
  final ValueChanged<UserProfile> onProfileSelected;

  const SwitchProfileSection({
    super.key,
    required this.currentProfile,
    required this.onProfileSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Switch Profile',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              InkWell(
                onTap: () {
                /*  AddFamilyMemberDialog.show(
                    context,
                    onMemberAdded: onProfileSelected,
                  );*/
                },
                child: Row(
                  children: const [
                    Icon(Icons.settings_outlined, size: 14, color: AppTheme.primary),
                    SizedBox(width: 4),
                    Text(
                      'Manage Family',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Horizontal List of Profiles
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (final profile in <UserProfile>[currentProfile]) ...[
                  _ProfileAvatarItem(
                    profile: profile,
                    isSelected: profile.id == currentProfile.id,
                    onTap: () => onProfileSelected(profile),
                  ),
                  const SizedBox(width: 14),
                ],

              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatarItem extends StatelessWidget {
  final UserProfile profile;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileAvatarItem({
    required this.profile,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF08A).withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : const Color(0xFFE2E8F0),
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(profile.emoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            profile.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
            ),
          ),
          Text(
            profile.role,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMemberItem extends StatelessWidget {
  final VoidCallback onTap;

  const _AddMemberItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFC7D2FE),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Icon(Icons.add, size: 24, color: AppTheme.primary),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const Text(
            'Member',
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
