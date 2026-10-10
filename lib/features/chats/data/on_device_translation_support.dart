import 'package:flutter/foundation.dart';

bool get supportsOnDeviceTranslation =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);
