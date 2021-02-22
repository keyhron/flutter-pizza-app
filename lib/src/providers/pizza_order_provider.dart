import 'package:flutter/material.dart'
    show InheritedWidget, Widget, BuildContext;

// Blocs
import 'package:pizza_app/src/blocs/pizza_order_bloc.dart';

class PizzaOrderProvider extends InheritedWidget {
  final PizzaOrderBLoC bloc;
  final Widget child;

  PizzaOrderProvider({this.bloc, this.child}) : super(child: child);

  static PizzaOrderBLoC of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<PizzaOrderProvider>().bloc;

  @override
  bool updateShouldNotify(covariant PizzaOrderProvider oldWidget) => true;
}
