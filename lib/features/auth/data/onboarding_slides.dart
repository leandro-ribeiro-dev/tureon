import 'package:flutter/material.dart';

class OnboardingSlide {
  const OnboardingSlide({
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
  });

  final IconData icon;
  final String titleKey;
  final String descriptionKey;
}

const onboardingSlides = <OnboardingSlide>[
  OnboardingSlide(
    icon: Icons.bolt_rounded,
    titleKey: 'onboardingRealtimeTitle',
    descriptionKey: 'onboardingRealtimeDescription',
  ),
  OnboardingSlide(
    icon: Icons.lock_outline_rounded,
    titleKey: 'onboardingSecretTitle',
    descriptionKey: 'onboardingSecretDescription',
  ),
  OnboardingSlide(
    icon: Icons.groups_2_outlined,
    titleKey: 'onboardingGroupsChannelsTitle',
    descriptionKey: 'onboardingGroupsChannelsDescription',
  ),
  OnboardingSlide(
    icon: Icons.devices_outlined,
    titleKey: 'onboardingDevicesTitle',
    descriptionKey: 'onboardingDevicesDescription',
  ),
];
