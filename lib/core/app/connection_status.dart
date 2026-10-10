enum ConnectionStatus {
  disconnected,
  connecting,
  synchronizing,
  connected,
  reconnecting,
  authenticating,
}

extension ConnectionStatusPresentation on ConnectionStatus {
  String get label => switch (this) {
    ConnectionStatus.disconnected => 'Desconectado',
    ConnectionStatus.connecting => 'Conectando...',
    ConnectionStatus.synchronizing => 'Sincronizando, aguarde...',
    ConnectionStatus.connected => 'Tureon',
    ConnectionStatus.reconnecting => 'Reconectando...',
    ConnectionStatus.authenticating => 'Autenticando...',
  };
}
