import 'package:flutter/material.dart';
import 'package:tressy/features/widgets/profile_appbar.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfileAppBar(
        title: 'Privacy Policy',
        centerTitle: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: const SafeArea(
        child: _PrivacyPolicyContent(),
      ),
    );
  }
}

class _PrivacyPolicyContent extends StatelessWidget {
  const _PrivacyPolicyContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        _buildSection(
          context,
          number: '1',
          title: 'Introduction',
          children: [
            _BodyText(
              'This Privacy Policy explains how JR STYLE\'O BOOKING AND FASHION PVT LTD '
              '("Company", "We", "Us", "Our") collects, uses, shares, protects, and '
              'processes personal information when Users and Partners ("You", "Your") '
              'access or use the Gloup Instantly website, mobile application, and related '
              'services ("Platform").',
            ),
            _BodyText(
              'By using the Platform, You consent to the data practices described in this Policy.',
            ),
            const _BodyText('This Policy complies with:'),
            const _BulletList(items: [
              'Information Technology Act, 2000',
              'Information Technology (Reasonable Security Practices and Procedures and Sensitive Personal Data or Information) Rules, 2011',
              'IT Intermediary Guidelines 2021',
              'Indian Contract Act, 1872',
            ]),
          ],
        ),
        _buildSection(
          context,
          number: '2',
          title: 'Information We Collect',
          children: [
            const _BodyText('We may collect the following:'),
            const _SubSectionTitle('A. User Information'),
            const _BulletList(items: [
              'Name, gender',
              'Phone number, email address',
              'Location data (with permission)',
              'Device information',
              'Service preferences',
              'Booking history',
              'Payment details (via Razorpay gateways only)',
              'Reviews and feedback',
            ]),
            const _SubSectionTitle('B. Partner (Salon) Information'),
            const _BulletList(items: [
              'Owner/Manager name',
              'Business name',
              'Business address & licence',
              'GST details (if applicable)',
              'Service menu & pricing',
              'Staff details',
              'Bank account details for settlements',
            ]),
            const _SubSectionTitle('C. Automatically Collected Data'),
            const _BulletList(items: [
              'IP address',
              'Device model',
              'App usage analytics',
              'Cookies',
              'Crash logs',
              'Advertising identifiers',
            ]),
          ],
        ),
        _buildSection(
          context,
          number: '3',
          title: 'Use of Information',
          children: [
            const _BodyText('We use data to:'),
            const _BulletList(items: [
              'Facilitate salon discovery & booking',
              'Process payments',
              'Provide customer support',
              'Send appointment reminders',
              'Deliver push notifications',
              'Improve platform functionality',
              'Prevent fraud',
              'Display targeted offers',
              'Conduct analytics and reporting',
              'Maintain safety and security',
            ]),
          ],
        ),
        _buildSection(
          context,
          number: '4',
          title: 'Sharing of Information',
          children: [
            const _BodyText('We may share data with:'),
            const _SubSectionTitle('A. Partner Salons'),
            const _BulletList(items: [
              'User booking details',
              'Service selection',
              'Contact details',
            ]),
            const _SubSectionTitle('B. Third-Party Service Providers'),
            const _BulletList(items: [
              'Payment gateways',
              'SMS/Email partners',
              'Cloud storage providers',
              'Analytics tools',
              'Marketing partners',
            ]),
            const _SubSectionTitle('C. Legal Authorities (if required)'),
            const _BodyText('Only under:'),
            const _BulletList(items: [
              'Court order',
              'Law enforcement request',
              'Fraud investigation',
            ]),
            const _BodyText(
              'We do not sell or rent personal information to third parties.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '5',
          title: 'Payment & Financial Data',
          children: [
            _BodyText(
              'Payments on Gloup Instantly are processed by certified third-party '
              'payment gateways complying with:',
            ),
            const _BulletList(items: [
              'PCI-DSS Standards',
              'RBI Guidelines',
            ]),
            const _BodyText(
              'We do not store full card numbers, CVV, or sensitive payment credentials.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '6',
          title: 'Data Protection & Security',
          children: [
            const _BodyText('We implement:'),
            const _BulletList(items: [
              'Encryption',
              'Secure servers',
              'Access controls',
              'Multi-level authentication',
              'Regular audits',
            ]),
            const _BodyText(
              'However, no internet transmission is 100% secure. The User agrees that '
              'the Company is not liable for unauthorized access, hacking, or data theft '
              'beyond reasonable measures.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '7',
          title: 'User Rights',
          children: [
            const _BodyText('Users may:'),
            const _BulletList(items: [
              'Request data deletion',
              'Request correction of inaccurate data',
              'Withdraw permissions',
              'Disable location access',
              'Opt-out of marketing communications',
            ]),
            _ContactEmailText(
              prefix: 'Requests can be emailed to ',
              email: 'contact@gloup.in',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '8',
          title: 'Retention of Data',
          children: [
            const _BodyText('We retain information:'),
            const _BulletList(items: [
              'As long as your account is active',
              'As required by Indian law (for audit, tax, or regulatory needs)',
              'As necessary to resolve disputes',
            ]),
          ],
        ),
        _buildSection(
          context,
          number: '9',
          title: 'Children\'s Privacy',
          children: [
            _BodyText(
              'The Platform is not intended for children under 13 years of age.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '10',
          title: 'Third-Party Links',
          children: [
            _BodyText(
              'Gloup Instantly may contain links to external websites. We are not '
              'responsible for their privacy and data practices.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '11',
          title: 'Updates to This Policy',
          children: [
            _BodyText(
              'We may update this Policy at any time. Continued use of the Platform '
              'constitutes acceptance of updated terms.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '12',
          title: 'Contact Information',
          children: [
            const _BodyText('For concerns or queries:'),
            const _BodyText(
              'JR STYLE\'O BOOKING AND FASHION PVT LTD',
              fontWeight: FontWeight.w500,
            ),
            _ContactEmailText(
              prefix: 'Email: ',
              email: 'contact@gloup.in',
            ),
            _ContactPhoneText(
              prefix: 'Phone: ',
              phone: '+91 75388 08796',
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRIVACY POLICY',
          style: context.textTheme.titleLarge?.copyWith(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'For Users & Partners of the Gloup Instantly Platform',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Operated by JR STYLE\'O BOOKING AND FASHION PVT LTD',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.mutedOnSurface,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Last Updated: 01/03/2026',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.mutedOnSurface,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String number,
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. $title',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _SubSectionTitle extends StatelessWidget {
  const _SubSectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        text,
        style: context.textTheme.bodyLarge?.copyWith(
          color: context.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(
    this.text, {
    this.fontWeight = FontWeight.w300,
  });

  final String text;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurface,
          fontWeight: fontWeight,
          height: 1.5,
        ),
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurface,
                          fontWeight: FontWeight.w300,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ContactEmailText extends StatelessWidget {
  const _ContactEmailText({
    required this.prefix,
    required this.email,
  });

  final String prefix;
  final String email;

  Future<void> _launchEmail() async {
    final uri = Uri.parse('mailto:$email');
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w300,
            height: 1.5,
          ),
          children: [
            TextSpan(text: prefix),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: _launchEmail,
                child: Text(
                  email,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactPhoneText extends StatelessWidget {
  const _ContactPhoneText({
    required this.prefix,
    required this.phone,
  });

  final String prefix;
  final String phone;

  Future<void> _launchPhone() async {
    final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w300,
            height: 1.5,
          ),
          children: [
            TextSpan(text: prefix),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: _launchPhone,
                child: Text(
                  phone,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
