/*
// atdResultScreen.dart
// Flutter ResultsScreen fetching ATD report dynamically using AtdResultResponse.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_service.dart';
import '../../../core/storage/user_pref.dart';
import 'model/AtdCategoryInfo.dart';
import 'model/AtdResult.dart';

Future<AtdResultResponse> fetchAtdResult({
  required String userDataId,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = UserPref(prefs).getToken() ?? '';
  if (token.isEmpty) throw Exception('Missing authentication token');

  final response = await ApiService().findAtdReportByUserDataId(
    auth: token,
    userDataId: userDataId,
  );

  if (response.statusCode != 200 || response.data == null) {
    throw Exception('Server error ${response.statusCode}');
  }

  final dataMap = response.data is Map
      ? Map<String, dynamic>.from(response.data as Map)
      : <String, dynamic>{};

  final atdResponse = AtdResultResponse.fromJson(dataMap);
  if (atdResponse.atdReport == null) {
    throw Exception('No ATD report found for candidate');
  }

  return atdResponse;
}

// ───────────────────────── Screen ─────────────────────────

const Color _bg = Color(0xFFFBF8F5);
const Color _accent = Color(0xFFE57373);

String _fmt(double v) => v.toStringAsFixed(1);

class ResultsScreen extends StatefulWidget {
  final String userDataId;

  const ResultsScreen({
    super.key,
    required this.userDataId,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Future<AtdResultResponse> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchAtdResult(userDataId: widget.userDataId);
  }

  void _retry() {
    setState(() {
      _future = fetchAtdResult(userDataId: widget.userDataId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _header(),
            ),
            Expanded(
              child: FutureBuilder<AtdResultResponse>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(color: _accent),
                    );
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data?.atdReport == null) {
                    return _errorView();
                  }
                  return _content(snapshot.data!.atdReport!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Could not load results',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Check your connection and try again',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(AtdCategoryInfo c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heroCard(c),
          const SizedBox(height: 16),
          _interpretationCard(c),
          const SizedBox(height: 16),
          _chartCard(c),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Header: Logo + title
  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/dakshlogo.png',
              width: 28,
              height: 28,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.fingerprint, size: 28, color: _accent),
            ),
            const SizedBox(width: 6),
            const Text(
              'DAKSH ATD Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _card({required Widget child}) => Card(
        elevation: 2,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: child,
      );

  // Card 1: Final ATD angle
  Widget _heroCard(AtdCategoryInfo c) {
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Calculated ATD Angle',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  '${_fmt(c.angle)}°',
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                const Text(
                  'Bilateral palm average',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    c.profileName,
                    style: const TextStyle(
                      color: Color(0xFF1976D2),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Icon(Icons.fingerprint, size: 64, color: Color(0xFF80CBC4)),
          ],
        ),
      ),
    );
  }

  // Card 2: Interpretation and reference scale (all text from API)
  Widget _interpretationCard(AtdCategoryInfo c) {
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lightbulb,
                      size: 18, color: Color(0xFF00897B)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Interpretation Profile',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(
                      c.profileName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00897B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              c.description,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF616161), height: 1.4),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),
            _trait('🧠 Cognitive & Processing Trait', const Color(0xFF1E88E5),
                c.cognitiveTrait),
            const SizedBox(height: 10),
            _trait('⚡ Physical & Reflex Response', const Color(0xFF2E7D32),
                c.physicalTrait),
            const SizedBox(height: 10),
            _trait('💡 Learning Recommendations', const Color(0xFFE65100),
                c.learningRecommendations),
            const SizedBox(height: 10),
            const Text(
              '🌟 Key Strengths',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B9A)),
            ),
            const SizedBox(height: 4),
            for (final s in c.strengths)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✓ ',
                        style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    Expanded(
                      child: Text(s,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF424242))),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            const Text('Reference Scale',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                _pill('< 35°\nAthlete', c.key == 'BORN_ATHLETE'),
                const SizedBox(width: 4),
                _pill('35-40°\nSmart', c.key == 'ACTIVELY_SMART'),
                const SizedBox(width: 4),
                _pill('41-45°\nNormal', c.key == 'NORMAL_BALANCED'),
                const SizedBox(width: 4),
                _pill('46-50°\nAverage', c.key == 'STEP_BY_STEP'),
                const SizedBox(width: 4),
                _pill('> 50°\nMethodical', c.key == 'METHODICAL'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _trait(String title, Color color, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(body,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF424242), height: 1.35)),
      ],
    );
  }

  Widget _pill(String label, bool selected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E88E5) : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9,
            height: 1.2,
            color: selected ? Colors.white : const Color(0xFF9E9E9E),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Card 3: Bilateral chart
  Widget _chartCard(AtdCategoryInfo c) {
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ATD Measurement Overview',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 140,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _bar('Calculated Angle', c.angle, const Color(0xFF42A5F5)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Final: ${_fmt(c.angle)}° • Tag: ${c.rangeTag}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(String label, double value, Color color) {
    final barHeight = ((value / 65.0) * 110).clamp(10.0, 120.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${_fmt(value)}°',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 36,
          height: barHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
*/
// atdResultScreen.dart
// Responsive ResultsScreen fetching ATD report dynamically using AtdResultResponse.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_service.dart';
import '../../../core/storage/user_pref.dart';
import 'model/AtdCategoryInfo.dart';
import 'model/AtdResult.dart';

Future<AtdResultResponse> fetchAtdResult({
  required String userDataId,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = UserPref(prefs).getToken() ?? '';
  if (token.isEmpty) throw Exception('Missing authentication token');

  final response = await ApiService().findAtdReportByUserDataId(
    auth: token,
    userDataId: userDataId,
  );

  if (response.statusCode != 200 || response.data == null) {
    throw Exception('Server error ${response.statusCode}');
  }

  final dataMap = response.data is Map
      ? Map<String, dynamic>.from(response.data as Map)
      : <String, dynamic>{};

  final atdResponse = AtdResultResponse.fromJson(dataMap);
  if (atdResponse.atdReport == null) {
    throw Exception('No ATD report found for candidate');
  }

  return atdResponse;
}

// ───────────────────────── Screen ─────────────────────────

const Color _bg = Color(0xFFFBF8F5);
const Color _accent = Color(0xFFE57373);

/// Content never gets wider than this (keeps tablets / landscape readable).
const double _maxContentWidth = 640;

String _fmt(double v) => v.toStringAsFixed(1);

class ResultsScreen extends StatefulWidget {
  final String userDataId;

  const ResultsScreen({
    super.key,
    required this.userDataId,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Future<AtdResultResponse> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchAtdResult(userDataId: widget.userDataId);
  }

  void _retry() {
    setState(() {
      _future = fetchAtdResult(userDataId: widget.userDataId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Clamp system font scaling so large accessibility sizes don't break layout.
    final mq = MediaQuery.of(context);
    final scaler = mq.textScaler.clamp(
      minScaleFactor: 0.85,
      maxScaleFactor: 1.3,
    );

    return MediaQuery(
      data: mq.copyWith(textScaler: scaler),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final compact = w < 360;
              final hPad = compact ? 14.0 : 20.0;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
                        child: _header(),
                      ),
                      Expanded(
                        child: FutureBuilder<AtdResultResponse>(
                          future: _future,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return const Center(
                                child:
                                CircularProgressIndicator(color: _accent),
                              );
                            }
                            if (snapshot.hasError ||
                                !snapshot.hasData ||
                                snapshot.data?.atdReport == null) {
                              return _errorView();
                            }
                            return _content(
                              snapshot.data!.atdReport!,
                              compact: compact,
                              hPad: hPad,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Could not load results',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Check your connection and try again',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(
      AtdCategoryInfo c, {
        required bool compact,
        required double hPad,
      }) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heroCard(c, compact: compact),
          const SizedBox(height: 16),
          _interpretationCard(c, compact: compact),
          const SizedBox(height: 16),
          _chartCard(c, compact: compact),
        ],
      ),
    );
  }

  // Header: Logo + title
  Widget _header() {
    return Row(
      children: [
        Image.asset(
          'assets/images/dakshlogo.png',
          width: 28,
          height: 28,
          errorBuilder: (_, __, ___) =>
          const Icon(Icons.fingerprint, size: 28, color: _accent),
        ),
        const SizedBox(width: 6),
        const Expanded(
          child: Text(
            'DAKSH ATD Results',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) => Card(
    elevation: 2,
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: child,
  );

  // Card 1: Final ATD angle
  Widget _heroCard(AtdCategoryInfo c, {required bool compact}) {
    return _card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calculated ATD Angle',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_fmt(c.angle)}°',
                      style: TextStyle(
                        fontSize: compact ? 36 : 44,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E88E5),
                      ),
                    ),
                  ),
                  const Text(
                    'Bilateral palm average',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      c.profileName,
                      softWrap: true,
                      style: const TextStyle(
                        color: Color(0xFF1976D2),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.fingerprint,
              size: compact ? 48 : 64,
              color: const Color(0xFF80CBC4),
            ),
          ],
        ),
      ),
    );
  }

  // Card 2: Interpretation and reference scale (all text from API)
  Widget _interpretationCard(AtdCategoryInfo c, {required bool compact}) {
    return _card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lightbulb,
                      size: 18, color: Color(0xFF00897B)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Interpretation Profile',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(
                        c.profileName,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00897B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              c.description,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF616161), height: 1.4),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),
            _trait('🧠 Cognitive & Processing Trait', const Color(0xFF1E88E5),
                c.cognitiveTrait),
            const SizedBox(height: 10),
            _trait('⚡ Physical & Reflex Response', const Color(0xFF2E7D32),
                c.physicalTrait),
            const SizedBox(height: 10),
            _trait('💡 Learning Recommendations', const Color(0xFFE65100),
                c.learningRecommendations),
            const SizedBox(height: 10),
            const Text(
              '🌟 Key Strengths',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B9A)),
            ),
            const SizedBox(height: 4),
            for (final s in c.strengths)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✓ ',
                        style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    Expanded(
                      child: Text(s,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF424242))),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            const Text('Reference Scale',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 8),
            _referenceScale(c),
          ],
        ),
      ),
    );
  }

  /// Five pills that always fit on one row (text scales down) and never overflow.
  Widget _referenceScale(AtdCategoryInfo c) {
    final items = <(String, String)>[
      ('< 35°\nAthlete', 'BORN_ATHLETE'),
      ('35-40°\nSmart', 'ACTIVELY_SMART'),
      ('41-45°\nNormal', 'NORMAL_BALANCED'),
      ('46-50°\nAverage', 'STEP_BY_STEP'),
      ('> 50°\nMethodical', 'METHODICAL'),
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            _pill(items[i].$1, c.key == items[i].$2),
          ],
        ],
      ),
    );
  }

  Widget _trait(String title, Color color, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(body,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF424242), height: 1.35)),
      ],
    );
  }

  Widget _pill(String label, bool selected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E88E5) : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              height: 1.2,
              color: selected ? Colors.white : const Color(0xFF9E9E9E),
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Card 3: Bilateral chart
  Widget _chartCard(AtdCategoryInfo c, {required bool compact}) {
    return _card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ATD Measurement Overview',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 190,
              child: LayoutBuilder(
                builder: (context, box) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _bar(
                        'Calculated Angle',
                        c.angle,
                        const Color(0xFF42A5F5),
                        availableHeight: box.maxHeight,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Final: ${_fmt(c.angle)}° • Tag: ${c.rangeTag}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The bar height is derived from the space actually available, so the
  /// value text + bar + label can never exceed the chart box (no bottom overflow).
  Widget _bar(
      String label,
      double value,
      Color color, {
        required double availableHeight,
      }) {
    const valueTextArea = 22.0; // value text + gap
    const labelArea = 30.0; // gap + label (room for text scaling)
    final maxBar =
    (availableHeight - valueTextArea - labelArea).clamp(10.0, 400.0);
    final barHeight = ((value / 65.0) * maxBar).clamp(10.0, maxBar);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${_fmt(value)}°',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 36,
          height: barHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}