class ChatMessage {
  final String content;
  final String timestamp;
  final bool isImage;
  final bool isFile;
  final bool isMine;

  ChatMessage({
    required this.content,
    required this.timestamp,
    this.isImage = false,
    this.isFile = false,
    this.isMine = true,
  });
}
