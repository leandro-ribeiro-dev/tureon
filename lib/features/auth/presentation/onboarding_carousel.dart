import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_localizations_extensions.dart';
import '../data/onboarding_slides.dart';
import 'widgets/onboarding_slide_view.dart';

/// Competitor-styled Onboarding Carousel screen where Google Sign-In appears strictly on the last slide.
class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({
    required this.slides,
    required this.onSkip,
    required this.onSignInWithGoogle,
    this.isAuthenticating = false,
    this.authError,
    this.initialPage,
    super.key,
  });

  final List<OnboardingSlide> slides;
  final VoidCallback onSkip;
  final VoidCallback onSignInWithGoogle;
  final bool isAuthenticating;
  final String? authError;
  final int? initialPage;

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  late final PageController _pageController;
  late int _page;

  bool get _isLastPage => _page == widget.slides.length - 1;

  @override
  void initState() {
    super.initState();
    final startPage = widget.initialPage ??
        (widget.authError != null ? widget.slides.length - 1 : 0);
    _page = startPage;
    _pageController = PageController(initialPage: startPage);
  }

  @override
  void didUpdateWidget(covariant OnboardingCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.authError != null && oldWidget.authError == null && !_isLastPage) {
      _goToLastPage();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (!_isLastPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToLastPage() {
    _pageController.animateToPage(
      widget.slides.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.safeLocalizations;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Top Header: App Title & Skip button on earlier slides
        SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.appTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
              ),
              if (!_isLastPage)
                TextButton(
                  onPressed: _goToLastPage,
                  child: Text(
                    l10n.onboardingSkip,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Carousel PageView with borderless OnboardingSlideViews
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.slides.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) {
              final slide = widget.slides[index];
              return OnboardingSlideView(
                slide: slide,
                title: _title(l10n, slide.titleKey),
                description: _description(l10n, slide.descriptionKey),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Animated Page Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.slides.length, (index) {
            final isCurrent = index == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isCurrent ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isCurrent
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),

        const SizedBox(height: 24),

        // Display auth error if any
        if (widget.authError != null && _isLastPage) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              widget.authError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 13,
              ),
            ),
          ),
        ],

        // Bottom Action Section: Google Sign-In ONLY on the last slide
        SizedBox(
          width: double.infinity,
          height: 52,
          child: _isLastPage
              ? FilledButton.icon(
                  onPressed: widget.isAuthenticating
                      ? null
                      : widget.onSignInWithGoogle,
                  icon: widget.isAuthenticating
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.account_circle_outlined),
                  label: Text(
                    l10n.loginWithGoogle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : FilledButton.icon(
                  onPressed: _nextPage,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text(
                    'Próximo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  String _title(AppLocalizations l10n, String key) => switch (key) {
        'onboardingRealtimeTitle' => l10n.onboardingRealtimeTitle,
        'onboardingSecretTitle' => l10n.onboardingSecretTitle,
        'onboardingGroupsChannelsTitle' => l10n.onboardingGroupsChannelsTitle,
        'onboardingDevicesTitle' => l10n.onboardingDevicesTitle,
        _ => throw ArgumentError.value(key, 'titleKey', 'Unknown onboarding key'),
      };

  String _description(AppLocalizations l10n, String key) => switch (key) {
        'onboardingRealtimeDescription' => l10n.onboardingRealtimeDescription,
        'onboardingSecretDescription' => l10n.onboardingSecretDescription,
        'onboardingGroupsChannelsDescription' =>
          l10n.onboardingGroupsChannelsDescription,
        'onboardingDevicesDescription' => l10n.onboardingDevicesDescription,
        _ => throw ArgumentError.value(
            key,
            'descriptionKey',
            'Unknown onboarding key',
          ),
      };
}
