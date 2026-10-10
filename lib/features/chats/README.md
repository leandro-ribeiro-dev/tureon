# Organização do chat

`domain/` define mensagens, contratos e regras de envio. O histórico normal permanece local; notificações não substituem a fila durável e os ACKs.

`data/grpc_chat_repository.dart` preserva a API pública e conecta os serviços:

- `chat_stream_coordinator`: sessão, reconexão, prontidão e controle de fluxo.
- `chat_delivery_router`: persistência de entregas, recibos e mutações antes do ACK.
- `chat_message_sender` e `chat_attachment_sender`: comandos na outbox.
- `chat_secret_outbox_preparer`: preparação criptográfica através da porta existente e recuperação da outbox.
- `chat_message_mutations`: edição e exclusão serializadas por mensagem.
- `chat_local_history`: consultas reativas, leitura e prévia.
- `chat_conversation_resolver`: destinatários e snapshots de salas.
- `chat_attachment_inputs`: arquivos, localização e gravação na plataforma.

Os serviços existentes de ACK, outbox e mídia mantêm seus ciclos de vida. Mudanças de protocolo começam em `proto/`.

`presentation/views/chat_screen.dart` compõe a tela. Os arquivos privados em `views/conversation/` dividem ciclo de vida, histórico, compositor, anexos e ações. Widgets reutilizáveis ficam em `presentation/widgets/`; busca e tradução têm controladores em `presentation/controllers/`.

A tradução permanece no dispositivo e usa cache local por conta, mensagem, texto e idioma. Operações assíncronas verificam a geração da conversa antes de atualizar a tela. Preserve essa verificação após novas esperas no fluxo de anexos.

A timeline indexa mensagens para resolver respostas e escuta traduções diretamente. As bolhas mantêm a estrutura e as cores aprovadas.

Valide em `tureon/` com `flutter analyze` e `flutter test`. Os testes de repositório cobrem persistência, ACK, reconexão e chats secretos; os de widgets cobrem compositor e bolhas. Os testes do controlador de tradução cobrem conclusões tardias após reset e descarte.
