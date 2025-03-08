import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<String> allItems = [
    "Apple",
    "Banana",
    "Cherry",
    "Mango",
    "Orange",
    "Pineapple",
    "Strawberry",
    "Watermelon"
  ];
  List<String> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = List.from(allItems); // Initialize with all items
  }

  void filterSearchResults(String query) {
    List<String> tempSearchList = [];
    if (query.isNotEmpty) {
      tempSearchList = allItems
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      tempSearchList = List.from(allItems);
    }
    setState(() {
      filteredItems = tempSearchList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (value) => filterSearchResults(value),
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredItems.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(filteredItems[index]),
                          leading: const Icon(Icons.search),
                        );
                      },
                    )
                  : const Center(
                      child: Text("No results found",
                          style: TextStyle(fontSize: 16)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}