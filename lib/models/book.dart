class Book {
  final String id;
  final String title;
  final String author;
  final String thumbnail;

  Book({required this.id, required this.title, required this.author, required this.thumbnail});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['volumeInfo']['title'] ?? 'Sans titre',
      author: (json['volumeInfo']['authors'] != null)
          ? (json['volumeInfo']['authors'] as List).join(', ')
          : 'Auteur inconnu',
      thumbnail: json['volumeInfo']['imageLinks']?['thumbnail'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'thumbnail': thumbnail,
    };
  }
}
