import 'package:firebase_auth/firebase_auth.dart';
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
        title: const Text('Ma Bibliotheque U'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Chercher un livre...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    libraryProvider.fetchBooks(_searchController.text);
                  },
                ),
              ),
            ),
          ),
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
                                  onPressed: () async {
                                    final user = FirebaseAuth.instance.currentUser;
                                    if (user == null) {
                                      if (!context.mounted) {
                                        return;
                                      }
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Connecte-toi avant de reserver.'),
                                        ),
                                      );
                                      return;
                                    }

                                    await libraryProvider.reserveBook(book);
                                  },
                                  child: const Text('Reserver'),
                                )
                              : const Text(
                                  'Reserve',
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
