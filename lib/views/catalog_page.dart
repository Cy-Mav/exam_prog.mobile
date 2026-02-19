import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data!.docs;
          if (books.isEmpty) {
            return const Center(child: Text('Aucun livre dans le catalogue.'));
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final data = books[index].data() as Map<String, dynamic>;
              final String title = (data['Titre'] ?? 'Sans titre').toString();
              final String author = (data['Auteur'] ?? 'Auteur inconnu').toString();
              final bool isAvailable = (data['Disponible'] ?? false) == true;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.book, color: Colors.blue),
                  title: Text(title),
                  subtitle: Text(author),
                  trailing: Text(
                    isAvailable ? 'Disponible' : 'Reserve',
                    style: TextStyle(
                      color: isAvailable ? Colors.green : const Color.fromARGB(255, 244, 54, 225),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
