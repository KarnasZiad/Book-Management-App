import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';
import 'favorites_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  Future<List<Book>>? _futureBooks;
  List<String> favoriteIds = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    final favorites = await DBService.getItems();
    setState(() {
      favoriteIds = favorites.map((b) => b.id).toList();
    });
  }

  void _toggleFavorite(Book book) async {
    if (favoriteIds.contains(book.id)) {
      await DBService.deleteItem(book.id);
    } else {
      await DBService.insertItem(book);
    }
    _loadFavorites();
  }

  void _searchBooks() {
    setState(() {
      _futureBooks = ApiService.searchBooks(_controller.text);
    });
  }

  Widget _buildBookCard(Book book) {
    bool isFavorite = favoriteIds.contains(book.id);
    return Card(
      child: ListTile(
        leading: Image.network(book.thumbnail, width: 50, errorBuilder: (ctx, _, __) => Icon(Icons.book)),
        title: Text(book.title),
        subtitle: Text(book.author),
        trailing: IconButton(
          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : null),
          onPressed: () => _toggleFavorite(book),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recherche de livres'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritesPage())),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Mot-clé'),
                    onSubmitted: (_) => _searchBooks(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchBooks,
                ),
              ],
            ),
          ),
          Expanded(
            child: _futureBooks == null
                ? Center(child: Text('Recherche un livre...'))
                : FutureBuilder<List<Book>>(
                    future: _futureBooks,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('Aucun résultat'));
                      }
                      return ListView(
                        children: snapshot.data!.map(_buildBookCard).toList(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
