class SupportArticle {
  const SupportArticle({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.body,
    this.popular = false,
  });

  final String id;
  final String category;
  final String title;
  final String summary;
  final String body;
  final bool popular;
}

const supportArticles = <SupportArticle>[
  SupportArticle(
    id: 'account-security',
    category: 'Conta e segurança',
    title: 'Como manter minha conta segura?',
    summary: 'Proteja sua sessão, dispositivos e chaves privadas.',
    body:
        'Use uma senha forte, revise os dispositivos conectados e nunca compartilhe tokens. O Tureon não solicita sua chave privada nem o código de autenticação por mensagem.',
    popular: true,
  ),
  SupportArticle(
    id: 'messages-encryption',
    category: 'Mensagens',
    title: 'As mensagens ficam salvas onde?',
    summary: 'Entenda o armazenamento local e a sincronização segura.',
    body:
        'Os envelopes são armazenados localmente no dispositivo. O servidor encaminha o conteúdo criptografado e não deve conseguir ler o texto da conversa.',
    popular: true,
  ),
  SupportArticle(
    id: 'devices',
    category: 'Conta e segurança',
    title: 'Como remover um dispositivo?',
    summary: 'Revogue o acesso de celulares e computadores antigos.',
    body:
        'Abra Perfil, Dispositivos conectados e selecione o dispositivo. Remova qualquer sessão que você não reconheça.',
  ),
  SupportArticle(
    id: 'bots',
    category: 'Bots',
    title: 'Como criar um bot com a Forja?',
    summary: 'Encontre a Forja pela busca para criar e gerenciar bots.',
    body:
        'Abra a busca de conversas, procure por @forja_bot e selecione Forja. Envie /start e depois /newbot. Informe o nome de exibição e um username terminado em _bot. O token será enviado na conversa uma única vez; guarde-o em local seguro.',
    popular: true,
  ),
  SupportArticle(
    id: 'notifications',
    category: 'Mensagens',
    title: 'Não recebo notificações.',
    summary: 'Confira permissões, conexão e configurações do sistema.',
    body:
        'Verifique a permissão de notificações do sistema, o modo Não Perturbe e a conexão de rede. Depois, reabra o Tureon para restabelecer o stream.',
  ),
];
