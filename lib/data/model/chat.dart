class Chat {
  final int transaksiId;
  final String message;
  final int senderId;
  final String chatType;
  final String senderName;
  final String? senderImage;
  final DateTime createdAt;

  Chat({
    this.senderImage,
    required this.transaksiId,
    required this.message,
    required this.senderId,
    required this.chatType,
    required this.senderName,
    required this.createdAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      transaksiId: json['transaksi_id'],
      senderImage: json['sender_image'],
      message: json['message'],
      senderId: json['sender_id'],
      chatType: json['chat_type'],
      senderName: json['sender_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
