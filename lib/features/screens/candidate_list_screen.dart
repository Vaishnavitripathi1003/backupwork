import 'package:flutter/material.dart';
import '../../core/Global/global_class.dart';
import '../../data/models/user_models.dart';
import 'dmit_protocol_intro_screen.dart';

/// Full vertical list of all candidates with search by name / number.
/// Pops with the tapped candidate's index (in the original list) to render their report on HomeScreen.
class CandidateListScreen extends StatefulWidget {
  final List<User> candidates;
  final int selectedIndex;

  const CandidateListScreen({
    super.key,
    required this.candidates,
    required this.selectedIndex,
  });

  @override
  State<CandidateListScreen> createState() => _CandidateListScreenState();
}

class _CandidateListScreenState extends State<CandidateListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _name(User u) {
    if (u.dataName != null && u.dataName!.isNotEmpty) return u.dataName!;
    if (u.firstName != null && u.firstName!.isNotEmpty) return u.firstName!;
    return 'Candidate';
  }

  String _phone(User u) {
    if (u.mobile != null && u.mobile!.isNotEmpty) return u.mobile!;
    try {
      final v = (u as dynamic).mobileNumber;
      return v?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  String _imageUrl(User u) {
    try {
      final v = (u as dynamic).profileImage;
      return v?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  List<int> get _filteredIndices {
    final all = List<int>.generate(widget.candidates.length, (i) => i);
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;

    final qDigits = q.replaceAll(RegExp(r'[^0-9]'), '');

    return all.where((i) {
      final u = widget.candidates[i];
      final name = _name(u).toLowerCase();
      final phone = _phone(u);
      final phoneDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');

      final nameMatch = name.contains(q);
      final phoneMatch = phone.contains(q) ||
          (qDigits.isNotEmpty && phoneDigits.contains(qDigits));
      return nameMatch || phoneMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredIndices;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        title: Text(
          _query.trim().isEmpty
              ? 'All Candidates (${widget.candidates.length})'
              : 'Results (${results.length}/${widget.candidates.length})',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Search by name or number',
                hintStyle: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xFF94A3B8)),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Color(0xFF94A3B8), size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                ),
              ),
            ),
          ),

          // List / empty state
          Expanded(
            child: results.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final originalIndex = results[i];
                      return _buildCandidateCard(originalIndex);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 56, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            const Text(
              'No candidates found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nothing matches "${_query.trim()}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateCard(int index) {
    final user = widget.candidates[index];
    final isSelected = index == widget.selectedIndex;
    final phone = _phone(user);
    final img = _imageUrl(user);

    return GestureDetector(
      onTap: () async {
        GlobalClass.selected_member = user.id;

        if (user.isReportGenerated == true) {
          // Report is generated: Return selected index to HomeScreen immediately to display report
          Navigator.pop(context, index);
        } else {
          // Report NOT generated: Open DMIT Scan Protocol screen first
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => DmitProtocolIntroScreen(
                candidateName: _name(user),
              ),
            ),
          );
          if (mounted) {
            Navigator.pop(context, index);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6366F1)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFFEF08A),
              backgroundImage: img.isNotEmpty ? NetworkImage(img) : null,
              child: img.isEmpty
                  ? const Text('👦', style: TextStyle(fontSize: 24))
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name(user),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                       /* const Icon(Icons.phone_rounded,
                            size: 13, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),*/
                        Text(
                          phone,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (user.isReportGenerated == true) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Report Ready ✨',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ] else ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Scan Pending ⏳',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF6366F1), size: 22),
          ],
        ),
      ),
    );
  }
}
