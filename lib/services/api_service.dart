import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService {
  static Future<List<Book>> searchBooks(String query) async {
    final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List books = data['items'];
      return books.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Erreur de chargement');
    }
  }
}
