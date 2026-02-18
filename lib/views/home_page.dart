import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/library_controller.dart';
import '../models/book.dart';
import 'history_page.dart';

class HomePage extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryProvider = Provider.of<LibraryController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ma Bibliothèque U 🏪"),
        actions: [
          // Bouton Historique
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HistoryPage(userEmail: "papanaexauce@gmail.com"), // à remplacer par l'email connecté
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Chercher un livre...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Recherche dans Firestore
                    libraryProvider.fetchBooks(_searchController.text);
                  },
                ),
              ),
            ),
          ),

          // Liste des livres
          Expanded(
            child: libraryProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: libraryProvider.books.length,
                    itemBuilder: (context, index) {
                      final Book book = libraryProvider.books[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: const Icon(Icons.book, color: Colors.blue),
                          title: Text(book.title),
                          subtitle: Text(book.author),
                          trailing: book.isAvailable
                              ? ElevatedButton(
                                  onPressed: () {
                                    // Réserver le livre avec l'email
                                    libraryProvider.reserveBook(
                                        "papanaexauce@gmail.com", book);
                                  },
                                  child: const Text("Réserver"),
                                )
                              : const Text(
                                  "Réservé",
                                  style: TextStyle(color: Color.fromARGB(255, 244, 54, 225)),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
