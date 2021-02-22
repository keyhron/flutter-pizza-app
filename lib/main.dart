import 'package:flutter/material.dart';

// Pages
import 'package:pizza_app/src/pages/pizza_details.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pizza App',
      home: PizzaDetailsPage(),
    );
  }
}
