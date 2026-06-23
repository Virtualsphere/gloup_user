import 'package:flutter/material.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalDocumentHeader extends StatelessWidget {
  const LegalDocumentHeader({
    super.key,
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

class LegalDocumentDivider extends StatelessWidget {
  const LegalDocumentDivider({super.key});

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

class LegalSection extends StatelessWidget {
  const LegalSection({
    super.key,
    required this.number,
    required this.title,
    required this.children,
  });

  final String number;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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

class LegalSubSectionTitle extends StatelessWidget {
  const LegalSubSectionTitle(this.text, {super.key});

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

class LegalBodyText extends StatelessWidget {
  const LegalBodyText(
    this.text, {
    super.key,
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

class LegalBulletList extends StatelessWidget {
  const LegalBulletList({super.key, required this.items});

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

class LegalContactEmailText extends StatelessWidget {
  const LegalContactEmailText({
    super.key,
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

class LegalDualContactEmailText extends StatelessWidget {
  const LegalDualContactEmailText({
    super.key,
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

class LegalContactPhoneText extends StatelessWidget {
  const LegalContactPhoneText({
    super.key,
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

class LegalFaqItem extends StatelessWidget {
  const LegalFaqItem({
    super.key,
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: context.mutedOnSurface.withValues(alpha: 0.2),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 12),
        title: Text(
          question,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconColor: isDarkMode ? context.colorScheme.onSurface : null,
        collapsedIconColor: isDarkMode ? context.colorScheme.onSurface : null,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
