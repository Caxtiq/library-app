import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:library_app/models/message.dart';
import 'package:library_app/services/auth_service.dart';
import 'package:library_app/services/message_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;

  ChatScreen({required this.receiverId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  late WebSocketChannel channel;
  final AuthService _authService = AuthService();
  final MessageService _messageService = MessageService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _loadMessages();
  }

  void _connectWebSocket() async {
    final token = await _authService.getToken();
    channel = WebSocketChannel.connect(
      Uri.parse('ws://127.0.0.1:8080/ws?token=$token'),
    );
    channel.stream.listen((message) {
      setState(() {
        _messages.add(Message.fromJson(jsonDecode(message)));
      });
    });
  }

  void _loadMessages() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final messages = await _messageService.getMessages(widget.receiverId);
      setState(() {
        _messages.addAll(messages);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load messages: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        final message = await _messageService.sendMessage(
          widget.receiverId,
          _messageController.text,
        );
        setState(() {
          _messages.add(message);
        });
        _messageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_messages[index].content),
                        subtitle: Text(_messages[index].sender as String),
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: 'Message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}