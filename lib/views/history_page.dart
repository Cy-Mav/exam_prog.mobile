import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  bool _belongsToUser(Map<String, dynamic> data, User user) {
    final dynamic userId = data['userId'];
    final dynamic legacyEmail = data['ID_utilisateur'];

    if (userId is String && userId == user.uid) {
      return true;
    }

    if (legacyEmail is String && user.email != null && legacyEmail == user.email) {
      return true;
    }

    return false; // scalopandre
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des emprunts')),
      body: user == null
          ? const Center(child: Text('Aucun utilisateur connecte.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('reservations').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reservations = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _belongsToUser(data, user);
                }).toList();

                if (reservations.isEmpty) {
                  return const Center(child: Text("Aucun emprunt pour l'instant."));
                }

                return ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final res = reservations[index].data() as Map<String, dynamic>;
                    final String bookId = (res['Nom_livre'] ?? '').toString();
                    final String date = (res['Date'] ?? '').toString();

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('books').doc(bookId).get(),
                      builder: (context, bookSnapshot) {
                        if (!bookSnapshot.hasData) {
                          return const ListTile(title: Text('Chargement du livre...'));
                        }

                        final bookDoc = bookSnapshot.data!;
                        if (!bookDoc.exists) {
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: const Icon(Icons.history, color: Colors.orange),
                              title: const Text('Livre introuvable'),
                              subtitle: Text('Date: $date'),
                            ),
                          );
                        }

                        final bookData = bookDoc.data() as Map<String, dynamic>;
                        final String title = (bookData['Titre'] ?? 'Sans titre').toString();
                        final String author = (bookData['Auteur'] ?? 'Auteur inconnu').toString();

                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: const Icon(Icons.history, color: Colors.orange),
                            title: Text(title),
                            subtitle: Text('Auteur: $author\nDate: $date'),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
