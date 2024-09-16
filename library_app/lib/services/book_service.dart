import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:library_app/models/book.dart';
import 'package:library_app/services/auth_service.dart';



class BookService {
  final String baseUrl = 'http://localhost:8080/api/books';
  final AuthService _authService = AuthService();

  Future<List<Book>> getAllBooks() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load books: ${response.statusCode}, ${response.body}');
      }
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((book) => Book.fromJson(book)).toList();
    } catch (e) {
      throw Exception('Failed to load books: $e');
    }
  }

  Future<Book> addBook(Book book) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(book.toJson()),
      );

      if (response.statusCode == 200) {
        return Book.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add book: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to add book: $e');
    }
  }

  Future<Book> updateBook(Book book) async {
    try {
      final token = await _authService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/${book.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(book.toJson()),
      );

      if (response.statusCode == 200) {
        return Book.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  Future<void> deleteBook(int id) async {
    try {
      final token = await _authService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  Future<Book> restoreBook(Book book) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/restore'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(book.toJson()),
      );

      if (response.statusCode == 200) {
        return Book.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to restore book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to restore book: $e');
    }
  }
}