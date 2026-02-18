import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatelessWidget {
  final String userEmail; // on utilise l'email de l'étudiant

  const HistoryPage({super.key, required this.userEmail}); // HistoryPage({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historique des emprunts")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reservations')
            .where('ID_utilisateur', isEqualTo: userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final reservations = snapshot.data!.docs;

          if (reservations.isEmpty) {
            return const Center(child: Text("Aucun emprunt pour l'instant."));
          }

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              var res = reservations[index];
              String bookId = res['Nom_livre'];
              String date = res['Date'];

              // On fait une requête pour récupérer le titre du livre
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('books').doc(bookId).get(),
                builder: (context, bookSnapshot) {
                  if (!bookSnapshot.hasData) {
                    return const ListTile(
                      title: Text("Chargement du livre..."),
                    );
                  }

                  var bookData = bookSnapshot.data!;
                  String title = bookData['Titre'];
                  String author = bookData['Auteur'];

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: const Icon(Icons.history, color: Colors.orange),
                      title: Text(title),
                      subtitle: Text("Auteur: $author\nDate: $date"),
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
