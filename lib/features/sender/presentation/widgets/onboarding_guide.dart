import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/requests_provider.dart';
import '../../../../core/providers/profile_provider.dart';

class OnboardingGuide extends ConsumerWidget {
  final UserProfile? profile;

  const OnboardingGuide({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (profile == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final requestsAsync = ref.watch(requestsProvider);
    final hasRequests = requestsAsync.value?.isNotEmpty ?? false;

    final steps = [
      _OnboardingStep(
        title: l10n.onboardingStep1,
        isCompleted: profile!.identityValidated,
        onTap: () {
          // In a real app, this would navigate to identity validation
          // For the demo, we'll just toggle it in the provider
          ref
              .read(profileStateProvider.notifier)
              .updateContract('identity', !profile!.identityValidated);
        },
      ),
      _OnboardingStep(
        title: l10n.onboardingStep2,
        isCompleted:
            profile!.adhesionContractAccepted &&
            profile!.certificateContractAccepted,
        onTap: () {
          ref
              .read(profileStateProvider.notifier)
              .updateContract('adhesion', true);
          ref
              .read(profileStateProvider.notifier)
              .updateContract('certificate', true);
        },
      ),
      _OnboardingStep(
        title: l10n.onboardingStep3,
        isCompleted: profile!.hasCertificate,
        onTap: profile!.canCreateCertificate
            ? () => ref.read(profileStateProvider.notifier).createCertificate()
            : null,
      ),
      _OnboardingStep(
        title: l10n.onboardingStep4,
        isCompleted: hasRequests,
        onTap: null, // This auto-completes when they create their first request
      ),
    ];

    final allCompleted = steps.every((s) => s.isCompleted);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  allCompleted ? Icons.stars : Icons.auto_awesome,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  allCompleted ? l10n.onboardingComplete : l10n.onboardingTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...steps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StepRow(step: step),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep {
  final String title;
  final bool isCompleted;
  final VoidCallback? onTap;

  _OnboardingStep({required this.title, required this.isCompleted, this.onTap});
}

class _StepRow extends StatelessWidget {
  final _OnboardingStep step;

  const _StepRow({required this.step});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = step.isCompleted
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    return InkWell(
      onTap: step.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(
            step.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              step.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: step.isCompleted
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: step.isCompleted
                    ? FontWeight.w600
                    : FontWeight.normal,
                decoration: step.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          if (!step.isCompleted && step.onTap != null)
            Icon(
              Icons.chevron_right,
              size: 16,
              color: theme.colorScheme.primary,
            ),
        ],
      ),
    );
  }
}
