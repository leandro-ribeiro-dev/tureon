import 'package:flutter/widgets.dart';

import 'app_localizations.dart';
import 'app_localizations_pt.dart';

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get safeLocalizations =>
      AppLocalizations.of(this) ?? AppLocalizationsPt();
}
