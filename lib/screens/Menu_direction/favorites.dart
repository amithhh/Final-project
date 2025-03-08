import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> favoriteItems = [
    "Item 1",
    "Item 2",
    "Item 3",
    "Item 4",
  ]; // Example data

  void removeFavorite(int index) {
    setState(() {
      favoriteItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: favoriteItems.isEmpty
          ? const Center(
              child: Text(
                "No favorites added yet!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  child: ListTile(
                    title: Text(favoriteItems[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeFavorite(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}