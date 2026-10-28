import 'package:flutter/material.dart';

class DpdpPrivacyScreen extends StatelessWidget {
  const DpdpPrivacyScreen({super.key});

  static const Color _headerColor = Color(0xFF1E1B4B);
  static const Color _textColor = Color(0xFF1E293B);
  static const Color _softText = Color(0xFF334155);
  static const Color _ruleColor = Color(0xFFD1D5DB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _headerColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'DPDP Act & Data Privacy',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('🛡️', style: TextStyle(fontSize: 17)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Digital Personal Data Protection Act',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _textColor,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                '(India DPDP Act, 2023 Compliance)',
                style: TextStyle(fontSize: 13, color: _softText),
              ),
              const SizedBox(height: 12),
              const Text(
                'Daksh Intelligence complies with Indian data privacy '
                    'standards to keep your evaluations and scans secure.',
                style: TextStyle(fontSize: 14, height: 1.4, color: _textColor),
              ),

              _divider(),

              // What we collect
              _sectionHeader('📌', 'WHAT WE COLLECT & WHY'),
              _bullet('Identity Info:',
                  ' Name, phone number for profile creation and account security.'),
              _bullet('Biometric & Assessment Data:',
                  ' Used purely for intelligence profiling and generating cognitive report matrices.'),

              _divider(),

              // Rights
              _sectionHeader('⚖️', 'YOUR RIGHTS AS A DATA PRINCIPAL'),
              _numbered(1, 'Right to Access Information:',
                  ' View a summary of your personal and scan data.'),
              _numbered(2, 'Right to Correction & Erasure:',
                  ' Request rectification or complete permanent deletion.'),
              _numbered(3, 'Right to Withdraw Consent:',
                  ' Revoke your scan consent at any time.'),
              _numbered(4, 'Right of Grievance Redressal:',
                  ' Access to resolve privacy and data handling concerns.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: Divider(height: 1, thickness: 1, color: _ruleColor),
  );

  Widget _sectionHeader(String emoji, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: _textColor,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _bullet(String boldText, String normalText) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 6),
        const Text('•',
            style: TextStyle(fontSize: 14, height: 1.4, color: _textColor)),
        const SizedBox(width: 8),
        Expanded(child: _richLine(boldText, normalText)),
      ],
    ),
  );

  Widget _numbered(int n, String boldText, String normalText) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Text('$n.',
              style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: _textColor)),
        ),
        const SizedBox(width: 2),
        Expanded(child: _richLine(boldText, normalText)),
      ],
    ),
  );

  Widget _richLine(String boldText, String normalText) => RichText(
    text: TextSpan(
      style: const TextStyle(fontSize: 14, height: 1.4, color: _textColor),
      children: [
        TextSpan(
            text: boldText,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        TextSpan(text: normalText),
      ],
    ),
  );
}
/*
import 'package:flutter/material.dart';

class DpdpPrivacyScreen extends StatelessWidget {
  const DpdpPrivacyScreen({super.key});

  static const Color _navy = Color(0xFF0F172A);
  static const Color _indigo = Color(0xFF1E1B4B);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _bg = Color(0xFFF8FAFC);
  static const Color _title = Color(0xFF1E293B);
  static const Color _body = Color(0xFF475569);
  static const Color _border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.viewPaddingOf(context).top;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // ---------- Header ----------
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_navy, _indigo, _navy],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'DPDP Act & Data Privacy',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _cyan.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: _cyan.withValues(alpha: 0.5), width: 1.2),
                      ),
                      child: const Icon(Icons.verified_user_rounded,
                          color: _cyan, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Digital Personal Data Protection Act',
                            style: TextStyle(
                              fontSize: 19,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          _ComplianceChip(
                              label: '(India DPDP Act, 2023 Compliance)'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Daksh Intelligence complies with Indian data privacy '
                      'standards to keep your evaluations and scans secure.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),

          // ---------- Content ----------
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  children: [
                    _SectionCard(
                      icon: Icons.push_pin_rounded,
                      accent: const Color(0xFF6366F1),
                      accentBg: const Color(0xFFEEF2FF),
                      title: 'WHAT WE COLLECT & WHY',
                      children: const [
                        _InfoRow(
                          icon: Icons.badge_rounded,
                          iconColor: Color(0xFF0284C7),
                          iconBg: Color(0xFFE0F2FE),
                          heading: 'Identity Info:',
                          text:
                          'Name, phone number for profile creation and account security.',
                        ),
                        _RowDivider(),
                        _InfoRow(
                          icon: Icons.fingerprint_rounded,
                          iconColor: Color(0xFFA855F7),
                          iconBg: Color(0xFFF3E8FF),
                          heading: 'Biometric & Assessment Data:',
                          text:
                          'Used purely for intelligence profiling and generating cognitive report matrices.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      icon: Icons.balance_rounded,
                      accent: const Color(0xFF16A34A),
                      accentBg: const Color(0xFFDCFCE7),
                      title: 'YOUR RIGHTS AS A DATA PRINCIPAL',
                      children: const [
                        _NumberedRow(
                          number: 1,
                          heading: 'Right to Access Information:',
                          text:
                          'View a summary of your personal and scan data.',
                        ),
                        _RowDivider(),
                        _NumberedRow(
                          number: 2,
                          heading: 'Right to Correction & Erasure:',
                          text:
                          'Request rectification or complete permanent deletion.',
                        ),
                        _RowDivider(),
                        _NumberedRow(
                          number: 3,
                          heading: 'Right to Withdraw Consent:',
                          text: 'Revoke your scan consent at any time.',
                        ),
                        _RowDivider(),
                        _NumberedRow(
                          number: 4,
                          heading: 'Right of Grievance Redressal:',
                          text:
                          'Access to resolve privacy and data handling concerns.',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceChip extends StatelessWidget {
  final String label;
  const _ComplianceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF67E8F9),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final Color accentBg;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.accent,
    required this.accentBg,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DpdpPrivacyScreen._border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: DpdpPrivacyScreen._title,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 12),
    child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
  );
}

class _RichText extends StatelessWidget {
  final String heading;
  final String text;
  const _RichText({required this.heading, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: DpdpPrivacyScreen._title,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            height: 1.45,
            color: DpdpPrivacyScreen._body,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String heading;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.heading,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(child: _RichText(heading: heading, text: text)),
      ],
    );
  }
}

class _NumberedRow extends StatelessWidget {
  final int number;
  final String heading;
  final String text;

  const _NumberedRow({
    required this.number,
    required this.heading,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _RichText(heading: heading, text: text)),
      ],
    );
  }
}*/
