import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shop/data/categories.dart';
import 'package:shop/models/category.dart';
import 'package:shop/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String _enterdNamed = '';
  int _enterdQuantity = 0;
  Category _selectedCatrgory = categories[Categories.fruit]!;

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      final Uri url = Uri.https(
          'flutter-project-6e74f-default-rtdb.firebaseio.com',
          'shopping-list.json');

      http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _enterdNamed,
          'quantity': _enterdQuantity,
          'category': _selectedCatrgory.title,
        }),
      )
          .then((res) {
        log(res.body);
        final Map<String, dynamic> resData = json.decode(res.body);
        if (res.statusCode == 200) {
          Navigator.of(context).pop(GroceryItem(
            id: resData['name'],
            name: _enterdNamed,
            quantity: _enterdQuantity,
            category: _selectedCatrgory,
          ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new Item"),
      ),
      body: Padding(
        padding: EdgeInsets.all(9),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                onSaved: (newValue) {
                  _enterdNamed = newValue!;
                },
                decoration: InputDecoration(labelText: 'Name'),
                validator: (String? value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return "Must be Between 1 and 50 Characters";
                  }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                      onSaved: (newValue) {
                        _enterdQuantity = int.parse(newValue!);
                      },
                      decoration: InputDecoration(labelText: 'Quantity'),
                      validator: (String? value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Must Be A Valid Positive Number ";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCatrgory,
                      items: [
                        for (final Category in categories.entries)
                          DropdownMenuItem(
                            value: Category.value,
                            child: Row(
                              children: [
                                Container(
                                  height: 16,
                                  width: 16,
                                  color: Category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(Category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (Category? value) {
                        setState(() {
                          _selectedCatrgory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveItem,
                    child: _isLoading
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
