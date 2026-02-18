class Book {
  final String id;
  final String title;
  final String author;
  bool isAvailable; // booléen modifiable

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isAvailable,
  });

  factory Book.fromFirestore(dynamic doc) {
    return Book(
      id: doc.id,
      title: doc['Titre'],
      author: doc['Auteur'],
      isAvailable: doc['Disponible'],
    );
  }

  // ignore: strict_top_level_inference
  static Object? fromJson(e) {
    return null;
  }
}
