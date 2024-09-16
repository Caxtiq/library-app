import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:library_app/models/message.dart';
import 'package:library_app/services/auth_service.dart';

class MessageService {
  final String baseUrl = 'http://localhost:8080/api/messages';
  final AuthService _authService = AuthService();

  Future<List<Message>> getMessages(String receiverId) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/$receiverId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((message) => Message.fromJson(message)).toList();
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  Future<Message> sendMessage(String receiverId, String content) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'receiverId': receiverId,
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        return Message.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> deleteMessage(int messageId) async {
    try {
      final token = await _authService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$messageId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }
}