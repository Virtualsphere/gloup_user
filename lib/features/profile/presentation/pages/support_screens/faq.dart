import 'package:flutter/material.dart';
import 'package:tressy/features/profile/presentation/pages/support_screens/legal_content_widgets.dart';
import 'package:tressy/features/widgets/profile_appbar.dart';

class Faq extends StatelessWidget {
  const Faq({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfileAppBar(
        title: 'FAQs',
        centerTitle: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: const SafeArea(
        child: _FaqContent(),
      ),
    );
  }
}

class _FaqContent extends StatelessWidget {
  const _FaqContent();

  static const _faqs = [
    (
      question: 'What is GloUp?',
      answer:
          'GloUp is a salon booking platform that helps customers discover nearby salons, '
          'book appointments, and enjoy exclusive offers and discounts.',
    ),
    (
      question: 'How do I book a salon appointment?',
      answer:
          'Search for a salon, choose your preferred service, select a time slot, make payment, '
          'and confirm your booking instantly.',
    ),
    (
      question: 'Are GloUp offers available directly at the salon?',
      answer:
          'No. GloUp offers and discounts are exclusively available through the GloUp app.',
    ),
    (
      question: 'Is online payment mandatory?',
      answer:
          'Most bookings require online payment to confirm your appointment and secure the '
          'discounted offer.',
    ),
    (
      question: 'How do I know my booking is confirmed?',
      answer:
          'You will receive an in-app notification, booking confirmation screen, and confirmation '
          'message after successful payment.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        const LegalDocumentHeader(
          title: 'FREQUENTLY ASKED QUESTIONS (FAQs)',
          subtitle: 'GloUp Salon Booking Platform',
          company: 'Operated by JR STYLE\'O BOOKING AND FASHION PVT LTD',
          lastUpdated: '01/03/2026',
        ),
        ..._faqs.map(
          (faq) => LegalFaqItem(
            question: faq.question,
            answer: faq.answer,
          ),
        ),
        const SizedBox(height: 8),
        const LegalBodyText(
          'Still have questions? Reach out to GloUp Support at contact@gloup.in or visit www.gloup.in.',
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
