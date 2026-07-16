import 'package:flutter/material.dart';
import 'package:tressy/core/constants/cancellation_policy.dart';
import 'package:tressy/features/profile/presentation/pages/support_screens/legal_content_widgets.dart';
import 'package:tressy/features/widgets/profile_appbar.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class Cancellation extends StatelessWidget {
  const Cancellation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfileAppBar(
        title: 'Cancellation & Refund',
        centerTitle: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: const SafeArea(
        child: _CancellationContent(),
      ),
    );
  }
}

class _CancellationContent extends StatelessWidget {
  const _CancellationContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        const LegalDocumentHeader(
          title: 'CANCELLATION & REFUND POLICY',
          subtitle: 'GloUp Salon Booking Platform',
          company: 'Operated by JR STYLE\'O BOOKING AND FASHION PVT LTD',
          lastUpdated: '01/03/2026',
        ),
        LegalSection(
          number: '1',
          title: 'Customer Cancellation',
          children: [
            LegalSubSectionTitle(
                CancellationPolicy.moreThanBeforeAppointmentTitle),
            const LegalBulletList(items: [
              '100% refund.',
              'Refund processed within 5–7 business days.',
            ]),
            LegalSubSectionTitle(
                CancellationPolicy.lessThanBeforeAppointmentTitle),
            const LegalBulletList(items: [
              '50% refund.',
              'Remaining amount retained to compensate salon slot blocking.',
            ]),
            LegalSubSectionTitle('No Show'),
            LegalBulletList(items: [
              'No refund.',
              'Appointment considered completed.',
            ]),
          ],
        ),
        const LegalSection(
          number: '2',
          title: 'Salon Cancellation',
          children: [
            LegalBodyText(
              'If a salon cancels a confirmed appointment:',
            ),
            LegalBulletList(items: [
              'Customer receives 100% refund.',
              'Customer may reschedule at another salon.',
              'Repeated cancellations may result in penalties or account suspension.',
            ]),
          ],
        ),
        const LegalSection(
          number: '3',
          title: 'Refund Conditions',
          children: [
            LegalBodyText('Refunds are applicable when:'),
            LegalBulletList(items: [
              'Salon cancels appointment.',
              'Duplicate payment occurs.',
              'Technical issue causes failed booking after payment deduction.',
              'Service is unavailable at the booked time.',
            ]),
            LegalBodyText('Refunds are not applicable when:'),
            LegalBulletList(items: [
              'Customer does not arrive for the appointment.',
              'Customer arrives significantly late and misses the slot.',
              'Service has already been completed.',
            ]),
          ],
        ),
        const LegalSection(
          number: '4',
          title: 'Late Arrival Policy',
          children: [
            LegalBulletList(items: [
              'Customers arriving more than 15 minutes late may have their appointment rescheduled based on salon availability.',
              'Refunds may not be applicable in such cases.',
            ]),
          ],
        ),
        const LegalSection(
          number: '5',
          title: 'Offer & Discount Policy',
          children: [
            LegalBulletList(items: [
              'All GloUp offers are available only through the GloUp app.',
              'Offers cannot be combined unless specifically stated.',
              'Salons reserve the right to verify booking details before providing services.',
              'GloUp may modify or discontinue offers without prior notice.',
            ]),
          ],
        ),
        LegalSection(
          number: '6',
          title: 'Contact Us',
          children: const [
            LegalBodyText(
              'GloUp Support',
              fontWeight: FontWeight.w500,
            ),
            LegalContactEmailText(
              prefix: 'Email: ',
              email: 'contact@gloup.in',
            ),
            _WebsiteLinkText(),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _WebsiteLinkText extends StatelessWidget {
  const _WebsiteLinkText();

  Future<void> _launchWebsite() async {
    final uri = Uri.parse('https://www.gloup.in');
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
            const TextSpan(text: 'Website: '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: _launchWebsite,
                child: Text(
                  'www.gloup.in',
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
