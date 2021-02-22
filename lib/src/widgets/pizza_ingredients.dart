import 'package:flutter/material.dart';

// Models
import 'package:pizza_app/src/models/ingredient.dart';

// Provider
import 'package:pizza_app/src/providers/pizza_order_provider.dart';

const itemSize = 45.0;

class PizzaIngredients extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = PizzaOrderProvider.of(context);

    return ValueListenableBuilder(
        valueListenable: bloc.notifierTotal,
        builder: (context, value, _) {
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: ingredients.length,
            itemBuilder: (BuildContext context, int i) {
              final ingredient = ingredients[i];

              return _PizzaIngredientItem(
                ingredient: ingredient,
                exist: bloc.containsIngredient(ingredient),
                onTap: () {
                  bloc.removeIngredient(ingredient);
                },
              );
            },
          );
        });
  }
}

class _PizzaIngredientItem extends StatelessWidget {
  const _PizzaIngredientItem({Key key, this.ingredient, this.exist, this.onTap})
      : super(key: key);
  final Ingredient ingredient;
  final bool exist;
  final VoidCallback onTap;

  Widget _buildChild({bool withImage = true}) {
    return GestureDetector(
      onTap: exist ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7.0),
        child: Container(
            height: itemSize,
            width: itemSize,
            decoration: BoxDecoration(
                color: Color(0xFFF5EED3),
                shape: BoxShape.circle,
                border: exist
                    ? Border.all(color: Color(0xFFF8603B), width: 2)
                    : null),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: withImage
                  ? Image.asset(
                      ingredient.image,
                      fit: BoxFit.contain,
                    )
                  : SizedBox.fromSize(),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: exist
            ? _buildChild()
            : Draggable(
                feedback: DecoratedBox(
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10.0,
                          offset: Offset(0.0, 2.0),
                          spreadRadius: 5.0)
                    ]),
                    child: _buildChild()),
                data: ingredient,
                child: _buildChild()));
  }
}
