import 'package:library_app/models/user.dart';

class Message {
  final int? id;
  final String content;
  final User sender;
  final User receiver;
  final DateTime timestamp;

  Message({
    this.id,
    required this.content,
    required this.sender,
    required this.receiver,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      sender: User.fromJson(json['sender']),
      receiver: User.fromJson(json['receiver']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}