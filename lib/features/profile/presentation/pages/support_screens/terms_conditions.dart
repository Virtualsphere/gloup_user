import 'package:flutter/material.dart';
import 'package:tressy/features/widgets/profile_appbar.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsConditions extends StatelessWidget {
  const TermsConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfileAppBar(
        title: 'Terms & Conditions',
        centerTitle: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: const SafeArea(
        child: _TermsConditionsContent(),
      ),
    );
  }
}

class _TermsConditionsContent extends StatelessWidget {
  const _TermsConditionsContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        _buildUserTerms(context),
        const _DocumentDivider(),
        _buildPartnerTerms(context),
        const _DocumentDivider(),
        _buildFranchisedSalonTerms(context),
        const _DocumentDivider(),
        _buildTelecallingTerms(context),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildUserTerms(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DocumentHeader(
          title: 'USER TERMS & CONDITIONS',
          subtitle: 'Applicable to Users of the Gloup Instantly Platform',
          company: 'Operated by JR STYLE\'O BOOKING AND FASHION PVT LTD',
          lastUpdated: '01/03/2026',
        ),
        _buildSection(
          context,
          number: '1',
          title: 'Introduction',
          children: [
            _BodyText(
              'These Terms & Conditions ("Terms") govern the use of the digital platform '
              '"Gloup Instantly", including the mobile application, website, and related '
              'services ("Platform"), owned and operated by JR STYLE\'O BOOKING AND FASHION '
              'PVT LTD ("Company", "We", "Us", "Our").',
            ),
            _BodyText(
              'By accessing or using the Platform, You ("User", "Customer", "You", "Your") '
              'acknowledge that You have read, understood, and agreed to be bound by these '
              'Terms, the Privacy Policy, and all applicable laws and regulations.',
            ),
            _BodyText(
              'Gloup Instantly operates strictly as a technology intermediary as defined '
              'under the Information Technology Act, 2000, and the Information Technology '
              '(Intermediary Guidelines and Digital Media Ethics Code) Rules, 2021.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '2',
          title: 'Nature of Platform',
          children: [
            const _BodyText('The platform provides the following:'),
            const _BulletList(items: [
              'Listing of independent third-party salons, parlours, spas, and grooming centers ("Partner(s)")',
              'Online appointment booking services',
              'Pricing display, service menus, and offers',
              'Location-based recommendations',
              'Digital payment facilitation through third-party payment gateways',
            ]),
            const _SubSectionTitle('Gloup Instantly IS NOT'),
            const _BulletList(items: [
              'A salon, parlour, spa, grooming center, or service provider',
              'An employer of salon staff',
              'A guarantor of service quality',
              'A trainer, consultant, or inspector of salons',
              'A party to any service agreement between User and Partner',
            ]),
            const _BodyText(
              'All grooming, beauty, and cosmetic services are provided solely by independent third-party Partners.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '3',
          title: 'No Warranty or Responsibility for Salon Services',
          children: [
            const _BodyText('The User acknowledges and agrees that:'),
            const _BulletList(items: [
              'All services are rendered exclusively by Partners.',
              'The company has no control over the quality, safety, pricing, timing, behaviour, skill, expertise, or outcome of services provided by partners.',
            ]),
            const _BodyText('Gloup Instantly is NOT responsible for:'),
            const _BulletList(items: [
              'Wrong haircut, styling dissatisfaction',
              'Skin damage, burns, rashes, allergic reactions',
              'Injury, medical complications, infection',
              'Poor hygiene or unclean tools',
              'Behaviour, misconduct, or negligence by Partner staff',
              'Theft, loss, or damage to personal items',
              'Delay, cancellation, or rescheduling by the Partner',
            ]),
            const _BodyText(
              'The User agrees that all disputes, complaints, compensation, refunds, liabilities, and claims shall be handled directly between the User and the Partner.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '4',
          title: 'Limitation of Liability',
          children: [
            const _BodyText('To the fullest extent permitted under Indian law:'),
            const _BodyText(
              'Gloup Instantly shall not be liable for any direct, indirect, incidental, special, punitive, exemplary, or consequential damages including but not limited to:',
            ),
            const _BulletList(items: [
              'Bodily injury',
              'Loss of income',
              'Loss of data',
              'Emotional distress',
              'Service dissatisfaction',
              'Financial loss',
            ]),
          ],
        ),
        _buildSection(
          context,
          number: '5',
          title: 'Payment Terms',
          children: [
            const _BulletList(items: [
              'Payment processing is handled by third-party payment gateways.',
              'Gloup Instantly only facilitates payment transfer from user to partner.',
              'Gloup Instantly is not responsible for payment failures, bank delays, disputes, chargebacks, duplicate charges, or refunds.',
            ]),
          ],
        ),
        _buildSection(
          context,
          number: '6',
          title: 'User Obligations',
          children: [
            const _BodyText('Users agree to:'),
            const _BulletList(items: [
              'Provide accurate personal information',
              'Arrive on time for appointments',
              'Ensure they do not have allergies',
              'Verify the service menu before confirming',
              'Read pricing and offers carefully',
              'Follow Partner instructions for safety',
            ]),
          ],
        ),
        _buildSection(
          context,
          number: '7',
          title: 'Appointment Policies',
          children: [
            _BodyText(
              'Partners may cancel, delay, or reschedule appointments.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '8',
          title: 'Reviews & Ratings',
          children: [
            _BodyText(
              'By submitting reviews, the user grants Gloup Instantly an irrevocable right to publish, display, and moderate feedback.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '9',
          title: 'Suspension / Termination',
          children: [
            const _BodyText('Gloup Instantly may suspend or terminate User access for:'),
            const _BulletList(items: [
              'Abuse of platform',
              'Fake bookings',
              'Fraudulent activity',
              'Misuse of offers',
            ]),
          ],
        ),
        _buildSection(
          context,
          number: '11',
          title: 'Contact Information',
          children: [
            const _BodyText(
              'JR STYLE\'O BOOKING AND FASHION PVT LTD',
              fontWeight: FontWeight.w500,
            ),
            const _BodyText(
              '(No. 54, Chola Avenue, SNM Green City, Villar Road, thanjavur)',
            ),
            _DualContactEmailText(
              prefix: 'Email: ',
              emails: ['booking@gloup.in', 'contact@gloup.in'],
            ),
            _ContactPhoneText(
              prefix: 'Phone: ',
              phone: '+91 75388 08796',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPartnerTerms(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DocumentHeader(
          title: 'PARTNER (SALON) TERMS & CONDITIONS',
          subtitle:
              'Applicable to Partner Salons, Parlours & Beauty Centers Using the Gloup Instantly Platform',
          company: 'Owned and operated by: JR STYLE\'O BOOKING AND FASHION PVT LTD',
          lastUpdated: '01/03/2026',
        ),
        _buildSection(
          context,
          number: '1',
          title: 'Introduction',
          children: [
            _BodyText(
              'These Partner Terms & Conditions ("Agreement" and "Terms") govern the relationship '
              'between independent third-party salons, parlours, grooming centres, spas, or beauty '
              'service operators ("Partner", "Salon", "Vendor", "You", and "Your") and JR STYLE\'O '
              'BOOKING AND FASHION PVT LTD.',
            ),
            const _BodyText('Gloup Instantly operates as a digital technology aggregator in accordance with:'),
            const _BulletList(items: [
              'The Information Technology Act, 2000',
              'Intermediary Guidelines & Digital Media Ethics Code Rules, 2021',
              'The Indian Contract Act, 1872',
              'Consumer Protection Act, 2019',
            ]),
            const _BodyText('Gloup Instantly does not provide any salon or grooming services.'),
          ],
        ),
        _buildSection(
          context,
          number: '2',
          title: 'Nature of Partnership',
          children: [
            const _BodyText('The Partner acknowledges that:'),
            const _BulletList(items: [
              'Gloup Instantly is only a booking intermediary.',
              'Gloup Instantly does not employ salon staff.',
              'Gloup Instantly does not control, inspect, or supervise salon operations.',
              'Gloup Instantly does not guarantee customers, revenue, ratings, or bookings.',
            ]),
          ],
        ),
        _buildSection(
          context,
          number: '3',
          title: 'Responsibilities of the Partner',
          children: [
            const _BodyText('The Partner shall:'),
            const _BulletList(items: [
              'Ensure proper hygiene, cleanliness, safety, and sanitisation.',
              'Use trained, certified, and professional staff.',
              'Display accurate pricing, offers, and service menus.',
              'Deliver services at the requested date & time.',
              'Ensure lawful operation of the business including licences and GST.',
            ]),
          ],
        ),
        _buildSection(
          context,
          number: '4',
          title: 'No Liability of Gloup Instantly for Partner Services',
          children: [
            const _BodyText(
              'The Partner expressly acknowledges that Gloup Instantly bears NO responsibility or liability for:',
            ),
            const _BulletList(items: [
              'Poor service quality',
              'Wrong haircut or styling',
              'Burns, rashes, allergic reactions',
              'Skin infections or medical issues',
              'Injury, slips, cuts, or accidents',
              'Theft or loss inside the premises',
              'Behaviour, negligence, or misconduct by staff',
            ]),
          ],
        ),
        _buildSection(
          context,
          number: '5',
          title: 'Customer Complaints & Dispute Handling',
          children: [
            _BodyText(
              'All customer complaints and resolutions are the sole responsibility of the Partner.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '6',
          title: 'Payment Terms',
          children: [
            _BodyText(
              'Payments collected through Gloup Instantly\'s payment gateway are transferred to the Partner after deduction of applicable charges.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '7',
          title: 'Marketing, Promotions & Notifications',
          children: [
            _BodyText(
              'The Partner authorises Gloup Instantly to display salon profile, images, services, and prices publicly and promote offers.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '8',
          title: 'Service Quality & Compliance',
          children: [
            _BodyText(
              'Failure to comply with hygiene and legal standards may result in suspension.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '9',
          title: 'Ratings & Reviews',
          children: [
            _BodyText(
              'Gloup Instantly reserves the right to publish or remove reviews.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '10',
          title: 'No Employer–Employee Relationship',
          children: [
            _BodyText(
              'Nothing in this Agreement creates employer–employee relationship, partnership firm, or agency.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '11',
          title: 'Liability & Indemnity',
          children: [
            _BodyText(
              'The Partner shall indemnify and hold harmless Gloup Instantly from all claims arising out of services.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '12',
          title: 'Intellectual Property',
          children: [
            _BodyText(
              'The Partner shall not misuse Gloup Instantly\'s trademarks or logo.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '13',
          title: 'Termination',
          children: [
            _BodyText(
              'Gloup Instantly may suspend or remove the Partner without notice for misconduct or fraud.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '15',
          title: 'Contact Information',
          children: [
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
      ],
    );
  }

  Widget _buildFranchisedSalonTerms(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DocumentHeader(
          title: 'TERMS & CONDITIONS FOR FRANCHISED SALONS',
          subtitle:
              '(For salons operating under franchise brands such as Naturals, Green Trends, Toni & Guy, etc.)',
          company: 'Owned and Operated by JR STYLE\'O BOOKING AND FASHION PVT LTD',
          lastUpdated: null,
          footer:
              'These terms govern the listing and participation of franchised salons on the Gloup Instantly platform.',
        ),
        _buildSection(
          context,
          number: '1',
          title: 'Applicability',
          children: [
            _BodyText(
              'This document applies to any salon that operates under a franchised brand and chooses to register or list their salon on the Gloup Instantly platform.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '2',
          title: 'Platform Status (Technology Intermediary)',
          children: [
            const _BodyText(
              'Gloup Instantly functions solely as a technology platform and digital intermediary.',
            ),
            const _BodyText('Gloup Instantly:'),
            const _BulletList(items: [
              'Does not own or operate salons',
              'Does not manage franchise relationships',
              'Does not verify brand affiliations',
              'Does not supervise salon operations',
              'Does not participate in franchise agreements',
            ]),
          ],
        ),
        _buildSection(
          context,
          number: '3',
          title: 'Open Platform Declaration',
          children: [
            _BodyText(
              'Gloup Instantly is an open-access platform available to all salons.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '4',
          title: 'Franchise Compliance Responsibility',
          children: [
            _BodyText(
              'Salon owners are solely responsible for ensuring their franchise agreements permit listing on third-party platforms.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '5',
          title: 'No Liability of Gloup Instantly',
          children: [
            _BodyText(
              'Gloup Instantly shall not be responsible for franchise disputes, brand misuse, legal conflicts, or trademark issues.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '6',
          title: 'Self-Declaration by Salon Owner',
          children: [
            _BodyText(
              'By registering, the salon owner declares they have the legal right to operate and list the salon.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '7',
          title: 'Full Responsibility of the Franchised Salon',
          children: [
            _BodyText(
              'The franchised salon accepts 100% responsibility for compliance with franchise agreements.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '8',
          title: 'Indemnity Clause',
          children: [
            _BodyText(
              'The salon agrees to indemnify Gloup Instantly from any franchise-related claims.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '9',
          title: 'Platform Communication Rights',
          children: [
            _BodyText(
              'Gloup Instantly may contact salons via phone, SMS, WhatsApp, or email.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '10',
          title: 'Platform Content Disclaimer',
          children: [
            _BodyText(
              'All salon information is uploaded and controlled by the salon owner.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '11',
          title: 'Right to Remove Listings',
          children: [
            _BodyText(
              'Gloup Instantly reserves the right to remove listings if complaints or violations occur.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '12',
          title: 'No Compensation or Refund',
          children: [
            _BodyText(
              'Removed salons are not entitled to compensation.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '13',
          title: 'Limitation of Liability',
          children: [
            _BodyText(
              'Gloup Instantly\'s role is limited strictly to providing a technology platform.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '14',
          title: 'Governing Law',
          children: [
            _BodyText(
              'These terms shall be governed by the laws of India.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '15',
          title: 'Acceptance of Terms',
          children: [
            _BodyText(
              'By registering, the salon owner agrees to these conditions.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTelecallingTerms(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DocumentHeader(
          title: 'TERMS & CONDITIONS FOR TELECALLING TEAM',
          subtitle: 'TELECALLING DISCLAIMER & RESPONSIBILITY POLICY',
          company: 'Owned and Operated by: JR STYLE\'O BOOKING AND FASHION PVT LTD',
          lastUpdated: null,
          footer:
              'This policy governs all telecalling activities related to Gloup Instantly.',
        ),
        _buildSection(
          context,
          number: '1',
          title: 'Purpose of Telecalling',
          children: [
            _BodyText(
              'This policy governs all telephonic communication conducted by Gloup Instantly representatives including telecallers, sales agents, onboarding executives, and business development representatives.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '2',
          title: 'Nature of Telecalling Activity',
          children: [
            const _BodyText(
              'Telecalling is conducted only to introduce the platform and provide information.',
            ),
            const _BodyText('Telecallers are not authorised to make commitments.'),
          ],
        ),
        _buildSection(
          context,
          number: '3',
          title: 'Telecaller Authority Limitations',
          children: [
            _BodyText(
              'Telecallers are prohibited from guaranteeing bookings, promising revenue, offering discounts not officially published, or signing agreements verbally.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '4',
          title: 'Informational Nature of Phone Calls',
          children: [
            _BodyText(
              'All calls are purely informational.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '5',
          title: 'No Liability for Verbal Communication',
          children: [
            _BodyText(
              'Gloup Instantly shall not be responsible for miscommunication or misunderstanding during calls.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '6',
          title: 'Official Information Source',
          children: [
            _BodyText(
              'Only written policies, agreements, and website information are considered official.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '7',
          title: 'Telecaller Code of Conduct',
          children: [
            _BodyText(
              'Telecallers must communicate respectfully and avoid misleading claims.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '8',
          title: 'Open Platform Disclosure',
          children: [
            _BodyText(
              'Salons can independently download the Gloup Instantly Partner App and onboard themselves.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '9',
          title: 'Recording and Monitoring',
          children: [
            _BodyText(
              'Calls may be recorded for training and dispute resolution.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '10',
          title: 'Limitation of Liability',
          children: [
            _BodyText(
              'Gloup Instantly is not liable for business decisions made after calls.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '11',
          title: 'Indemnification',
          children: [
            _BodyText(
              'Salons agree not to file claims based on verbal conversations.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '12',
          title: 'Policy Updates',
          children: [
            _BodyText(
              'The company may update this policy at any time.',
            ),
          ],
        ),
        _buildSection(
          context,
          number: '13',
          title: 'Acceptance of Policy',
          children: [
            _BodyText(
              'Continuing telephonic discussions implies acceptance of this policy.',
            ),
          ],
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

class _DocumentHeader extends StatelessWidget {
  const _DocumentHeader({
    required this.title,
    required this.subtitle,
    required this.company,
    this.lastUpdated,
    this.footer,
  });

  final String title;
  final String subtitle;
  final String company;
  final String? lastUpdated;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleLarge?.copyWith(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          company,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.mutedOnSurface,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (lastUpdated != null) ...[
          const SizedBox(height: 12),
          Text(
            'Last Updated: $lastUpdated',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.mutedOnSurface,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (footer != null) ...[
          const SizedBox(height: 12),
          Text(
            footer!,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _DocumentDivider extends StatelessWidget {
  const _DocumentDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        color: context.mutedOnSurface.withValues(alpha: 0.4),
        thickness: 1,
        height: 32,
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

class _DualContactEmailText extends StatelessWidget {
  const _DualContactEmailText({
    required this.prefix,
    required this.emails,
  });

  final String prefix;
  final List<String> emails;

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = context.textTheme.bodyMedium?.copyWith(
      color: context.colorScheme.primary,
      fontWeight: FontWeight.w400,
      height: 1.5,
      decoration: TextDecoration.underline,
    );
    final baseStyle = context.textTheme.bodyMedium?.copyWith(
      color: context.colorScheme.onSurface,
      fontWeight: FontWeight.w300,
      height: 1.5,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(prefix, style: baseStyle),
          GestureDetector(
            onTap: () => _launchEmail(emails[0]),
            child: Text(emails[0], style: linkStyle),
          ),
          Text(' / ', style: baseStyle),
          GestureDetector(
            onTap: () => _launchEmail(emails[1]),
            child: Text(emails[1], style: linkStyle),
          ),
        ],
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
