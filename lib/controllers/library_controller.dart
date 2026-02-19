import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/book.dart';

class LibraryController extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Book> books = [];
  bool isLoading = false;

  User? get _currentUser => _auth.currentUser;

  Future<void> fetchBooks(String query) async {
    isLoading = true;
    notifyListeners();

    try {
      final trimmedQuery = query.trim();
      final snapshot = await _db.collection('books').get();

      books = snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();

      if (trimmedQuery.isNotEmpty) {
        books = books
            .where(
              (book) =>
                  book.title.toLowerCase().contains(trimmedQuery.toLowerCase()) ||
                  book.author.toLowerCase().contains(trimmedQuery.toLowerCase()),
            )
            .toList();

        await _saveSearchQuery(trimmedQuery);
      }
    } catch (e) {
      debugPrint('Erreur Firestore: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _saveSearchQuery(String query) async {
    final user = _currentUser;
    if (user == null || query.isEmpty) {
      return;
    }

    try {
      await _db.collection('search_history').add({
        'userId': user.uid,
        'userEmail': user.email,
        'query': query,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Erreur historique recherche: $e');
    }
  }

  Future<void> reserveBook(Book book) async {
    final user = _currentUser;
    if (user == null) {
      debugPrint('Reservation impossible: aucun utilisateur connecte.');
      return;
    }

    if (!book.isAvailable) {
      return;
    }

    try {
      await _db.collection('reservations').add({
        'userId': user.uid,
        'userEmail': user.email,
        'ID_utilisateur': user.email,
        'Nom_livre': book.id,
        'Date': DateTime.now().toIso8601String(),
      });

      await _db.collection('books').doc(book.id).update({
        'Disponible': false,
      });

      book.isAvailable = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur reservation: $e');
    }
  }
}
