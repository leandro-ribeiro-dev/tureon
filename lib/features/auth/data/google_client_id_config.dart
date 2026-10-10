const googleWebClientId =
    '926051807017-fn1t90pct3to5bofhsh0qvtsedir80tr.apps.googleusercontent.com';
const googleDesktopClientId =
    '926051807017-ffd666hbtjh68bffef4s4vlf8un7s0r6.apps.googleusercontent.com';

String resolveServerClientId(String environmentClientId) =>
    environmentClientId.trim().isEmpty
    ? googleWebClientId
    : environmentClientId.trim();

String resolveLinuxDesktopClientId(String environmentClientId) =>
    environmentClientId.trim().isEmpty
    ? googleDesktopClientId
    : environmentClientId.trim();
