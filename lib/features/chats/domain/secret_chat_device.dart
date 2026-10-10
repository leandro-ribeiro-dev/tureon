class SecretChatDevice {
  const SecretChatDevice({
    required this.deviceId,
    required this.name,
    required this.platform,
    required this.signalDeviceId,
  });

  final String deviceId;
  final String name;
  final String platform;
  final int signalDeviceId;
}
