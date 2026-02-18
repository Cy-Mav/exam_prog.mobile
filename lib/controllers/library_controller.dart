import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class LibraryController extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Book> books = [];
  bool isLoading = false;

  /// Chercher des livres
  Future<void> fetchBooks(String query) async {
    isLoading = true;
    notifyListeners();

    try {
      var snapshot = await _db.collection('books').get();

      books = snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();

      if (query.isNotEmpty) {
        books = books.where((book) =>
          book.title.toLowerCase().contains(query.toLowerCase()) ||
          book.author.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    } catch (e) {
      print("Erreur Firestore: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// Réserver un livre avec email
  Future<void> reserveBook(String userEmail, Book book) async {
    try {
      await _db.collection("reservations").add({
        "ID_utilisateur": userEmail,
        "Nom_livre": book.id,
        "Date": DateTime.now().toIso8601String(),
      });

      await _db.collection("books").doc(book.id).update({
        "isAvailable": false,
      });

      book.isAvailable = false;
      notifyListeners();
    } catch (e) {
      print("Erreur réservation: $e");
    }
  }
}
