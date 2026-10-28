/*

import 'package:daksh/data/models/multipleintellegenceResponse.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/Global/global_class.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/reportResponse.dart';
import '../../core/models/user_profile.dart';
import '../../core/network/api_service.dart';
import '../../core/services/ReportService.dart';
import '../../core/storage/user_pref.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/brainDominanceResponse.dart';
import '../../data/models/careerMatchResponse.dart';
import '../../data/models/personalityblenResponse.dart';
import '../../data/models/sensesAnalysisResponse.dart';
import '../../data/models/user_models.dart';
import '../../shared/widgets/add_family_member_dialog.dart';
import 'candidate_list_screen.dart';
import 'dmit_protocol_intro_screen.dart';
import 'widgets/ask_vayo_overlay.dart';
import 'widgets/brain_dominance_card.dart';
import 'widgets/career_match_card.dart';
import 'widgets/daksh_intelligence_drawer.dart';
import 'widgets/disc_swot_cards.dart';
import 'widgets/home_header.dart';
import 'widgets/intelligence_chart_card.dart';
import 'widgets/personality_blend_card.dart';
import 'widgets/senses_analysis_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onScanUploaded;

  const HomeScreen({super.key, this.onScanUploaded});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedMemberIndex = 0;
  String _adminFirstName = 'Aarav';
  List<User> _candidateMembers = [];
  ReportModel? _homeReportModel;
  bool _isLoadingHomeReport = false;
  PersonalityBlendResponse? _personalityBlend;
  MultipleIntelligenceResponse? _multipleIntelligenceResponse;
  SensesAnalysisResponse? _sensesAnalysis;
  BrainDominanceResponse? _brainDominanceResponse;
  CareerMatchResponse? _careerMatch;
  static const int _maxVisibleMembers = 10;
  bool isReportLoading= false;


  @override
  void initState() {
    super.initState();
    _loadAdminAndCandidatesFromSqlite();
  }

  double _toPercentage(double? val) {
    if (val == null) return 0.0;
    return val <= 1.0 ? (val * 100) : val;
  }

  Future<void> _loadAdminAndCandidatesFromSqlite({
    String? selectId,
    bool reloadReport = true,
  }) async {
    try {
      final keepId = selectId ?? (GlobalClass.selected_member.isNotEmpty ? GlobalClass.selected_member : _selectedCandidate?.id);

      var sqliteCandidates =
      await DatabaseHelper.instance.getCandidateMembers();
      debugPrint('SQLite candidates: ${sqliteCandidates.length}');

      if (!mounted) return;

      if (sqliteCandidates.isEmpty) {
        final admin = await DatabaseHelper.instance.getAdminData();
        if (admin != null) {
          final fallbackUser = User(
            id: admin.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
            adminId: admin.id ?? '',
            firstName: admin.firstName ?? 'Student',
            lastName: admin.lastName ?? '',
            dataName: '${admin.firstName ?? ''} ${admin.lastName ?? ''}'.trim(),
            email: admin.email,
            mobile: admin.mobile,
            isReportGenerated: false,
          );
          await DatabaseHelper.instance.insertCandidateMembers([fallbackUser]);
          sqliteCandidates = [fallbackUser];
        } else {
          setState(() {
            _candidateMembers = [];
            _selectedMemberIndex = 0;
            _homeReportModel = null;
            _personalityBlend = null;
            _careerMatch = null;
          });
          return;
        }
      }

      int idx = keepId == null
          ? 0
          : sqliteCandidates.indexWhere((c) => c.id == keepId);
      if (idx < 0) idx = 0;

      setState(() {
        _candidateMembers = sqliteCandidates;
        _selectedMemberIndex = idx;
      });

      if (reloadReport) {
        await _selectMember(idx);
      } else {
        GlobalClass.selected_member = sqliteCandidates[idx].id;
      }

    } catch (e) {
      debugPrint('Admin & candidates fetch exception: $e');
    }
  }

  User? get _selectedCandidate {
    if (_candidateMembers.isNotEmpty &&
        _selectedMemberIndex < _candidateMembers.length) {
      return _candidateMembers[_selectedMemberIndex];
    }
    return null;
  }

  bool get _isReportGenerated {
    return *//*

*/
/*false*//*
*/
/*
 _selectedCandidate?.isReportGenerated == true;
  }

  UserProfile get _selectedProfile {
    final candidate = _selectedCandidate;
    final name = _selectedMemberName;

    final primaryP = _homeReportModel?.personality?.primary.isNotEmpty == true
        ? _homeReportModel!.personality!.primary
        : 'Dominate';
    final secondaryP =
    _homeReportModel?.personality?.secondary.isNotEmpty == true
        ? _homeReportModel!.personality!.secondary
        : 'Influential';

    final rightB =
    _toPercentage(_homeReportModel?.brainDominance?.rightBrain ?? 0.62);
    final leftB =
    _toPercentage(_homeReportModel?.brainDominance?.leftBrain ?? 0.38);

    final vis = _toPercentage(_homeReportModel?.senses?.see ?? 0.88);
    final tch = _toPercentage(_homeReportModel?.senses?.touch ?? 0.82);

    return UserProfile(
      id: candidate?.id ?? '1',
      name: name,
      role: candidate?.studdingClass ?? 'Class 8',
      emoji: '👦',
      studentId: '#DK-9842',
      archetype: 'Visual–Kinesthetic Leader (High Logical Fluency)',
      personalityPrimary: primaryP,
      personalitySecondary: secondaryP,
      primaryPercent: 65,
      secondaryPercent: 35,
      strengthsCount: 12,
      weaknessesCount: 5,
      brainDominance: rightB >= leftB
          ? 'Right Brain Dominant (${rightB.toStringAsFixed(0)}%)'
          : 'Left Brain Dominant (${leftB.toStringAsFixed(0)}%)',
      sensoryPreference:
      'Vision (${vis.toStringAsFixed(0)}%) & Touch (${tch.toStringAsFixed(0)}%)',
      topCareerMatch: 'Software Engineer',
      careerMatchPercent: 94,
    );
  }

  String get _selectedMemberName {
    if (_candidateMembers.isNotEmpty &&
        _selectedMemberIndex < _candidateMembers.length) {
      final user = _candidateMembers[_selectedMemberIndex];
      return (user.dataName != null && user.dataName!.isNotEmpty)
          ? user.dataName!
          : (user.firstName != null && user.firstName!.isNotEmpty)
          ? user.firstName!
          : 'Aarav';
    }
    return _adminFirstName;
  }

  void _selectMember(int index) async {
    setState(() {
      _selectedMemberIndex = index;
    });

    if (_candidateMembers.isNotEmpty && index < _candidateMembers.length) {
      final selectedCandidate = _candidateMembers[index];
      final name = (selectedCandidate.dataName != null &&
          selectedCandidate.dataName!.isNotEmpty)
          ? selectedCandidate.dataName!
          : (selectedCandidate.firstName != null &&
          selectedCandidate.firstName!.isNotEmpty)
          ? selectedCandidate.firstName!
          : 'Aarav';

      GlobalClass.selected_member = selectedCandidate.id;
      debugPrint(
          "Selected active candidate member -> ID: ${selectedCandidate.id}, Name: $name, isReportGenerated: ${selectedCandidate.isReportGenerated}");

      //_loadHomeReportData();

      if(selectedCandidate.isReportGenerated==true)
      {
        await loadReportDataAccToCandidateIdAndParams();
      }


    }
  }

  void _openScanModeDialog() async {
    final bool? isSuccess = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DmitProtocolIntroScreen(
          candidateName: _selectedMemberName,
        ),
      ),
    );

    if (isSuccess == true && mounted) {
      final id = GlobalClass.selected_member;

      setState(() {
        isReportLoading = true;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = UserPref(prefs).getToken() ?? '';

        if (token.isNotEmpty && id.isNotEmpty) {
          bool isGenerated = false;

          // Continuously poll fetchReportStatus until isReportGenerated becomes true
          while (!isGenerated && mounted) {
            final statusResp = await ApiService().fetchReportStatus(
              auth: token,
              userDataId: id,
            );

            isGenerated = (statusResp.statusCode == 200 &&
                (statusResp.data['isReportGenerated'] == true ||
                    statusResp.data['isReportGenerated'].toString() == 'true'));

            debugPrint("fetchReportStatus -> candidate ID: $id isGenerated=$isGenerated");

            if (!isGenerated) {
              await Future.delayed(const Duration(seconds: 2));
            }
          }

          if (isGenerated && mounted) {
            // 1) Update isReportGenerated = 1 locally in SQLite user_table
            await DatabaseHelper.instance.updateReportGeneratedStatus(id, isGenerated);

            // 2) Reload candidates from SQLite
            await _loadAdminAndCandidatesFromSqlite(
              selectId: id,
              reloadReport: false,
            );

            // 3) Load fresh report data from server
            await loadReportDataAccToCandidateIdAndParams();
          }
        }
      } catch (e) {
        debugPrint("Error checking fetchReportStatus: $e");
      } finally {
        if (mounted) {
          setState(() {
            isReportLoading = false;
          });
        }
      }
    }
  }

  void _openAddMemberDialog() {
    AddFamilyMemberDialog.show(
      context,
      onMemberAdded: (newMember) {
        debugPrint('onMemberAdded fired -> ${newMember.id}');
        // reload list and select the member that was just added
        _loadAdminAndCandidatesFromSqlite(selectId: newMember.id);
      },
    );
  }

  /// Opens the full vertical candidate list (with search).
  /// Returns the tapped candidate's index in the original list.
  Future<void> _openAllCandidates() async {
    final picked = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => CandidateListScreen(
          candidates: _candidateMembers,
          selectedIndex: _selectedMemberIndex,
        ),
      ),
    );
    if (picked != null && mounted) {
      _selectMember(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double padding = context.scalePadding(16.0);
    final isNarrow = context.isNarrowMobile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const DakshIntelligenceDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Scrollable Body
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Bar Navigation Header
                  HomeTopBar(currentProfile: _selectedProfile),

                  const SizedBox(height: 16),

                  // 2. Greeting Card
                  _buildGreetingCard(context),

                  const SizedBox(height: 16),

                  // 3. Select Family Member Section
                  _buildFamilyMemberSelector(),

                  const SizedBox(height: 16),

                  // 4. Conditional Content (Loading vs Report Cards vs Hero Card)
                  if (isReportLoading) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFFFFF),
                            Color(0xFFF8FAFF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFFC7D2FE),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated glowing icon container
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFEEF2FF),
                                  Color(0xFFE0E7FF),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withValues(alpha: 0.20),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer pulsing ring
                                const SizedBox(
                                  width: 84,
                                  height: 84,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFC7D2FE),
                                    strokeWidth: 2,
                                    value: 1,
                                  ),
                                ),
                                // Inner spinning indicator
                                const SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF6366F1),
                                    strokeWidth: 4,
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                // Center AI icon
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Color(0xFF6366F1),
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Title
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                            ).createShader(bounds),
                            child: Text(
                              ' Your Report is Generating Soon ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.scaleFont(20),
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Subtitle with icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 15,
                                color: const Color(0xFF10B981).withValues(alpha: 0.9),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Fingerprints uploaded successfully',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: context.scaleFont(13),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Analyzing biometric data for $_selectedMemberName and building the your  Biometric Report...',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF64748B),
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Animated progress dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.3, end: 1.0),
                                duration: Duration(milliseconds: 600 + (index * 200)),
                                curve: Curves.easeInOut,
                                builder: (context, value, child) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.lerp(
                                        const Color(0xFFC7D2FE),
                                        const Color(0xFF6366F1),
                                        value,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF6366F1)
                                              .withValues(alpha: 0.4 * value),
                                          blurRadius: 8 * value,
                                          spreadRadius: 2 * value,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This may take a few moments',
                            style: TextStyle(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ] else if (_isReportGenerated) ...[
                    // Personality Blend Card
                    if (_personalityBlend != null &&
                        _personalityBlend!.report != null && _personalityBlend!.report!.personality!=null) ...[
                      PersonalityBlendCard(
                          personalityBlendData:
                          _personalityBlend!.report!.personality!),
                    ],
                    const SizedBox(height: 16),

                    // Locked Tier Warning Banner
                    const LockedWarningBanner(),
                    const SizedBox(height: 16),

                    if (_multipleIntelligenceResponse != null) ...[
                      // 8 Multiple Intelligence Chart Card
                      IntelligenceChartCard(
                        multipleIntelligenceData: _multipleIntelligenceResponse
                            ?.report?.multipleIntelligence,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 5 Senses Analysis Card
                    if (_sensesAnalysis != null &&
                        _sensesAnalysis!.report != null) ...[
                      SensesAnalysisCard(currentProfile: _sensesAnalysis!.report!.senses),
                      const SizedBox(height: 16),
                    ],

                    // Brain Dominance Card
                    if (_brainDominanceResponse != null &&
                        _brainDominanceResponse!.report != null) ...[
                      BrainDominanceCard(currentProfile: _brainDominanceResponse!.report!.brainDominance),
                      const SizedBox(height: 16),
                    ],

                    // DISC Analysis Card
                    *//*

*/
/* DiscAnalysisCard(currentProfile: _selectedProfile),
                    const SizedBox(height: 16),*//*
*/
/*


                    if (_personalityBlend != null &&
                        _personalityBlend!.swotAnalysis != null) ...[
                      // SWOT Analysis Card
                      SwotAnalysisCard(
                          swotAnalysis: _personalityBlend!.swotAnalysis!),
                      const SizedBox(height: 16),
                    ],

                    if (_careerMatch != null &&
                        _careerMatch!.report != null) ...[
                      CareerMatchCard(_careerMatch!.report!.career),
                      const SizedBox(height: 16),
                    ]
                  ] else ...[
                    // Hero DMIT Card for candidates whose report is not yet generated
                    _buildHeroDmitCard(context, isNarrow),
                    const SizedBox(height: 16),

                    // Scientific Notice Footer Card
                    _buildScientificNoticeCard(),
                    const SizedBox(height: 80),
                  ],
                ],
              ),
            ),

            // Floating "Ask Vayo" Badge on Bottom Right
            *//*

*/
/*const Positioned(
              right: 16,
              bottom: 20,
              child: AskVayoFloatingWidget(),
            ),*//*
*/
/*

          ],
        ),
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFEF08A),
                  border: Border.all(color: const Color(0xFF818CF8), width: 2),
                ),
                child: const Center(
                  child: Text('👦', style: TextStyle(fontSize: 24)),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Titles bound from real data
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text(
                      'Hi, $_selectedMemberName! 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: context.scaleFont(16.5),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _isReportGenerated ? 'Full Spectrum Validated' : 'Scan Pending',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildFamilyMemberSelector() {
    if (_candidateMembers.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'ACTIVE CANDIDATE PROFILE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _openAddMemberDialog,
                child: const Text(
                  '+ Add Member',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                  border:
                  Border.all(color: const Color(0xFF6366F1), width: 1.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('👦', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(
                      _adminFirstName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4338CA),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    final total = _candidateMembers.length;
    final hasMore = total > _maxVisibleMembers;

    // First 10 indices; keep the selected one visible if it was picked from the full list
    List<int> visible = List.generate(total, (i) => i);
    if (hasMore) {
      visible = visible.take(_maxVisibleMembers).toList();
      if (_selectedMemberIndex >= _maxVisibleMembers) {
        visible[_maxVisibleMembers - 1] = _selectedMemberIndex;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'SELECT FAMILY MEMBER TO ANALYZE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _openAddMemberDialog,
              child: const Text(
                '+ Add Member',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              ...visible.map((index) {
                final isSelected = _selectedMemberIndex == index;
                final user = _candidateMembers[index];
                final name =
                (user.dataName != null && user.dataName!.isNotEmpty)
                    ? user.dataName!
                    : (user.firstName != null && user.firstName!.isNotEmpty)
                    ? user.firstName!
                    : 'Candidate';

                return GestureDetector(
                  onTap: () => _selectMember(index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color:
                      isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('👦', style: TextStyle(fontSize: 15)),
                        const SizedBox(width: 6),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? const Color(0xFF4338CA)
                                : const Color(0xFF334155),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6366F1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),

              // "View more" chip, only when there are more than 10 candidates
              if (hasMore)
                GestureDetector(
                  onTap: _openAllCandidates,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View more (+${total - _maxVisibleMembers})',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 15, color: Colors.white),
                      ],
                    ),
                  ),
                ),

              // Add (+) Member Button
              GestureDetector(
                onTap: _openAddMemberDialog,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroDmitCard(BuildContext context, bool isNarrow) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.scalePadding(16)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E1B4B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Chips Row (Strict Horizontal Row with FittedBox / Flexible)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border:
                    Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.biotech_rounded,
                            color: Color(0xFF00E5FF), size: 14),
                        SizedBox(width: 4),
                        Text(
                          'DERMATOGLYPHICS PROTOCOL',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF00E5FF),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF78350F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const Text(
                      '0/10 Fingers Scanned',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFDE047),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Central Target Circle (SCAN READY)
          GestureDetector(
            onTap: _openScanModeDialog,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withValues(alpha: 0.25),
                    const Color(0xFF0F172A),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF00E5FF),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.fingerprint_rounded,
                    color: Color(0xFF00E5FF),
                    size: 38,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'SCAN READY',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Title
          Text(
            'Start Biometric Analysis',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.scaleFont(20),
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          // Subtitle
          Text(
            'Capture 10 fingerprints to calibrate $_selectedMemberName\'s inborn neocortex lobes and unlock all intelligence dimensions.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF94A3B8),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          // 2x2 Grid of Locked Matrices
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildLockedMatrixCard('🔷', '8 Intelligences'),
              _buildLockedMatrixCard('🧠', 'Brain Dominance'),
              _buildLockedMatrixCard('👁', '5 Senses (VAK)'),
              _buildLockedMatrixCard('🎯', 'DISC & Careers'),
            ],
          ),

          const SizedBox(height: 18),

          // Analysis Sequence List Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text('📜', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 8),
                    Text(
                      'Analysis Sequence:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSequenceStep('1', 'Review scientific  benefits'),
                const SizedBox(height: 6),
                _buildSequenceStep(
                    '2', 'Capture 10 epidermal ridge fingerprints'),
                const SizedBox(height: 6),
                _buildSequenceStep(
                    '3', 'Instant unlock of intelligence dashboard'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Primary Action Button (Start DMIT Analysis)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00E5FF),
                    Color(0xFF2563EB),
                    Color(0xFF7C3AED),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _openScanModeDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Start Analysis (Scan 10 Fingers)',
                          style: TextStyle(
                            fontSize: context.scaleFont(14),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bottom Trust Badges (Strict Horizontal Row with FittedBox)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _TrustBadge(
                    icon: Icons.shield_outlined, label: '100% Non-invasive'),
                SizedBox(width: 6),
                Text('•', style: TextStyle(color: Colors.white38)),
                SizedBox(width: 6),
                _TrustBadge(
                    icon: Icons.lock_outline, label: 'Zero Image Storage'),
                SizedBox(width: 6),
                // Text('•', style: TextStyle(color: Colors.white38)),
                *//*

*/
/* SizedBox(width: 6),
                _TrustBadge(icon: Icons.bolt_rounded, label: 'AI Synthesis'),*//*
*/
/*

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedMatrixCard(String icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: const [
                    Icon(Icons.lock_rounded,
                        color: Color(0xFFFDE047), size: 10),
                    SizedBox(width: 3),
                    Text(
                      'Locked',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFDE047),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceStep(String num, String text) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xFF00E5FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScientificNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('💡', style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Scientific Notice: Fingerprint epidermal ridges form synchronously with the cerebral neocortex during the 13th to 19th week of gestation. Complete the scan to calculate Total Finger Ridge Count (TFRC) and discover inborn cognitive capabilities.',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF1E40AF),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadReportDataAccToCandidateIdAndParams() async {
    await _loadPersonalityBlend();
    await _loadmultipleIntellegenceData();
    await _loadSensesAnalysis();
    await _loadBrainDominance();
    await _loadCareerMatch();
  }

  Future<void> _loadPersonalityBlend() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final parsed =
    await reportService.fetchPersonalityBlend(userDataId: candidate.id);

    // ignore the result if the user switched candidate while loading
    if (!mounted || _selectedCandidate?.id != candidate.id) return;

    setState(() => _personalityBlend = parsed);
    debugPrint(
      'personality_blend -> primary: ${parsed?.report?.personality?.primary}, '
          'secondary: ${parsed?.report?.personality?.secondary}',
    );
  }

  Future<void> _loadmultipleIntellegenceData() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final parsed =
    await reportService.fetchMultipleIntelligence(userDataId: candidate.id);
    if (!mounted || _selectedCandidate?.id != candidate.id) return;

    setState(() => _multipleIntelligenceResponse = parsed);
    debugPrint('multipleintellegence');
  }

  Future<void> _loadSensesAnalysis() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final result =
    await reportService.fetchSensesAnalysis(userDataId: candidate.id);

    // ignore the result if the user switched candidate while loading
    if (!mounted || _selectedCandidate?.id != candidate.id) return;
    setState(() => _sensesAnalysis = result);
    debugPrint('SENSES dominant -> ${result?.report?.senses?.dominant}');
  }

  Future<void> _loadBrainDominance() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final result =
    await reportService.fetchBrainDominance(userDataId: candidate.id);

    if (!mounted || _selectedCandidate?.id != candidate.id) return;
    setState(() => _brainDominanceResponse = result);
    debugPrint('BRAIN label -> ${result?.report?.brainDominance?.label}');
  }

  Future<void> _loadCareerMatch() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final result =
    await reportService.fetchCareerMatch(userDataId: candidate.id);

    // ignore the result if the user switched candidate while loading
    if (!mounted || _selectedCandidate?.id != candidate.id) return;

    setState(() => _careerMatch = result);

    final top = result?.report?.career?.topCategory;
    debugPrint('CAREER top category -> ${top?.name}, self: ${top?.self}');
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF38BDF8), size: 12),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}*//*

import 'package:daksh/data/models/multipleintellegenceResponse.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/Global/global_class.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/reportResponse.dart';
import '../../core/models/user_profile.dart';
import '../../core/network/api_service.dart';
import '../../core/services/ReportService.dart';
import '../../core/services/dashboard_report_status_controller.dart';
import '../../core/storage/user_pref.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/brainDominanceResponse.dart';
import '../../data/models/careerMatchResponse.dart';
import '../../data/models/personalityblenResponse.dart';
import '../../data/models/sensesAnalysisResponse.dart';
import '../../data/models/user_models.dart';
import '../../shared/widgets/add_family_member_dialog.dart';
import 'candidate_list_screen.dart';
import 'dmit_protocol_intro_screen.dart';
import 'widgets/ask_vayo_overlay.dart';
import 'widgets/brain_dominance_card.dart';
import 'widgets/career_match_card.dart';
import 'widgets/daksh_intelligence_drawer.dart';
import 'widgets/disc_swot_cards.dart';
import 'widgets/home_header.dart';
import 'widgets/intelligence_chart_card.dart';
import 'widgets/personality_blend_card.dart';
import 'widgets/senses_analysis_card.dart';

class HomeScreen extends StatefulWidget {
  /// Optional: scan upload successful hone par Dashboard ko batata hai
  /// (Dashboard Report tab kholta hai). Null ho to kuch nahi hota.
  final VoidCallback? onScanUploaded;

  const HomeScreen({super.key, this.onScanUploaded});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedMemberIndex = 0;
  String _adminFirstName = 'Aarav';
  List<User> _candidateMembers = [];
  ReportModel? _homeReportModel;
  bool _isLoadingHomeReport = false;
  PersonalityBlendResponse? _personalityBlend;
  MultipleIntelligenceResponse? _multipleIntelligenceResponse;
  SensesAnalysisResponse? _sensesAnalysis;
  BrainDominanceResponse? _brainDominanceResponse;
  CareerMatchResponse? _careerMatch;
  static const int _maxVisibleMembers = 10;
  bool isReportLoading = false;

  // Ek hi candidate ke "ready" event ko baar-baar handle hone se roko
  String? _handledReadyFor;

  @override
  void initState() {
    super.initState();
    DashboardReportStatusController.instance.state
        .addListener(_handleDashboardReportStatus);
    _loadAdminAndCandidatesFromSqlite();
  }

  @override
  void dispose() {
    DashboardReportStatusController.instance.state
        .removeListener(_handleDashboardReportStatus);
    super.dispose();
  }

  /// Dashboard ke Scan button se shuru hui report ka status sunta hai.
  /// waiting -> loading card, ready -> SQLite update + cards reload.
  Future<void> _handleDashboardReportStatus() async {
    if (!mounted) return;
    final flow = DashboardReportStatusController.instance.state.value;
    final id = flow.candidateId;
    if (id.isEmpty || id != GlobalClass.selected_member) return;

    if (flow.waitingFor(id)) {
      _handledReadyFor = null;
      // Purane candidate/report ka data na dikhe
      setState(() {
        isReportLoading = true;
        _homeReportModel = null;
        _personalityBlend = null;
        _multipleIntelligenceResponse = null;
        _sensesAnalysis = null;
        _brainDominanceResponse = null;
        _careerMatch = null;
      });
    } else if (flow.readyFor(id)) {
      if (_handledReadyFor == id) return;
      _handledReadyFor = id;

      // 1) Local SQLite me isReportGenerated = true
      await DatabaseHelper.instance.updateReportGeneratedStatus(id, true);
      if (!mounted) return;

      setState(() => isReportLoading = false);

      // 2) Candidates reload + report load (reloadReport default true)
      await _loadAdminAndCandidatesFromSqlite(selectId: id);
    } else if (flow.failedFor(id)) {
      setState(() => isReportLoading = false);
    }
  }

  double _toPercentage(double? val) {
    if (val == null) return 0.0;
    return val <= 1.0 ? (val * 100) : val;
  }

  Future<void> _loadAdminAndCandidatesFromSqlite({
    String? selectId,
    bool reloadReport = true,
  }) async {
    try {
      final keepId = selectId ?? _selectedCandidate?.id;

      final sqliteCandidates =
      await DatabaseHelper.instance.getCandidateMembers();
      debugPrint('SQLite candidates: ${sqliteCandidates.length}');

      if (!mounted || sqliteCandidates.isEmpty) return;

      int idx = keepId == null
          ? 0
          : sqliteCandidates.indexWhere((c) => c.id == keepId);
      if (idx < 0) idx = 0;

      setState(() {
        _candidateMembers = sqliteCandidates;

        _selectedMemberIndex = idx;
      });

      if (reloadReport) {
        _selectMember(idx);
      } else {
        GlobalClass.selected_member = sqliteCandidates[idx].id;
      }
    } catch (e) {
      debugPrint('Admin & candidates fetch exception: $e');
    }
  }

  User? get _selectedCandidate {
    if (_candidateMembers.isNotEmpty &&
        _selectedMemberIndex < _candidateMembers.length) {
      return _candidateMembers[_selectedMemberIndex];
    }
    return null;
  }

  bool get _isReportGenerated {
    return */
/*false*//*
 _selectedCandidate?.isReportGenerated == true;
  }

  UserProfile get _selectedProfile {
    final candidate = _selectedCandidate;
    final name = _selectedMemberName;

    final primaryP = _homeReportModel?.personality?.primary.isNotEmpty == true
        ? _homeReportModel!.personality!.primary
        : 'Dominate';
    final secondaryP =
    _homeReportModel?.personality?.secondary.isNotEmpty == true
        ? _homeReportModel!.personality!.secondary
        : 'Influential';

    final rightB =
    _toPercentage(_homeReportModel?.brainDominance?.rightBrain ?? 0.62);
    final leftB =
    _toPercentage(_homeReportModel?.brainDominance?.leftBrain ?? 0.38);

    final vis = _toPercentage(_homeReportModel?.senses?.see ?? 0.88);
    final tch = _toPercentage(_homeReportModel?.senses?.touch ?? 0.82);

    return UserProfile(
      id: candidate?.id ?? '1',
      name: name,
      role: candidate?.studdingClass ?? 'Class 8',
      emoji: '👦',
      studentId: '#DK-9842',
      archetype: 'Visual–Kinesthetic Leader (High Logical Fluency)',
      personalityPrimary: primaryP,
      personalitySecondary: secondaryP,
      primaryPercent: 65,
      secondaryPercent: 35,
      strengthsCount: 12,
      weaknessesCount: 5,
      brainDominance: rightB >= leftB
          ? 'Right Brain Dominant (${rightB.toStringAsFixed(0)}%)'
          : 'Left Brain Dominant (${leftB.toStringAsFixed(0)}%)',
      sensoryPreference:
      'Vision (${vis.toStringAsFixed(0)}%) & Touch (${tch.toStringAsFixed(0)}%)',
      topCareerMatch: 'Software Engineer',
      careerMatchPercent: 94,
    );
  }

  String get _selectedMemberName {
    if (_candidateMembers.isNotEmpty &&
        _selectedMemberIndex < _candidateMembers.length) {
      final user = _candidateMembers[_selectedMemberIndex];
      return (user.dataName != null && user.dataName!.isNotEmpty)
          ? user.dataName!
          : (user.firstName != null && user.firstName!.isNotEmpty)
          ? user.firstName!
          : 'Aarav';
    }
    return _adminFirstName;
  }

  void _selectMember(int index) async {
    setState(() {
      _selectedMemberIndex = index;
    });

    if (_candidateMembers.isNotEmpty && index < _candidateMembers.length) {
      final selectedCandidate = _candidateMembers[index];
      final name = (selectedCandidate.dataName != null &&
          selectedCandidate.dataName!.isNotEmpty)
          ? selectedCandidate.dataName!
          : (selectedCandidate.firstName != null &&
          selectedCandidate.firstName!.isNotEmpty)
          ? selectedCandidate.firstName!
          : 'Aarav';

      GlobalClass.selected_member = selectedCandidate.id;
      debugPrint(
          "Selected active candidate member -> ID: ${selectedCandidate.id}, Name: $name, isReportGenerated: ${selectedCandidate.isReportGenerated}");

      //_loadHomeReportData();

      if (selectedCandidate.isReportGenerated == true) {
        await loadReportDataAccToCandidateIdAndParams();
      }
    }
  }

  void _openScanModeDialog() async {
    final bool? isSuccess = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DmitProtocolIntroScreen(
          candidateName: _selectedMemberName,
        ),
      ),
    );

    if (isSuccess == true && mounted) {
      final id = GlobalClass.selected_member;

      // Dashboard ko batao: Report tab par chale jao.
      // (callback null ho to kuch nahi hoga). Polling neeche Home hi karega.
      widget.onScanUploaded?.call();

      setState(() {
        isReportLoading = true;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = UserPref(prefs).getToken() ?? '';

        if (token.isNotEmpty && id.isNotEmpty) {
          bool isGenerated = false;

          // Continuously poll fetchReportStatus until isReportGenerated becomes true
          while (!isGenerated && mounted) {
            final statusResp = await ApiService().fetchReportStatus(
              auth: token,
              userDataId: id,
            );

            isGenerated = (statusResp.statusCode == 200 &&
                (statusResp.data['isReportGenerated'] == true ||
                    statusResp.data['isReportGenerated'].toString() ==
                        'true'));

            debugPrint(
                "fetchReportStatus -> candidate ID: $id isGenerated=$isGenerated");

            if (!isGenerated) {
              await Future.delayed(const Duration(seconds: 2));
            }
          }

          if (isGenerated && mounted) {
            // 1) Update isReportGenerated = 1 locally in SQLite user_table
            await DatabaseHelper.instance
                .updateReportGeneratedStatus(id, isGenerated);

            // 2) Reload candidates from SQLite
            await _loadAdminAndCandidatesFromSqlite(
              selectId: id,
              reloadReport: false,
            );

            // 3) Load fresh report data from server
            await loadReportDataAccToCandidateIdAndParams();
          }
        }
      } catch (e) {
        debugPrint("Error checking fetchReportStatus: $e");
      } finally {
        if (mounted) {
          setState(() {
            isReportLoading = false;
          });
        }
      }
    }
  }

  void _openAddMemberDialog() {
    AddFamilyMemberDialog.show(
      context,
      onMemberAdded: (newMember) {
        debugPrint('onMemberAdded fired -> ${newMember.id}');
        // reload list and select the member that was just added
        _loadAdminAndCandidatesFromSqlite(selectId: newMember.id);
      },
    );
  }

  /// Opens the full vertical candidate list (with search).
  /// Returns the tapped candidate's index in the original list.
  Future<void> _openAllCandidates() async {
    final picked = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => CandidateListScreen(
          candidates: _candidateMembers,
          selectedIndex: _selectedMemberIndex,
        ),
      ),
    );
    if (picked != null && mounted) {
      _selectMember(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double padding = context.scalePadding(16.0);
    final isNarrow = context.isNarrowMobile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const DakshIntelligenceDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Scrollable Body
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Bar Navigation Header
                  HomeTopBar(currentProfile: _selectedProfile),

                  const SizedBox(height: 16),

                  // 2. Greeting Card
                  _buildGreetingCard(context),

                  const SizedBox(height: 16),

                  // 3. Select Family Member Section
                  _buildFamilyMemberSelector(),

                  const SizedBox(height: 16),

                  // 4. Conditional Content (Loading vs Report Cards vs Hero Card)
                  if (isReportLoading) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFFFFF),
                            Color(0xFFF8FAFF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFFC7D2FE),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1)
                                .withValues(alpha: 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: const Color(0xFF6366F1)
                                .withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated glowing icon container
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFEEF2FF),
                                  Color(0xFFE0E7FF),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1)
                                      .withValues(alpha: 0.20),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer pulsing ring
                                const SizedBox(
                                  width: 84,
                                  height: 84,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFC7D2FE),
                                    strokeWidth: 2,
                                    value: 1,
                                  ),
                                ),
                                // Inner spinning indicator
                                const SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF6366F1),
                                    strokeWidth: 4,
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                // Center AI icon
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Color(0xFF6366F1),
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Title
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                            ).createShader(bounds),
                            child: Text(
                              ' Your Report is Generating Soon ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.scaleFont(20),
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Subtitle with icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 15,
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.9),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Fingerprints uploaded successfully',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: context.scaleFont(13),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Analyzing biometric data for $_selectedMemberName and building the your  Biometric Report...',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF64748B),
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Animated progress dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.3, end: 1.0),
                                duration: Duration(
                                    milliseconds: 600 + (index * 200)),
                                curve: Curves.easeInOut,
                                builder: (context, value, child) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.lerp(
                                        const Color(0xFFC7D2FE),
                                        const Color(0xFF6366F1),
                                        value,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF6366F1)
                                              .withValues(alpha: 0.4 * value),
                                          blurRadius: 8 * value,
                                          spreadRadius: 2 * value,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'This may take a few moments',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ] else if (_isReportGenerated) ...[
                    // Personality Blend Card
                    if (_personalityBlend != null &&
                        _personalityBlend!.report != null &&
                        _personalityBlend!.report!.personality != null) ...[
                      PersonalityBlendCard(
                          personalityBlendData:
                          _personalityBlend!.report!.personality!),
                    ],
                    const SizedBox(height: 16),

                    // Locked Tier Warning Banner
                    const LockedWarningBanner(),
                    const SizedBox(height: 16),

                    if (_multipleIntelligenceResponse != null) ...[
                      // 8 Multiple Intelligence Chart Card
                      IntelligenceChartCard(
                        multipleIntelligenceData: _multipleIntelligenceResponse
                            ?.report?.multipleIntelligence,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 5 Senses Analysis Card
                    if (_sensesAnalysis != null &&
                        _sensesAnalysis!.report != null) ...[
                      SensesAnalysisCard(
                          currentProfile: _sensesAnalysis!.report!.senses),
                      const SizedBox(height: 16),
                    ],

                    // Brain Dominance Card
                    if (_brainDominanceResponse != null &&
                        _brainDominanceResponse!.report != null) ...[
                      BrainDominanceCard(
                          currentProfile:
                          _brainDominanceResponse!.report!.brainDominance),
                      const SizedBox(height: 16),
                    ],

                    // DISC Analysis Card
                    */
/* DiscAnalysisCard(currentProfile: _selectedProfile),
                    const SizedBox(height: 16),*//*


                    if (_personalityBlend != null &&
                        _personalityBlend!.swotAnalysis != null) ...[
                      // SWOT Analysis Card
                      SwotAnalysisCard(
                          swotAnalysis: _personalityBlend!.swotAnalysis!),
                      const SizedBox(height: 16),
                    ],

                    if (_careerMatch != null &&
                        _careerMatch!.report != null) ...[
                      CareerMatchCard(_careerMatch!.report!.career),
                      const SizedBox(height: 16),
                    ]
                  ] else ...[
                    // Hero DMIT Card for candidates whose report is not yet generated
                    _buildHeroDmitCard(context, isNarrow),
                    const SizedBox(height: 16),

                    // Scientific Notice Footer Card
                    _buildScientificNoticeCard(),
                    const SizedBox(height: 80),
                  ],
                ],
              ),
            ),

            // Floating "Ask Vayo" Badge on Bottom Right
            */
/*const Positioned(
              right: 16,
              bottom: 20,
              child: AskVayoFloatingWidget(),
            ),*//*

          ],
        ),
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFEF08A),
                  border: Border.all(color: const Color(0xFF818CF8), width: 2),
                ),
                child: const Center(
                  child: Text('👦', style: TextStyle(fontSize: 24)),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Titles bound from real data
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text(
                      'Hi, $_selectedMemberName! 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: context.scaleFont(16.5),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _isReportGenerated
                      ? 'Full Spectrum Validated'
                      : 'Scan Pending',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildFamilyMemberSelector() {
    if (_candidateMembers.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'ACTIVE CANDIDATE PROFILE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _openAddMemberDialog,
                child: const Text(
                  '+ Add Member',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                  border:
                  Border.all(color: const Color(0xFF6366F1), width: 1.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('👦', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(
                      _adminFirstName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4338CA),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    final total = _candidateMembers.length;
    final hasMore = total > _maxVisibleMembers;

    // First 10 indices; keep the selected one visible if it was picked from the full list
    List<int> visible = List.generate(total, (i) => i);
    if (hasMore) {
      visible = visible.take(_maxVisibleMembers).toList();
      if (_selectedMemberIndex >= _maxVisibleMembers) {
        visible[_maxVisibleMembers - 1] = _selectedMemberIndex;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'SELECT FAMILY MEMBER TO ANALYZE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _openAddMemberDialog,
              child: const Text(
                '+ Add Member',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              ...visible.map((index) {
                final isSelected = _selectedMemberIndex == index;
                final user = _candidateMembers[index];
                final name =
                (user.dataName != null && user.dataName!.isNotEmpty)
                    ? user.dataName!
                    : (user.firstName != null && user.firstName!.isNotEmpty)
                    ? user.firstName!
                    : 'Candidate';

                return GestureDetector(
                  onTap: () => _selectMember(index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color:
                      isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('👦', style: TextStyle(fontSize: 15)),
                        const SizedBox(width: 6),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? const Color(0xFF4338CA)
                                : const Color(0xFF334155),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6366F1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),

              // "View more" chip, only when there are more than 10 candidates
              if (hasMore)
                GestureDetector(
                  onTap: _openAllCandidates,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View more (+${total - _maxVisibleMembers})',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 15, color: Colors.white),
                      ],
                    ),
                  ),
                ),

              // Add (+) Member Button
              GestureDetector(
                onTap: _openAddMemberDialog,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroDmitCard(BuildContext context, bool isNarrow) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.scalePadding(16)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E1B4B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Chips Row (Strict Horizontal Row with FittedBox / Flexible)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border:
                    Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.biotech_rounded,
                            color: Color(0xFF00E5FF), size: 14),
                        SizedBox(width: 4),
                        Text(
                          'DERMATOGLYPHICS PROTOCOL',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF00E5FF),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF78350F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '0/10 Fingers Scanned',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFDE047),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Central Target Circle (SCAN READY)
          GestureDetector(
            onTap: _openScanModeDialog,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withValues(alpha: 0.25),
                    const Color(0xFF0F172A),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF00E5FF),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.fingerprint_rounded,
                    color: Color(0xFF00E5FF),
                    size: 38,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'SCAN READY',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Title
          Text(
            'Start Biometric Analysis',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.scaleFont(20),
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          // Subtitle
          Text(
            'Capture 10 fingerprints to calibrate $_selectedMemberName\'s inborn neocortex lobes and unlock all intelligence dimensions.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF94A3B8),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          // 2x2 Grid of Locked Matrices
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildLockedMatrixCard('🔷', '8 Intelligences'),
              _buildLockedMatrixCard('🧠', 'Brain Dominance'),
              _buildLockedMatrixCard('👁', '5 Senses (VAK)'),
              _buildLockedMatrixCard('🎯', 'DISC & Careers'),
            ],
          ),

          const SizedBox(height: 18),

          // Analysis Sequence List Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text('📜', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 8),
                    Text(
                      'Analysis Sequence:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSequenceStep('1', 'Review scientific  benefits'),
                const SizedBox(height: 6),
                _buildSequenceStep(
                    '2', 'Capture 10 epidermal ridge fingerprints'),
                const SizedBox(height: 6),
                _buildSequenceStep(
                    '3', 'Instant unlock of intelligence dashboard'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Primary Action Button (Start DMIT Analysis)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00E5FF),
                    Color(0xFF2563EB),
                    Color(0xFF7C3AED),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _openScanModeDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Start Analysis (Scan 10 Fingers)',
                          style: TextStyle(
                            fontSize: context.scaleFont(14),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bottom Trust Badges (Strict Horizontal Row with FittedBox)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _TrustBadge(
                    icon: Icons.shield_outlined, label: '100% Non-invasive'),
                SizedBox(width: 6),
                Text('•', style: TextStyle(color: Colors.white38)),
                SizedBox(width: 6),
                _TrustBadge(
                    icon: Icons.lock_outline, label: 'Zero Image Storage'),
                SizedBox(width: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedMatrixCard(String icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: const [
                    Icon(Icons.lock_rounded,
                        color: Color(0xFFFDE047), size: 10),
                    SizedBox(width: 3),
                    Text(
                      'Locked',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFDE047),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceStep(String num, String text) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xFF00E5FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScientificNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('💡', style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Scientific Notice: Fingerprint epidermal ridges form synchronously with the cerebral neocortex during the 13th to 19th week of gestation. Complete the scan to calculate Total Finger Ridge Count (TFRC) and discover inborn cognitive capabilities.',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF1E40AF),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadReportDataAccToCandidateIdAndParams() async {
    await _loadPersonalityBlend();
    await _loadmultipleIntellegenceData();
    await _loadSensesAnalysis();
    await _loadBrainDominance();
    await _loadCareerMatch();
  }

  Future<void> _loadPersonalityBlend() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final parsed =
    await reportService.fetchPersonalityBlend(userDataId: candidate.id);

    // ignore the result if the user switched candidate while loading
    if (!mounted || _selectedCandidate?.id != candidate.id) return;

    setState(() => _personalityBlend = parsed);
    debugPrint(
      'personality_blend -> primary: ${parsed?.report?.personality?.primary}, '
          'secondary: ${parsed?.report?.personality?.secondary}',
    );
  }

  Future<void> _loadmultipleIntellegenceData() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final parsed =
    await reportService.fetchMultipleIntelligence(userDataId: candidate.id);
    if (!mounted || _selectedCandidate?.id != candidate.id) return;

    setState(() => _multipleIntelligenceResponse = parsed);
    debugPrint('multipleintellegence');
  }

  Future<void> _loadSensesAnalysis() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final result =
    await reportService.fetchSensesAnalysis(userDataId: candidate.id);

    // ignore the result if the user switched candidate while loading
    if (!mounted || _selectedCandidate?.id != candidate.id) return;
    setState(() => _sensesAnalysis = result);
    debugPrint('SENSES dominant -> ${result?.report?.senses?.dominant}');
  }

  Future<void> _loadBrainDominance() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final result =
    await reportService.fetchBrainDominance(userDataId: candidate.id);

    if (!mounted || _selectedCandidate?.id != candidate.id) return;
    setState(() => _brainDominanceResponse = result);
    debugPrint('BRAIN label -> ${result?.report?.brainDominance?.label}');
  }

  Future<void> _loadCareerMatch() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final result =
    await reportService.fetchCareerMatch(userDataId: candidate.id);

    // ignore the result if the user switched candidate while loading
    if (!mounted || _selectedCandidate?.id != candidate.id) return;

    setState(() => _careerMatch = result);

    final top = result?.report?.career?.topCategory;
    debugPrint('CAREER top category -> ${top?.name}, self: ${top?.self}');
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF38BDF8), size: 12),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}*/
/*
import 'dart:ui';
import 'package:daksh/data/models/multipleintellegenceResponse.dart';
import 'package:daksh/features/screens/widgets/ask_vayo_overlay.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/Global/global_class.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/reportResponse.dart';
import '../../core/models/user_profile.dart';
import '../../core/network/api_service.dart';
import '../../core/services/ReportService.dart';
import '../../core/storage/user_pref.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/brainDominanceResponse.dart';
import '../../data/models/careerMatchResponse.dart';
import '../../data/models/finger_scan_status_model.dart';
import '../../data/models/personalityblenResponse.dart';
import '../../data/models/sensesAnalysisResponse.dart';
import '../../data/models/user_models.dart';
import '../../shared/widgets/add_family_member_dialog.dart';
import 'candidate_list_screen.dart';
import 'dmit_protocol_intro_screen.dart';
import 'widgets/brain_dominance_card.dart';
import 'widgets/career_match_card.dart';
import 'widgets/daksh_intelligence_drawer.dart';
import 'widgets/disc_swot_cards.dart';
import 'widgets/home_header.dart';
import 'widgets/intelligence_chart_card.dart';
import 'widgets/personality_blend_card.dart';
import 'widgets/senses_analysis_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

/// Public hai taaki Dashboard GlobalKey se `openScan()` call kar sake.
class HomeScreenState extends State<HomeScreen> {
  int _selectedMemberIndex = 0;
  final String _adminFirstName = '';
  List<User> _candidateMembers = [];
  ReportModel? _homeReportModel;
  PersonalityBlendResponse? _personalityBlend;
  MultipleIntelligenceResponse? _multipleIntelligenceResponse;
  SensesAnalysisResponse? _sensesAnalysis;
  BrainDominanceResponse? _brainDominanceResponse;
  CareerMatchResponse? _careerMatch;
  static const int _maxVisibleMembers = 10;
  static const int _maxPollAttempts = 300; // 60 x 2s = 2 minute
  bool isReportLoading = false;
  String? admin_name;
  final Map<String, String> _scanStatus = {};

  @override
  void initState() {
    super.initState();
    _loadAdminDataFromLocal();
    _loadAdminAndCandidatesFromSqlite();
    GlobalClass.selectedMemberNotifier.addListener(_onGlobalMemberChanged);
  }

  @override
  void dispose() {
    GlobalClass.selectedMemberNotifier.removeListener(_onGlobalMemberChanged);
    super.dispose();
  }

  void _onGlobalMemberChanged() {
    if (!mounted) return;
    final globalId = GlobalClass.selected_member;
    if (globalId.isEmpty) return;

    final currentId = _selectedCandidate?.id;
    if (currentId == globalId) return;

    final idx = _candidateMembers.indexWhere((c) => c.id == globalId);
    if (idx != -1) {
      _selectMember(idx);
    } else {
      _loadAdminAndCandidatesFromSqlite(
        selectId: globalId,
        reloadReport: true,
      );
    }
  }


  */
/* void openScan() {
    if (!mounted) return;

    if (isReportLoading) return; 
    _openScanModeDialog();
  }
*//*

  bool _isCheckingScan = false;

  Future<void> openScan() async {
    if (!mounted || isReportLoading || _isCheckingScan) return;

    _isCheckingScan = true;

    try {
      final selectedCandidate = _selectedCandidate;

      if (selectedCandidate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a candidate first.'),
          ),
        );
        return;
      }

      final candidateId = selectedCandidate.id;

      // Get latest candidate data from SQLite
      final candidates =
      await DatabaseHelper.instance.getCandidateMembers();

      if (!mounted) return;

      final index = candidates.indexWhere(
            (candidate) => candidate.id == candidateId,
      );

      if (index == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Candidate not found.'),
          ),
        );
        return;
      }

      final candidate = candidates[index];

      debugPrint(
        'Scan check -> Candidate ID: ${candidate.id}, '
            'isReportGenerated: ${candidate.isReportGenerated}',
      );

      // Update selected candidate status in local list
      final selectedIndex = _candidateMembers.indexWhere(
            (item) => item.id == candidateId,
      );

      if (selectedIndex != -1) {
        setState(() {
          _candidateMembers[selectedIndex] = candidate;
        });
      }

      // If report already generated, do not scan again
      */
/*     if (candidate.isReportGenerated == true) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Already Scanned'),
                  ),
                ],
              ),
              content: Text(
                '${candidate.dataName?.isNotEmpty == true ? candidate.dataName : candidate.firstName ?? "Candidate"} '
                    'has already been scanned.\n\n'
                    'Please check the generated report.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Check Report'),
                ),
              ],
            );
          },
        );

        return;
      }*//*


      if (candidate.isReportGenerated == true) {
        final candidateName = candidate.dataName?.isNotEmpty == true
            ? candidate.dataName!
            : (candidate.firstName?.isNotEmpty == true
            ? candidate.firstName!
            : 'Candidate');

        await showGeneralDialog<void>(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Already Scanned',
          barrierColor: Colors.black.withValues(alpha: 0.35),
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (dialogContext, animation, secondaryAnimation) {
            return const SizedBox.shrink();
          },
          transitionBuilder: (dialogContext, animation, secondaryAnimation,
              child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            );

            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.85,
                  end: 1.0,
                ).animate(curvedAnimation),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 12,
                    sigmaY: 12,
                  ),
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    insetPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1)
                                .withValues(alpha: 0.18),
                            blurRadius: 35,
                            spreadRadius: 2,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Glowing fingerprint icon
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF6366F1),
                                  Color(0xFF8B5CF6),
                                  Color(0xFF06B6D4),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.fingerprint_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),

                          const SizedBox(height: 22),

                          const Text(
                            'Already Scanned!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E1B4B),
                              letterSpacing: -0.4,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            '$candidateName has already completed '
                                'the fingerprint scanning process.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Glass status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF)
                                  .withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFC7D2FE),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF10B981),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Report Already Generated',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF4338CA),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Gradient action button
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF6366F1),
                                  Color(0xFF8B5CF6),
                                  Color(0xFF2563EB),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                              icon: const Icon(
                                Icons.assessment_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              label: const Text(
                                'Check Report',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );

        return;
      }
      // Report not generated -> allow scanning
      if (!mounted || _selectedCandidate?.id != candidateId) return;

      GlobalClass.selected_member = candidateId;

      await _openScanModeDialog();
    } catch (e) {
      debugPrint('Error checking scan status: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to check scan status. Please try again.'),
          ),
        );
      }
    } finally {
      _isCheckingScan = false;
    }
  }

  double _toPercentage(double? val) {
    if (val == null) return 0.0;
    return val <= 1.0 ? (val * 100) : val;
  }

  Future<void> _loadAdminAndCandidatesFromSqlite({
    String? selectId,
    bool reloadReport = true,
  }) async {
    try {
      final keepId = selectId ??
          (GlobalClass.selected_member.isNotEmpty
              ? GlobalClass.selected_member
              : _selectedCandidate?.id);

      final sqliteCandidates =
      await DatabaseHelper.instance.getCandidateMembers();
      debugPrint('SQLite candidates: ${sqliteCandidates.length}');

      if (!mounted || sqliteCandidates.isEmpty) return;

      int idx = keepId == null
          ? 0
          : sqliteCandidates.indexWhere((c) => c.id == keepId);
      if (idx < 0) idx = 0;

      setState(() {
        _candidateMembers = sqliteCandidates;
        _selectedMemberIndex = idx;
      });

      if (reloadReport) {
        _selectMember(idx);
      } else {
        GlobalClass.selected_member = sqliteCandidates[idx].id;
      }
    } catch (e) {
      debugPrint('Admin & candidates fetch exception: $e');
    }
  }

  User? get _selectedCandidate {
    if (_candidateMembers.isNotEmpty &&
        _selectedMemberIndex < _candidateMembers.length) {
      return _candidateMembers[_selectedMemberIndex];
    }
    return null;
  }

  bool get _isReportGenerated {
    return _selectedCandidate?.isReportGenerated == true;
  }
  bool get _isReportstatus {
    final candidate = _selectedCandidate;
    final value = candidate?.status == true;

    debugPrint(
      '_isReportstatus -> id: ${candidate?.id}, '
          'raw status: ${candidate?.status}, result: $value',
    );

    return value;
  }

  UserProfile get _selectedProfile {
    final candidate = _selectedCandidate;
    final name = _selectedMemberName;

    final primaryP = _homeReportModel?.personality?.primary.isNotEmpty == true
        ? _homeReportModel!.personality!.primary
        : 'Dominate';
    final secondaryP =
    _homeReportModel?.personality?.secondary.isNotEmpty == true
        ? _homeReportModel!.personality!.secondary
        : 'Influential';

    final rightB =
    _toPercentage(_homeReportModel?.brainDominance?.rightBrain ?? 0.62);
    final leftB =
    _toPercentage(_homeReportModel?.brainDominance?.leftBrain ?? 0.38);

    final vis = _toPercentage(_homeReportModel?.senses?.see ?? 0.88);
    final tch = _toPercentage(_homeReportModel?.senses?.touch ?? 0.82);

    return UserProfile(
      id: candidate?.id ?? '1',
      name: name,
      role: candidate?.studdingClass ?? 'Class 8',
      emoji: '👦',
      studentId: '#DK-9842',
      archetype: 'Visual–Kinesthetic Leader (High Logical Fluency)',
      personalityPrimary: primaryP,
      personalitySecondary: secondaryP,
      primaryPercent: 65,
      secondaryPercent: 35,
      strengthsCount: 12,
      weaknessesCount: 5,
      brainDominance: rightB >= leftB
          ? 'Right Brain Dominant (${rightB.toStringAsFixed(0)}%)'
          : 'Left Brain Dominant (${leftB.toStringAsFixed(0)}%)',
      sensoryPreference:
      'Vision (${vis.toStringAsFixed(0)}%) & Touch (${tch.toStringAsFixed(
          0)}%)',
      topCareerMatch: 'Software Engineer',
      careerMatchPercent: 94,
    );
  }

  String get _selectedMemberName {
    if (_candidateMembers.isNotEmpty &&
        _selectedMemberIndex < _candidateMembers.length) {
      final user = _candidateMembers[_selectedMemberIndex];
      return (user.dataName != null && user.dataName!.isNotEmpty)
          ? user.dataName!
          : (user.firstName != null && user.firstName!.isNotEmpty)
          ? user.firstName!
          : 'Aarav';
    }
    return _adminFirstName;
  }

  void _selectMember(int index) async {
    setState(() {
      _selectedMemberIndex = index;
    });

    if (_candidateMembers.isNotEmpty && index < _candidateMembers.length) {
      final selectedCandidate = _candidateMembers[index];
      final name = (selectedCandidate.dataName != null &&
          selectedCandidate.dataName!.isNotEmpty)
          ? selectedCandidate.dataName!
          : (selectedCandidate.firstName != null &&
          selectedCandidate.firstName!.isNotEmpty)
          ? selectedCandidate.firstName!
          : 'Aarav';

      GlobalClass.selected_member = selectedCandidate.id;
      debugPrint(
          "Selected active candidate member -> ID: ${selectedCandidate
              .id}, Name: $name, isReportGenerated: ${selectedCandidate
              .isReportGenerated}");

      if (selectedCandidate.isReportGenerated == true) {
        await loadReportDataAccToCandidateIdAndParams();
      }
    }
  }

  /// Scan screen -> upload success -> loading card -> status poll ->
  /// SQLite update -> candidates reload -> report cards load.
  Future<void> _openScanModeDialog() async {
    final bool? isSuccess = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            DmitProtocolIntroScreen(
              candidateName: _selectedMemberName,
            ),
      ),
    );

    final id = GlobalClass.selected_member;

    GlobalClass.scanStatus[id] = "2";



    if (isSuccess == true && mounted) {
      final id = GlobalClass.selected_member;
      setState(() {
        isReportLoading = true;
      });
      */
/*  final fingerScanStatusModel = FingerScanStatusModel();
      fingerScanStatusModel.userId = GlobalClass.selected_member;
      fingerScanStatusModel.fingerScanStatus = true;
      fingerScanStatusModel.createdAt = DateTime.now().toString();

      await DatabaseHelper.instance.saveFingerScanStatus(fingerScanStatusModel);

*//*

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = UserPref(prefs).getToken() ?? '';

        if (token.isNotEmpty && id.isNotEmpty) {
          bool isGenerated = false;
          int attempts = 0;

          // isReportGenerated true hone tak poll karo (max _maxPollAttempts)
          while (!isGenerated && mounted && attempts < _maxPollAttempts) {
            attempts++;
            final statusResp = await ApiService().fetchReportStatus(
              auth: token,
              userDataId: id,
            );

            isGenerated = (statusResp.statusCode == 200 &&
                (statusResp.data['isReportGenerated'] == true ||
                    statusResp.data['isReportGenerated'].toString() ==
                        'true'));

            debugPrint(
                "fetchReportStatus -> candidate ID: $id isGenerated=$isGenerated (attempt $attempts)");

            if (!isGenerated) {
              await Future.delayed(const Duration(seconds: 2));
            }
          }

          if (isGenerated && mounted) {
            // 1) SQLite user_table me isReportGenerated update
            await DatabaseHelper.instance.updateReportGeneratedStatus(id, isGenerated);

            // 2) SQLite se candidates reload
            await _loadAdminAndCandidatesFromSqlite(selectId: id, reloadReport: false,);

            // 3) Server se fresh report data
            await loadReportDataAccToCandidateIdAndParams();
          }
          else if (!isGenerated && mounted) {

          }
        }
      } catch (e) {
        debugPrint("Error checking fetchReportStatus: $e");
      } finally {
        if (mounted) {
          setState(() {
            isReportLoading = false;
          });
        }
      }
    }
  }

  void _openAddMemberDialog() {
    AddFamilyMemberDialog.show(
      context,
      onMemberAdded: (newMember) {
        debugPrint('onMemberAdded fired -> ${newMember.id}');
        _loadAdminAndCandidatesFromSqlite(selectId: newMember.id);
      },
    );
  }

  /// Opens the full vertical candidate list (with search).
  /// Returns the tapped candidate's index in the original list.
  Future<void> _openAllCandidates() async {
    final picked = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) =>
            CandidateListScreen(
              candidates: _candidateMembers,
              selectedIndex: _selectedMemberIndex,
            ),
      ),
    );
    if (picked != null && mounted) {
      _selectMember(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double padding = context.scalePadding(16.0);
    final isNarrow = context.isNarrowMobile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const DakshIntelligenceDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Scrollable Body
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Bar Navigation Header
                  if(admin_name!=null)...[
                    HomeTopBar(currentProfile: _selectedProfile,
                        adminname: admin_name!),
                  ],


                  const SizedBox(height: 16),

                  // 2. Greeting Card
                  _buildGreetingCard(context),

                  const SizedBox(height: 16),

                  // 3. Select Family Member Section
                  _buildFamilyMemberSelector(),

                  const SizedBox(height: 16),

                  // 4. Conditional Content (Loading vs Report Cards vs Hero Card)
                  if (_isReportstatus && !_isReportGenerated) ...[
                    _buildReportLoadingCard(context),
                    const SizedBox(height: 80),
                  ]
                  else
                    if (_isReportGenerated) ...[
                      // Personality Blend Card
                      if (_personalityBlend != null &&
                          _personalityBlend!.report != null &&
                          _personalityBlend!.report!.personality != null) ...[
                        PersonalityBlendCard(
                            personalityBlendData:
                            _personalityBlend!.report!.personality!),
                      ],
                      const SizedBox(height: 16),

                      // Locked Tier Warning Banner
                      const LockedWarningBanner(),
                      const SizedBox(height: 16),

                      if (_multipleIntelligenceResponse != null) ...[
                        // 8 Multiple Intelligence Chart Card
                        IntelligenceChartCard(
                          multipleIntelligenceData: _multipleIntelligenceResponse
                              ?.report?.multipleIntelligence,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 5 Senses Analysis Card
                      if (_sensesAnalysis != null &&
                          _sensesAnalysis!.report != null) ...[
                        SensesAnalysisCard(
                            currentProfile: _sensesAnalysis!.report!.senses),
                        const SizedBox(height: 16),
                      ],

                      // Brain Dominance Card
                      if (_brainDominanceResponse != null &&
                          _brainDominanceResponse!.report != null) ...[
                        BrainDominanceCard(
                            currentProfile:
                            _brainDominanceResponse!.report!.brainDominance),
                        const SizedBox(height: 16),
                      ],

                      if (_personalityBlend != null &&
                          _personalityBlend!.swotAnalysis != null) ...[
                        // SWOT Analysis Card
                        SwotAnalysisCard(
                            swotAnalysis: _personalityBlend!.swotAnalysis!),
                        const SizedBox(height: 16),
                      ],

                      if (_careerMatch != null &&
                          _careerMatch!.report != null) ...[
                        CareerMatchCard(_careerMatch!.report!.career),
                        const SizedBox(height: 16),
                      ],
                    ] else
                      ...[
                        // Hero DMIT Card for candidates whose report is not yet generated
                        _buildHeroDmitCard(context, isNarrow),
                        const SizedBox(height: 16),

                        // Scientific Notice Footer Card
                        _buildScientificNoticeCard(),
                        const SizedBox(height: 80),
                      ],

                  if(_personalityBlend!=null)...[
                     Positioned(
                      right: 16,
                      bottom: 20,
                      child: AskVayoFloatingWidget(_personalityBlend!.report!.personality!.primary,_personalityBlend!.report!.personality!.primary),
                    ),
                  ]

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportLoadingCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF8FAFF),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFC7D2FE),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated glowing icon container
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEEF2FF),
                  Color(0xFFE0E7FF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.20),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                SizedBox(
                  width: 84,
                  height: 84,
                  child: CircularProgressIndicator(
                    color: Color(0xFFC7D2FE),
                    strokeWidth: 2,
                    value: 1,
                  ),
                ),
                // Inner spinning indicator
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    color: Color(0xFF6366F1),
                    strokeWidth: 4,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Center AI icon
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF6366F1),
                  size: 22,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Title
          ShaderMask(
            shaderCallback: (bounds) =>
                const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ).createShader(bounds),
            child: Text(
              ' Your Report is Generating Soon ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.scaleFont(20),
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_rounded,
                size: 15,
                color: const Color(0xFF10B981).withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Fingerprints uploaded successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.scaleFont(13),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Analyzing data for $_selectedMemberName and building the your Report...',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Animated progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.3, end: 1.0),
                duration: Duration(milliseconds: 600 + (index * 200)),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.lerp(
                        const Color(0xFFC7D2FE),
                        const Color(0xFF6366F1),
                        value,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1)
                              .withValues(alpha: 0.4 * value),
                          blurRadius: 8 * value,
                          spreadRadius: 2 * value,
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 8),
          const Text(
            'This may take a few moments',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFEF08A),
                  border: Border.all(color: const Color(0xFF818CF8), width: 2),
                ),
                child: const Center(
                  child: Text('👦', style: TextStyle(fontSize: 24)),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Titles bound from real data
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text(
                      'Hi, $_selectedMemberName! 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: context.scaleFont(16.5),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _isReportGenerated
                      ? 'Full Spectrum Validated'
                      : 'Scan Pending',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildFamilyMemberSelector() {
    if (_candidateMembers.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'ACTIVE CANDIDATE PROFILE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _openAddMemberDialog,
                child: const Text(
                  '+ Add Member',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                  border:
                  Border.all(color: const Color(0xFF6366F1), width: 1.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('👦', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(
                      _adminFirstName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4338CA),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    final total = _candidateMembers.length;
    final hasMore = total > _maxVisibleMembers;

    // First 10 indices; keep the selected one visible if it was picked from the full list
    List<int> visible = List.generate(total, (i) => i);
    if (hasMore) {
      visible = visible.take(_maxVisibleMembers).toList();
      if (_selectedMemberIndex >= _maxVisibleMembers) {
        visible[_maxVisibleMembers - 1] = _selectedMemberIndex;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'SELECT FAMILY MEMBER TO ANALYZE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _openAddMemberDialog,
              child: const Text(
                '+ Add Member',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              ...visible.map((index) {
                final isSelected = _selectedMemberIndex == index;
                final user = _candidateMembers[index];
                final name =
                (user.dataName != null && user.dataName!.isNotEmpty)
                    ? user.dataName!
                    : (user.firstName != null && user.firstName!.isNotEmpty)
                    ? user.firstName!
                    : 'Candidate';

                return GestureDetector(
                  onTap: () => _selectMember(index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color:
                      isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('👦', style: TextStyle(fontSize: 15)),
                        const SizedBox(width: 6),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? const Color(0xFF4338CA)
                                : const Color(0xFF334155),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6366F1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),

              // "View more" chip, only when there are more than 10 candidates
              if (hasMore)
                GestureDetector(
                  onTap: _openAllCandidates,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View more (+${total - _maxVisibleMembers})',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 15, color: Colors.white),
                      ],
                    ),
                  ),
                ),

              // Add (+) Member Button
              GestureDetector(
                onTap: _openAddMemberDialog,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroDmitCard(BuildContext context, bool isNarrow) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.scalePadding(16)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E1B4B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Chips Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border:
                    Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.biotech_rounded,
                            color: Color(0xFF00E5FF), size: 14),
                        SizedBox(width: 4),
                        Text(
                          'DERMATOGLYPHICS PROTOCOL',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF00E5FF),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF78350F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '0/10 Fingers Scanned',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFDE047),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Central Target Circle (SCAN READY)
          */
/*GestureDetector(
            onTap: _openScanModeDialog,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withValues(alpha: 0.25),
                    const Color(0xFF0F172A),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF00E5FF),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fingerprint_rounded,
                    color: Color(0xFF00E5FF),
                    size: 38,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'SCAN READY',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),*//*

          GestureDetector(
            onTap: _openScanModeDialog,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withValues(alpha: 0.25),
                    const Color(0xFF0F172A),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF00E5FF),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo_4.png',
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'SCAN READY',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Title
          Text(
            'Start Analysis',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.scaleFont(20),
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          // Subtitle
          Text(
            'Capture 10 fingerprints to calibrate $_selectedMemberName\'s inborn neocortex lobes and unlock all intelligence dimensions.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF94A3B8),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          // 2x2 Grid of Locked Matrices
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildLockedMatrixCard('🔷', '8 Intelligences'),
              _buildLockedMatrixCard('🧠', 'Brain Dominance'),
              _buildLockedMatrixCard('👁', '5 Senses (VAK)'),
              _buildLockedMatrixCard('🎯', 'DISC & Careers'),
            ],
          ),

          const SizedBox(height: 18),

          // Analysis Sequence List Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('📜', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 8),
                    Text(
                      'Analysis Sequence:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSequenceStep('1', 'Review scientific  benefits'),
                const SizedBox(height: 6),
                _buildSequenceStep(
                    '2', 'Capture 10 epidermal ridge fingerprints'),
                const SizedBox(height: 6),
                _buildSequenceStep(
                    '3', 'Instant unlock of intelligence dashboard'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Primary Action Button (Start DMIT Analysis)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00E5FF),
                    Color(0xFF2563EB),
                    Color(0xFF7C3AED),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _openScanModeDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Start Analysis (Scan 10 Fingers)',
                          style: TextStyle(
                            fontSize: context.scaleFont(14),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bottom Trust Badges
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TrustBadge(
                    icon: Icons.shield_outlined, label: '100% Non-invasive'),
                SizedBox(width: 6),
                Text('•', style: TextStyle(color: Colors.white38)),
                SizedBox(width: 6),
                _TrustBadge(
                    icon: Icons.lock_outline, label: 'Zero Image Storage'),
                SizedBox(width: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedMatrixCard(String icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 1),
                const Row(
                  children: [
                    Icon(Icons.lock_rounded,
                        color: Color(0xFFFDE047), size: 10),
                    SizedBox(width: 3),
                    Text(
                      'Locked',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFDE047),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceStep(String num, String text) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xFF00E5FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScientificNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💡', style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Scientific Notice: Fingerprint epidermal ridges form synchronously with the cerebral neocortex during the 13th to 19th week of gestation. Complete the scan to calculate Total Finger Ridge Count (TFRC) and discover inborn cognitive capabilities.',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF1E40AF),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadReportDataAccToCandidateIdAndParams() async {
    await _loadPersonalityBlend();
    await _loadmultipleIntellegenceData();
    await _loadSensesAnalysis();
    await _loadBrainDominance();
    await _loadCareerMatch();
  }


  /// Called by Dashboard when user returns to Home (e.g. from Profile).
  /// Reloads only the candidate list from SQLite and keeps the selected member.
  /// The report is refetched only if the selected member changed
  /// (for example, the old one was deleted in Profile).
  Future<void> reloadCandidates() async {
    if (!mounted) return;

    final previousId = _selectedCandidate?.id;

    await _loadAdminAndCandidatesFromSqlite(
      selectId: previousId,
      reloadReport: false,
    );

    if (!mounted) return;

    if (_selectedCandidate?.id != previousId) {
      _selectMember(_selectedMemberIndex);
    }
  }

  Future<void> _loadPersonalityBlend() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final parsed =
    await reportService.fetchPersonalityBlend(userDataId: candidate.id);

    // ignore the result if the user switched candidate while loading
    if (!mounted || _selectedCandidate?.id != candidate.id) return;

    setState(() => _personalityBlend = parsed);
    debugPrint(
      'personality_blend -> primary: ${parsed?.report?.personality?.primary}, '
          'secondary: ${parsed?.report?.personality?.secondary}',
    );
  }

  Future<void> _loadmultipleIntellegenceData() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final parsed =
    await reportService.fetchMultipleIntelligence(userDataId: candidate.id);
    if (!mounted || _selectedCandidate?.id != candidate.id) return;

    setState(() => _multipleIntelligenceResponse = parsed);
    debugPrint('multipleintellegence');
  }

  Future<void> _loadSensesAnalysis() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final result =
    await reportService.fetchSensesAnalysis(userDataId: candidate.id);

    if (!mounted || _selectedCandidate?.id != candidate.id) return;
    setState(() => _sensesAnalysis = result);
    debugPrint('SENSES dominant -> ${result?.report?.senses?.dominant}');
  }

  Future<void> _loadBrainDominance() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final result =
    await reportService.fetchBrainDominance(userDataId: candidate.id);

    if (!mounted || _selectedCandidate?.id != candidate.id) return;
    setState(() => _brainDominanceResponse = result);
    debugPrint('BRAIN label -> ${result?.report?.brainDominance?.label}');
  }

  Future<void> _loadCareerMatch() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final result =
    await reportService.fetchCareerMatch(userDataId: candidate.id);

    if (!mounted || _selectedCandidate?.id != candidate.id) return;

    setState(() => _careerMatch = result);

    final top = result?.report?.career?.topCategory;
    debugPrint('CAREER top category -> ${top?.name}, self: ${top?.self}');
  }

  Future<void> _loadAdminDataFromLocal() async {
    try {
      final admin = await DatabaseHelper.instance.getAdmin();
      admin_name=admin!.firstName;
    } catch (e) {
      debugPrint('Profile: admin load error: $e');
    }
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF38BDF8), size: 12),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}*/
import 'dart:ui';
import 'package:daksh/data/models/multipleintellegenceResponse.dart';
import 'package:daksh/features/screens/widgets/ask_vayo_overlay.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/Global/global_class.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/language_manager.dart';
import '../../core/native/biometric_scanner.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/reportResponse.dart';
import '../../core/models/user_profile.dart';
import '../../core/network/api_service.dart';
import '../../core/services/ReportService.dart';
import '../../core/storage/user_pref.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/brainDominanceResponse.dart';
import '../../data/models/careerMatchResponse.dart';
import '../../data/models/finger_scan_status_model.dart';
import '../../data/models/personalityblenResponse.dart';
import '../../data/models/sensesAnalysisResponse.dart';
import '../../data/models/user_models.dart';
import '../../shared/widgets/add_family_member_dialog.dart';
import 'candidate_list_screen.dart';
import 'dmit_protocol_intro_screen.dart';
import 'widgets/brain_dominance_card.dart';
import 'widgets/career_match_card.dart';
import 'widgets/daksh_intelligence_drawer.dart';
import 'widgets/disc_swot_cards.dart';
import 'widgets/home_header.dart';
import 'widgets/intelligence_chart_card.dart';
import 'widgets/personality_blend_card.dart';
import 'widgets/senses_analysis_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

/// Public hai taaki Dashboard GlobalKey se `openScan()` call kar sake.
class HomeScreenState extends State<HomeScreen> {
  int _selectedMemberIndex = 0;
  final String _adminFirstName = '';
  List<User> _candidateMembers = [];
  ReportModel? _homeReportModel;
  PersonalityBlendResponse? _personalityBlend;
  MultipleIntelligenceResponse? _multipleIntelligenceResponse;
  SensesAnalysisResponse? _sensesAnalysis;
  BrainDominanceResponse? _brainDominanceResponse;
  CareerMatchResponse? _careerMatch;
  static const int _maxVisibleMembers = 10;
  static const int _maxPollAttempts = 300; // 300 x 2s = 10 minute
  String? admin_name;
  bool _isHindi = false;
  final Map<String, String> _scanStatus = {};

  // Jin candidates ka report status abhi poll ho raha hai (duplicate polling roke)
  final Set<String> _pollingIds = {};

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
    _loadAdminDataFromLocal();
    _loadAdminAndCandidatesFromSqlite();
    GlobalClass.selectedMemberNotifier.addListener(_onGlobalMemberChanged);
  }

  Future<void> _loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userPref = UserPref(prefs);
      if (mounted) {
        setState(() {
          _isHindi = userPref.getHindiReport();
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userPref = UserPref(prefs);
      await userPref.toggleLanguage();
      if (mounted) {
        setState(() {
          _isHindi = userPref.getHindiReport();
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    GlobalClass.selectedMemberNotifier.removeListener(_onGlobalMemberChanged);
    super.dispose();
  }

  void _onGlobalMemberChanged() {
    if (!mounted) return;
    final globalId = GlobalClass.selected_member;
    if (globalId.isEmpty) return;

    final currentId = _selectedCandidate?.id;
    if (currentId == globalId) return;

    final idx = _candidateMembers.indexWhere((c) => c.id == globalId);
    if (idx != -1) {
      _selectMember(idx);
    } else {
      _loadAdminAndCandidatesFromSqlite(
        selectId: globalId,
        reloadReport: true,
      );
    }
  }

  bool _isCheckingScan = false;

  Future<void> openScan() async {
    if (!mounted || _showReportLoading || _isCheckingScan) return;

    _isCheckingScan = true;

    try {
      final selectedCandidate = _selectedCandidate;

      if (selectedCandidate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a candidate first.'),
          ),
        );
        return;
      }

      final candidateId = selectedCandidate.id;

      // Get latest candidate data from SQLite
      final candidates = await DatabaseHelper.instance.getCandidateMembers();

      if (!mounted) return;

      final index = candidates.indexWhere(
            (candidate) => candidate.id == candidateId,
      );

      if (index == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Candidate not found.'),
          ),
        );
        return;
      }

      final candidate = candidates[index];

      debugPrint(
        'Scan check -> Candidate ID: ${candidate.id}, '
            'isReportGenerated: ${candidate.isReportGenerated}',
      );

      // Update selected candidate status in local list
      final selectedIndex = _candidateMembers.indexWhere(
            (item) => item.id == candidateId,
      );

      if (selectedIndex != -1) {
        setState(() {
          _candidateMembers[selectedIndex] = candidate;
        });
      }

      // If report already generated, do not scan again
      if (candidate.isReportGenerated == true) {
        final candidateName = candidate.dataName?.isNotEmpty == true
            ? candidate.dataName!
            : (candidate.firstName?.isNotEmpty == true
            ? candidate.firstName!
            : 'Candidate');

        await showGeneralDialog<void>(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Already Scanned',
          barrierColor: Colors.black.withValues(alpha: 0.35),
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (dialogContext, animation, secondaryAnimation) {
            return const SizedBox.shrink();
          },
          transitionBuilder:
              (dialogContext, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            );

            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.85,
                  end: 1.0,
                ).animate(curvedAnimation),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 12,
                    sigmaY: 12,
                  ),
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    insetPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1)
                                .withValues(alpha: 0.18),
                            blurRadius: 35,
                            spreadRadius: 2,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Glowing fingerprint icon
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF6366F1),
                                  Color(0xFF8B5CF6),
                                  Color(0xFF06B6D4),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.fingerprint_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),

                          const SizedBox(height: 22),

                          const Text(
                            'Already Scanned!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E1B4B),
                              letterSpacing: -0.4,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            '$candidateName has already completed '
                                'the fingerprint scanning process.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Glass status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF)
                                  .withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFC7D2FE),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF10B981),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Report Already Generated',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF4338CA),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Gradient action button
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF6366F1),
                                  Color(0xFF8B5CF6),
                                  Color(0xFF2563EB),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                              icon: const Icon(
                                Icons.assessment_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              label: const Text(
                                'Check Report',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );

        return;
      }

      // Report not generated -> allow scanning
      if (!mounted || _selectedCandidate?.id != candidateId) return;

      GlobalClass.selected_member = candidateId;

      await _openScanModeDialog();
    } catch (e) {
      debugPrint('Error checking scan status: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to check scan status. Please try again.'),
          ),
        );
      }
    } finally {
      _isCheckingScan = false;
    }
  }

  double _toPercentage(double? val) {
    if (val == null) return 0.0;
    return val <= 1.0 ? (val * 100) : val;
  }

  Future<void> _loadAdminAndCandidatesFromSqlite({
    String? selectId,
    bool reloadReport = true,
  }) async {
    try {
      final keepId = selectId ??
          (GlobalClass.selected_member.isNotEmpty
              ? GlobalClass.selected_member
              : _selectedCandidate?.id);

      final sqliteCandidates =
      await DatabaseHelper.instance.getCandidateMembers();
      debugPrint('SQLite candidates: ${sqliteCandidates.length}');

      if (!mounted || sqliteCandidates.isEmpty) return;

      int idx = keepId == null
          ? 0
          : sqliteCandidates.indexWhere((c) => c.id == keepId);
      if (idx < 0) idx = 0;

      setState(() {
        _candidateMembers = sqliteCandidates;
        _selectedMemberIndex = idx;
      });

      if (reloadReport) {
        _selectMember(idx);
      } else {
        GlobalClass.selected_member = sqliteCandidates[idx].id;
      }
    } catch (e) {
      debugPrint('Admin & candidates fetch exception: $e');
    }
  }

  User? get _selectedCandidate {
    if (_candidateMembers.isNotEmpty &&
        _selectedMemberIndex < _candidateMembers.length) {
      return _candidateMembers[_selectedMemberIndex];
    }
    return null;
  }

  bool get _isReportGenerated {
    return _selectedCandidate?.isReportGenerated == true;
  }

  /// Loading card tab dikhao jab status == true ho aur report abhi generate na hui ho,
  /// ya jab us candidate ki polling chal rahi ho (scan ke turant baad).
  bool get _showReportLoading {
    final c = _selectedCandidate;
    if (c == null) return false;
    if (c.isReportGenerated == true) return false;
    if(c.isSubmitted == false) return false;
    return c.isSubmitted == true && c.isReportGenerated == false /*_pollingIds.contains(c.id)*/;

  }

  /// isReportGenerated true hone tak status API poll karta hai.
  /// True hote hi SQLite update -> candidates reload -> report cards load.
 /* Future<void> _pollReportUntilReady(String id) async {
    if (id.isEmpty || _pollingIds.contains(id)) return; // duplicate polling roko

    if (mounted) setState(() => _pollingIds.add(id));

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = UserPref(prefs).getToken() ?? '';
      if (token.isEmpty) return;

      bool isGenerated = false;
      int attempts = 0;

      while (!isGenerated && mounted && attempts < _maxPollAttempts) {
        attempts++;
        try {
          final resp = await ApiService().fetchReportStatus(
            auth: token,
            userDataId: id,
          );
          isGenerated = resp.statusCode == 200 &&
           //   resp.data['isReportGenerated'].toString() == 'true';
          ReportService.isReportGenerated(resp.data);
          debugPrint(
              'fetchReportStatus -> $id isGenerated=$isGenerated (attempt $attempts)');
        } catch (e) {
          // ek fail par polling band na ho
          debugPrint('fetchReportStatus error: $e');
        }

        if (!isGenerated) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (isGenerated) {
        // 1) SQLite update (widget mounted ho ya na ho)
        await DatabaseHelper.instance.updateReportGeneratedStatus(id, true);

        if (!mounted) return;

        // 2) Candidates reload, current selection same rakho
        await _loadAdminAndCandidatesFromSqlite(
          selectId: _selectedCandidate?.id ?? id,
          reloadReport: false,
        );

        // 3) Report data sirf tab load karo jab user abhi isi candidate par ho
        if (mounted && _selectedCandidate?.id == id) {
          await loadReportDataAccToCandidateIdAndParams();
        }
      }
    } catch (e) {
      debugPrint('Error in _pollReportUntilReady: $e');
    } finally {
      _pollingIds.remove(id);
      if (mounted) setState(() {});
    }
  }*/
  Future<void> _pollReportUntilReady(String id) async {
    if (id.isEmpty /*|| _pollingIds.contains(id)*/) {
      debugPrint('POLL SKIPPED -> id=$id (empty or already polling)');
      return; // duplicate polling roko
    }

    if (mounted) setState(() => _pollingIds.add(id));
    debugPrint('POLL START -> id=$id');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = UserPref(prefs).getToken() ?? '';
      if (token.isEmpty) {
        debugPrint('POLL ABORT -> token is empty');
        return;
      }

      bool isGenerated = false;
      int attempts = 0;

      while (!isGenerated && mounted && attempts < _maxPollAttempts) {
        attempts++;
        try {
          final resp = await ApiService().fetchReportStatus(
            auth: token,
            userDataId: id,
          );

          debugPrint('===== STATUS FULL RESPONSE (id=$id, attempt $attempts) =====');
          debugPrint('statusCode : ${resp.statusCode}');
          debugPrint('data type  : ${resp.data.runtimeType}');
          debugPrint('data       : ${resp.data}');
          debugPrint('============================================================');

          isGenerated = resp.statusCode == 200 &&
              ReportService.isReportGenerated(resp.data);

          debugPrint(
              'fetchReportStatus -> $id isGenerated=$isGenerated (attempt $attempts)');
        } catch (e, st) {
          // ek fail par polling band na ho
          debugPrint('fetchReportStatus error: $e');
          debugPrint('$st');
        }

        if (!isGenerated) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      debugPrint(
          'POLL LOOP END -> id=$id isGenerated=$isGenerated attempts=$attempts mounted=$mounted');

      if (isGenerated) {
        // 1) SQLite update
        final rows =
        await DatabaseHelper.instance.updateReportGeneratedStatus(id, true);
        debugPrint('DB UPDATE -> updateReportGeneratedStatus rows=$rows id=$id');

        if (!mounted) {
          debugPrint('POLL STOP -> widget not mounted after DB update');
          return;
        }

        // Local list turant update (minimal fix)
        final i = _candidateMembers.indexWhere((c) => c.id == id);
        debugPrint('LOCAL LIST -> index=$i for id=$id');
        if (i != -1) {
          setState(() => _candidateMembers[i].isReportGenerated = true);
        }

        // 2) Candidates reload
        await _loadAdminAndCandidatesFromSqlite(
          selectId: _selectedCandidate?.id ?? id,
          reloadReport: false,
        );

        // Reload ke baad ka state dekho
        final after = _candidateMembers.where((c) => c.id == id);
        for (final c in after) {
          debugPrint(
              'AFTER RELOAD -> id=${c.id} isReportGenerated=${c.isReportGenerated} isSubmitted=${c.isSubmitted}');
        }

        // 3) Report data load
        debugPrint(
            'LOAD REPORT CHECK -> selected=${_selectedCandidate?.id} polledId=$id');
        if (mounted && _selectedCandidate?.id == id) {
          await loadReportDataAccToCandidateIdAndParams();
          debugPrint('REPORT DATA LOADED -> personalityBlend=${_personalityBlend != null}');
        } else {
          debugPrint('REPORT LOAD SKIPPED -> user is on a different candidate');
        }
      }
    } catch (e, st) {
      debugPrint('Error in _pollReportUntilReady: $e');
      debugPrint('$st');
    } finally {
      _pollingIds.remove(id);
      debugPrint('POLL END -> id=$id removed from _pollingIds');
      if (mounted) setState(() {});
    }
  }
  UserProfile get _selectedProfile {
    final candidate = _selectedCandidate;
    final name = _selectedMemberName;

    final primaryP = _homeReportModel?.personality?.primary.isNotEmpty == true
        ? _homeReportModel!.personality!.primary
        : 'Dominate';
    final secondaryP =
    _homeReportModel?.personality?.secondary.isNotEmpty == true
        ? _homeReportModel!.personality!.secondary
        : 'Influential';

    final rightB =
    _toPercentage(_homeReportModel?.brainDominance?.rightBrain ?? 0.62);
    final leftB =
    _toPercentage(_homeReportModel?.brainDominance?.leftBrain ?? 0.38);

    final vis = _toPercentage(_homeReportModel?.senses?.see ?? 0.88);
    final tch = _toPercentage(_homeReportModel?.senses?.touch ?? 0.82);

    return UserProfile(
      id: candidate?.id ?? '1',
      name: name,
      role: candidate?.studdingClass ?? 'Class 8',
      emoji: '👦',
      studentId: '#DK-9842',
      archetype: 'Visual–Kinesthetic Leader (High Logical Fluency)',
      personalityPrimary: primaryP,
      personalitySecondary: secondaryP,
      primaryPercent: 65,
      secondaryPercent: 35,
      strengthsCount: 12,
      weaknessesCount: 5,
      brainDominance: rightB >= leftB
          ? 'Right Brain Dominant (${rightB.toStringAsFixed(0)}%)'
          : 'Left Brain Dominant (${leftB.toStringAsFixed(0)}%)',
      sensoryPreference:
      'Vision (${vis.toStringAsFixed(0)}%) & Touch (${tch.toStringAsFixed(0)}%)',
      topCareerMatch: 'Software Engineer',
      careerMatchPercent: 94,
    );
  }

  String get _selectedMemberName {
    if (_candidateMembers.isNotEmpty &&
        _selectedMemberIndex < _candidateMembers.length) {
      final user = _candidateMembers[_selectedMemberIndex];
      return (user.dataName != null && user.dataName!.isNotEmpty)
          ? user.dataName!
          : (user.firstName != null && user.firstName!.isNotEmpty)
          ? user.firstName!
          : 'Aarav';
    }
    return _adminFirstName;
  }

 /* void _selectMember(int index) async {
    setState(() {
      _selectedMemberIndex = index;
    });

    if (_candidateMembers.isNotEmpty && index < _candidateMembers.length) {
      final selectedCandidate = _candidateMembers[index];
      final name = (selectedCandidate.dataName != null &&
          selectedCandidate.dataName!.isNotEmpty)
          ? selectedCandidate.dataName!
          : (selectedCandidate.firstName != null &&
          selectedCandidate.firstName!.isNotEmpty)
          ? selectedCandidate.firstName!
          : 'Aarav';

      GlobalClass.selected_member = selectedCandidate.id;
      debugPrint(
          "Selected active candidate member -> ID: ${selectedCandidate.id}, Name: $name, isReportGenerated: ${selectedCandidate.isReportGenerated}");

      if (selectedCandidate.isReportGenerated == true) {
        await loadReportDataAccToCandidateIdAndParams();
      } else if (selectedCandidate.status == false) {
        // await nahi, background mein chale
        _pollReportUntilReady(selectedCandidate.id);
      }
    }
  }*/
  void _selectMember(int index) async {
    if (index < 0 || index >= _candidateMembers.length) return;

    final selectedCandidate = _candidateMembers[index];

    setState(() {
      _selectedMemberIndex = index;
      _homeReportModel = null;
      _personalityBlend = null;
      _multipleIntelligenceResponse = null;
      _sensesAnalysis = null;
      _brainDominanceResponse = null;
      _careerMatch = null;
    });

    GlobalClass.selected_member = selectedCandidate.id;

    debugPrint(
      'Selected candidate: ${selectedCandidate.id}, '
          'isReportGenerated=${selectedCandidate.isReportGenerated}, '
          'isSubmitted=${selectedCandidate.isSubmitted}',
    );

    if (selectedCandidate.isReportGenerated) {
      await loadReportDataAccToCandidateIdAndParams();
    } else if (selectedCandidate.isSubmitted) {
      _pollReportUntilReady(selectedCandidate.id);
    }
  }

  /// Scan screen -> upload success -> loading card -> status poll ->
  /// SQLite update -> candidates reload -> report cards load.
  /*Future<void> _openScanModeDialog() async {
    final bool? isSuccess = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DmitProtocolIntroScreen(
          candidateName: _selectedMemberName,
        ),
      ),
    );

    final id = GlobalClass.selected_member;

    GlobalClass.scanStatus[id] = "2";

    if (isSuccess == true && mounted) {
      await _pollReportUntilReady(id); // same shared polling
    }
  }*/


/*  Future<void> _openScanModeDialog() async {
    final bool? isSuccess = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DmitProtocolIntroScreen(
          candidateName: _selectedMemberName,
        ),
      ),
    );

    final id = GlobalClass.selected_member;

    GlobalClass.scanStatus[id] = "2";

    if (isSuccess == true && mounted) {

      // Update isSubmitted = true for selected candidate in SQLite
      if (id.isNotEmpty) {
        final updatedRows =
        await DatabaseHelper.instance.updateIsSubmittedStatus(
          id,
          true,
        );

        debugPrint(
          'SCAN SUCCESS => candidateId: $id, '
              'isSubmitted: true, '
              'updatedRows: $updatedRows',
        );
      }

      if (!mounted) return;

      // Existing report polling - unchanged
      await _pollReportUntilReady(id);
    }
  }*/

  Future<void> _openScanModeDialog() async {
    final id = GlobalClass.selected_member;

    final bool? isSuccess = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DmitProtocolIntroScreen(
          candidateName: _selectedMemberName,
        ),
      ),
    );

    GlobalClass.scanStatus[id] = "2";

    if (isSuccess == true && mounted) {
      // 1. Immediately show loading
      setState(() {
        _pollingIds.add(id);
      });

      // 2. Update selected candidate in SQLite
      final updatedRows =
      await DatabaseHelper.instance.updateIsSubmittedStatus(
        id,
        true,
      );

      // 3. Update selected candidate in local list
      if (!mounted) return;

      setState(() {
        final index = _candidateMembers.indexWhere(
              (c) => c.id == id,
        );

        if (index != -1) {
          _candidateMembers[index].isSubmitted = true;
        }
      });

      debugPrint(
        'SCAN SUCCESS => id: $id, '
            'isSubmitted: true, updatedRows: $updatedRows',
      );

      // 4. Start report polling
      await _pollReportUntilReady(id);
    }
  }

  Future<void> _openAtdScan() async {
    final id = GlobalClass.selected_member;
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a candidate first.')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = UserPref(prefs).getToken() ?? '';

      if (token.isNotEmpty) {
        final isSuccess = await BiometricScanner.startAtdScan(
          token: token,
          userDataId: id,
        );

        debugPrint("ATD Scan result: $isSuccess");

        if (isSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ ATD Palm Scan Completed Successfully!'),
              backgroundColor: Color(0xFF22C55E),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error opening ATD scan: $e");
    }
  }

  void _openAddMemberDialog() {
    AddFamilyMemberDialog.show(
      context,
      onMemberAdded: (newMember) {
        debugPrint('onMemberAdded fired -> ${newMember.id}');
        _loadAdminAndCandidatesFromSqlite(selectId: newMember.id);
      },
    );
  }

  /// Opens the full vertical candidate list (with search).
  /// Returns the tapped candidate's index in the original list.
  Future<void> _openAllCandidates() async {
    final picked = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => CandidateListScreen(
          candidates: _candidateMembers,
          selectedIndex: _selectedMemberIndex,
        ),
      ),
    );
    if (picked != null && mounted) {
      _selectMember(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double padding = context.scalePadding(16.0);
    final isNarrow = context.isNarrowMobile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const DakshIntelligenceDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Scrollable Body
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Bar Navigation Header
                  if (admin_name != null) ...[
                    HomeTopBar(
                      currentProfile: _selectedProfile,
                      adminname: admin_name!,
                      isHindi: _isHindi,
                      onLanguageToggle: _toggleLanguage,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // 2. Greeting Card
                  _buildGreetingCard(context),

                  const SizedBox(height: 16),

                  // 3. Select Family Member Section
                  _buildFamilyMemberSelector(),

                  const SizedBox(height: 16),

                  // 4. Conditional Content (Loading vs Report Cards vs Hero Card)
                  if (_showReportLoading) ...[
                    _buildReportLoadingCard(context),
                    const SizedBox(height: 80),
                  ]
                  else if (_isReportGenerated) ...[
                    // Personality Blend Card
                    if (_personalityBlend != null &&
                        _personalityBlend!.report != null &&
                        _personalityBlend!.report!.personality != null) ...[
                      PersonalityBlendCard(
                          personalityBlendData:
                          _personalityBlend!.report!.personality!),
                    ],
                    const SizedBox(height: 16),

                    // Locked Tier Warning Banner
                    const LockedWarningBanner(),
                    const SizedBox(height: 16),

                    if (_multipleIntelligenceResponse != null) ...[
                      // 8 Multiple Intelligence Chart Card
                      IntelligenceChartCard(
                        multipleIntelligenceData: _multipleIntelligenceResponse
                            ?.report?.multipleIntelligence,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 5 Senses Analysis Card
                    if (_sensesAnalysis != null &&
                        _sensesAnalysis!.report != null) ...[
                      SensesAnalysisCard(
                          currentProfile: _sensesAnalysis!.report!.senses),
                      const SizedBox(height: 16),
                    ],

                    // Brain Dominance Card
                    if (_brainDominanceResponse != null &&
                        _brainDominanceResponse!.report != null) ...[
                      BrainDominanceCard(
                          currentProfile:
                          _brainDominanceResponse!.report!.brainDominance),
                      const SizedBox(height: 16),
                    ],

                    if (_personalityBlend != null &&
                        _personalityBlend!.swotAnalysis != null) ...[
                      // SWOT Analysis Card
                      SwotAnalysisCard(
                          swotAnalysis: _personalityBlend!.swotAnalysis!),
                      const SizedBox(height: 16),
                    ],

                    if (_careerMatch != null &&
                        _careerMatch!.report != null) ...[
                      CareerMatchCard(_careerMatch!.report!.career),
                      const SizedBox(height: 16),
                    ],
                  ]

                  else ...[
                    // Hero DMIT Card for candidates whose report is not yet generated
                    _buildHeroDmitCard(context, isNarrow),
                    const SizedBox(height: 16),

                    // Scientific Notice Footer Card
                    _buildScientificNoticeCard(),
                    const SizedBox(height: 80),
                  ],
                ],
              ),
            ),

            // Floating "Ask Vayo" badge (Positioned sirf Stack ke andar valid hai)
            if (_personalityBlend?.report?.personality != null)
              Positioned(
                right: 16,
                bottom: 20,
                child: AskVayoFloatingWidget(
                  _personalityBlend!.report!.personality!.primary,
                  _personalityBlend!.report!.personality!.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportLoadingCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF8FAFF),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFC7D2FE),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated glowing icon container
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEEF2FF),
                  Color(0xFFE0E7FF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.20),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                SizedBox(
                  width: 84,
                  height: 84,
                  child: CircularProgressIndicator(
                    color: Color(0xFFC7D2FE),
                    strokeWidth: 2,
                    value: 1,
                  ),
                ),
                // Inner spinning indicator
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    color: Color(0xFF6366F1),
                    strokeWidth: 4,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Center AI icon
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF6366F1),
                  size: 22,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Title
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            ).createShader(bounds),
            child: Text(
              ' Your Report is Generating Soon ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.scaleFont(20),
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_rounded,
                size: 15,
                color: const Color(0xFF10B981).withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Fingerprints uploaded successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.scaleFont(13),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Analyzing data for $_selectedMemberName and building the your Report...',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Animated progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.3, end: 1.0),
                duration: Duration(milliseconds: 600 + (index * 200)),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.lerp(
                        const Color(0xFFC7D2FE),
                        const Color(0xFF6366F1),
                        value,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1)
                              .withValues(alpha: 0.4 * value),
                          blurRadius: 8 * value,
                          spreadRadius: 2 * value,
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 8),
          const Text(
            'This may take a few moments',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context) {
    final loc = LanguageManager.instance.strings;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFEF08A),
                  border: Border.all(color: const Color(0xFF818CF8), width: 2),
                ),
                child: const Center(
                  child: Text('👦', style: TextStyle(fontSize: 24)),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Titles bound from real data
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text(
                      loc.greetingName(_selectedMemberName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: context.scaleFont(16.5),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _isReportGenerated
                      ? loc.fullSpectrumValidated
                      : loc.scanPending,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildFamilyMemberSelector() {
    if (_candidateMembers.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'ACTIVE CANDIDATE PROFILE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _openAddMemberDialog,
                child: const Text(
                  '+ Add Member',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                  border:
                  Border.all(color: const Color(0xFF6366F1), width: 1.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('👦', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(
                      _adminFirstName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4338CA),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    final total = _candidateMembers.length;
    final hasMore = total > _maxVisibleMembers;

    // First 10 indices; keep the selected one visible if it was picked from the full list
    List<int> visible = List.generate(total, (i) => i);
    if (hasMore) {
      visible = visible.take(_maxVisibleMembers).toList();
      if (_selectedMemberIndex >= _maxVisibleMembers) {
        visible[_maxVisibleMembers - 1] = _selectedMemberIndex;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'SELECT FAMILY MEMBER TO ANALYZE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _openAddMemberDialog,
              child: const Text(
                '+ Add Member',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              ...visible.map((index) {
                final isSelected = _selectedMemberIndex == index;
                final user = _candidateMembers[index];
                final name =
                (user.dataName != null && user.dataName!.isNotEmpty)
                    ? user.dataName!
                    : (user.firstName != null && user.firstName!.isNotEmpty)
                    ? user.firstName!
                    : 'Candidate';

                return GestureDetector(
                  onTap: () => _selectMember(index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color:
                      isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('👦', style: TextStyle(fontSize: 15)),
                        const SizedBox(width: 6),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? const Color(0xFF4338CA)
                                : const Color(0xFF334155),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6366F1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),

              // "View more" chip, only when there are more than 10 candidates
              if (hasMore)
                GestureDetector(
                  onTap: _openAllCandidates,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View more (+${total - _maxVisibleMembers})',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 15, color: Colors.white),
                      ],
                    ),
                  ),
                ),

              // Add (+) Member Button
              GestureDetector(
                onTap: _openAddMemberDialog,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroDmitCard(BuildContext context, bool isNarrow) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.scalePadding(16)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E1B4B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Chips Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border:
                    Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.biotech_rounded,
                            color: Color(0xFF00E5FF), size: 14),
                        SizedBox(width: 4),
                        Text(
                          'DERMATOGLYPHICS PROTOCOL',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF00E5FF),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF78350F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '0/10 Fingers Scanned',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFDE047),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Central Target Circle (SCAN READY)
          GestureDetector(
            onTap: _openScanModeDialog,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withValues(alpha: 0.25),
                    const Color(0xFF0F172A),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF00E5FF),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo_4.png',
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isHindi ? 'स्कैन तैयार' : 'SCAN READY',
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Title
          Text(
            _isHindi ? 'विश्लेषण शुरू करें' : 'Start Analysis',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.scaleFont(20),
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          // Subtitle
          Text(
            _isHindi
                ? 'सभी बौद्धिक क्षमताओं का विश्लेषण करने के लिए $_selectedMemberName के 10 फिंगरप्रिंट स्कैन करें।'
                : 'Capture 10 fingerprints to calibrate $_selectedMemberName\'s inborn neocortex lobes and unlock all intelligence dimensions.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF94A3B8),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          // 2x2 Grid of Locked Matrices
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildLockedMatrixCard('🔷', '8 Intelligences'),
              _buildLockedMatrixCard('🧠', 'Brain Dominance'),
              _buildLockedMatrixCard('👁', '5 Senses (VAK)'),
              _buildLockedMatrixCard('🎯', 'DISC & Careers'),
            ],
          ),

          const SizedBox(height: 18),

          // Analysis Sequence List Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('📜', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 8),
                    Text(
                      'Analysis Sequence:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSequenceStep('1', 'Review scientific  benefits'),
                const SizedBox(height: 6),
                _buildSequenceStep(
                    '2', 'Capture 10 epidermal ridge fingerprints'),
                const SizedBox(height: 6),
                _buildSequenceStep(
                    '3', 'Instant unlock of intelligence dashboard'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Primary Action Button (Start DMIT Analysis)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00E5FF),
                    Color(0xFF2563EB),
                    Color(0xFF7C3AED),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _openScanModeDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Start Analysis (Scan 10 Fingers)',
                          style: TextStyle(
                            fontSize: context.scaleFont(14),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),


          SizedBox(
            width: double.infinity,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00E5FF),
                    Color(0xFF2563EB),
                    Color(0xFF7C3AED),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _openAtdScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.waving_hand_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Start Atd Analysis(Scan Palm)',
                          style: TextStyle(
                            fontSize: context.scaleFont(14),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),


          // Bottom Trust Badges
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TrustBadge(
                    icon: Icons.shield_outlined, label: '100% Non-invasive'),
                SizedBox(width: 6),
                Text('•', style: TextStyle(color: Colors.white38)),
                SizedBox(width: 6),
                _TrustBadge(
                    icon: Icons.lock_outline, label: 'Zero Image Storage'),
                SizedBox(width: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedMatrixCard(String icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 1),
                const Row(
                  children: [
                    Icon(Icons.lock_rounded,
                        color: Color(0xFFFDE047), size: 10),
                    SizedBox(width: 3),
                    Text(
                      'Locked',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFDE047),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceStep(String num, String text) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xFF00E5FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScientificNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💡', style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Scientific Notice: Fingerprint epidermal ridges form synchronously with the cerebral neocortex during the 13th to 19th week of gestation. Complete the scan to calculate Total Finger Ridge Count (TFRC) and discover inborn cognitive capabilities.',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF1E40AF),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadReportDataAccToCandidateIdAndParams() async {
    await _loadPersonalityBlend();
    await _loadmultipleIntellegenceData();
    await _loadSensesAnalysis();
    await _loadBrainDominance();
    await _loadCareerMatch();
  }

  /// Called by Dashboard when user returns to Home (e.g. from Profile).
  /// Reloads only the candidate list from SQLite and keeps the selected member.
  /// The report is refetched only if the selected member changed
  /// (for example, the old one was deleted in Profile).
  Future<void> reloadCandidates() async {
    if (!mounted) return;

    final previousId = _selectedCandidate?.id;

    await _loadAdminAndCandidatesFromSqlite(
      selectId: previousId,
      reloadReport: false,
    );

    if (!mounted) return;

    if (_selectedCandidate?.id != previousId) {
      _selectMember(_selectedMemberIndex);
    }
  }

  Future<void> _loadPersonalityBlend() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final parsed =
    await reportService.fetchPersonalityBlend(userDataId: candidate.id);

    // ignore the result if the user switched candidate while loading
    if (!mounted || _selectedCandidate?.id != candidate.id) return;

    setState(() => _personalityBlend = parsed);
    debugPrint(
      'personality_blend -> primary: ${parsed?.report?.personality?.primary}, '
          'secondary: ${parsed?.report?.personality?.secondary}',
    );
  }

  Future<void> _loadmultipleIntellegenceData() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final parsed =
    await reportService.fetchMultipleIntelligence(userDataId: candidate.id);
    if (!mounted || _selectedCandidate?.id != candidate.id) return;

    setState(() => _multipleIntelligenceResponse = parsed);
    debugPrint('multipleintellegence');
  }

  Future<void> _loadSensesAnalysis() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final result =
    await reportService.fetchSensesAnalysis(userDataId: candidate.id);

    if (!mounted || _selectedCandidate?.id != candidate.id) return;
    setState(() => _sensesAnalysis = result);
    debugPrint('SENSES dominant -> ${result?.report?.senses?.dominant}');
  }

  Future<void> _loadBrainDominance() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final result =
    await reportService.fetchBrainDominance(userDataId: candidate.id);

    if (!mounted || _selectedCandidate?.id != candidate.id) return;
    setState(() => _brainDominanceResponse = result);
    debugPrint('BRAIN label -> ${result?.report?.brainDominance?.label}');
  }

  Future<void> _loadCareerMatch() async {
    final candidate = _selectedCandidate;
    if (candidate == null) return;

    final result =
    await reportService.fetchCareerMatch(userDataId: candidate.id);

    if (!mounted || _selectedCandidate?.id != candidate.id) return;

    setState(() => _careerMatch = result);

    final top = result?.report?.career?.topCategory;
    debugPrint('CAREER top category -> ${top?.name}, self: ${top?.self}');
  }

  Future<void> _loadAdminDataFromLocal() async {
    try {
      final admin = await DatabaseHelper.instance.getAdmin();
      admin_name = admin!.firstName;
    } catch (e) {
      debugPrint('Profile: admin load error: $e');
    }
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF38BDF8), size: 12),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}