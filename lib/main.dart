import 'package:flutter/material.dart';
import 'package:shop/widgets/grocery_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 146, 230, 247),
          surface: const Color.fromARGB(255, 44, 50, 60),

          
          ),
      scaffoldBackgroundColor: Color.fromARGB(255, 49, 57, 59),
        useMaterial3: true,
      ),
      home: const GroceryList(),
    );
  }
}
