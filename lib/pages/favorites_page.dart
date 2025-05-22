import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/db_service.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<Book>> _favorites;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    _favorites = DBService.getItems();
    setState(() {});
  }

  void _deleteBook(String id) async {
    await DBService.deleteItem(id);
    _loadFavorites();
  }

  Widget _buildBookCard(Book book) {
    return Card(
      child: ListTile(
        leading: Image.network(book.thumbnail, width: 50, errorBuilder: (ctx, _, __) => Icon(Icons.book)),
        title: Text(book.title),
        subtitle: Text(book.author),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => _deleteBook(book.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mes favoris')),
      body: FutureBuilder<List<Book>>(
        future: _favorites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text('Aucun favori enregistré'));

          return ListView(children: snapshot.data!.map(_buildBookCard).toList());
        },
      ),
    );
  }
}
