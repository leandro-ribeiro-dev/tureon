enum VerificationBadge { none, verified, developer, celebrity }

VerificationBadge verificationBadgeFromServer(String value) => switch (value) {
  'verified' => VerificationBadge.verified,
  'developer' => VerificationBadge.developer,
  'celebrity' => VerificationBadge.celebrity,
  _ => VerificationBadge.none,
};
