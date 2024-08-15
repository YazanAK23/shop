import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/categories.dart';
import 'package:shop/models/grocery_item.dart';
import 'package:shop/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;
  String? _error;

  void _loadData() async {
    final Uri url = Uri.https(
      'flutter-project-6e74f-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    final http.Response res = await http.get(url).catchError((err) {
      log(err.toString());
      return http.Response('Failed to load data. Test your connection.', 400);
    });

    if (res.statusCode >= 400) {
      setState(() {
        _error = "Failed to fetch data. Please try again later.";
        _isLoading = false;  // Ensure loading stops
      });
      return;
    }

    if (res.body == 'null') {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (res.body.isNotEmpty) {
      final Map<String, dynamic>? loadedData = json.decode(res.body);

      if (loadedData != null) {
        final List<GroceryItem> loadedItems = [];

        for (var item in loadedData.entries) {
          if (item.value['name'] != null &&
              item.value['quantity'] != null &&
              item.value['category'] != null) {
            final matchingEntry = categories.entries.firstWhere(
              (element) => element.value.title == item.value['category'],
              orElse: () => categories.entries.first,
            );

            loadedItems.add(GroceryItem(
              id: item.key,
              name: item.value['name'],
              quantity: item.value['quantity'],
              category: matchingEntry.value,
            ));
          }
        }

        setState(() {
          _groceryItems = loadedItems;
          _isLoading = false;  // Ensure loading stops
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No item added yet.'),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (_) {
            _removeItem(_groceryItems[index]);
          },
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              height: 24,
              width: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Grocery'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: content,
    );
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final Uri url = Uri.https(
      'flutter-project-6e74f-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );

    try {
      final res = await http.delete(url);

      if (res.statusCode >= 400) {
        throw Exception('Failed to delete the item.');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('We could not delete the item.')),
      );
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  Future<void> _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }
}
