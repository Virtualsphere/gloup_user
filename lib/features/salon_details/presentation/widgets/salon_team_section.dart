import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/features/salon_details/domain/entities/salon_detail_entity.dart';
import 'package:tressy/features/salon_details/presentation/widgets/team_member_card.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class SalonTeamSection extends StatelessWidget {
  final bool isDarkMode;
  final SalonDetailEntity salonDetail;

  const SalonTeamSection({
    super.key,
    required this.isDarkMode,
    required this.salonDetail,
  });

  @override
  Widget build(BuildContext context) {
    return _buildTeamSection(context, isDarkMode, salonDetail);
  }

  Widget _buildTeamSection(
      BuildContext context, bool isDarkMode, SalonDetailEntity salonDetail) {
    if (salonDetail.teamMembers.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 48,
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              SizedBox(height: AppSizes.spaceM),
              Text(
                'No team members added',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - (AppSizes.paddingL * 3)) / 4;

        return Wrap(
          spacing: AppSizes.paddingL,
          runSpacing: AppSizes.paddingL,
          children: salonDetail.teamMembers.map((member) {
            return SizedBox(
              width: cardWidth,
              child: TeamMemberCard(
                name: member.name,
                role: member.role,
                imageUrl: member.imageUrl,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
