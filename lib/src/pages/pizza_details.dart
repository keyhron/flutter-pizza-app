import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Blocs
import 'package:pizza_app/src/blocs/pizza_order_bloc.dart';

// Models
import 'package:pizza_app/src/models/ingredient.dart';

// Provider
import 'package:pizza_app/src/providers/pizza_order_provider.dart';

// Widgets
import 'package:pizza_app/src/widgets/pizza_cart_icon.dart';
import 'package:pizza_app/src/widgets/pizza_size_button.dart';
import 'package:pizza_app/src/widgets/pizza_ingredients.dart';
import 'package:pizza_app/src/widgets/pizza_cart_button.dart';

const _pizzaCartSize = 48.0;

class PizzaDetailsPage extends StatefulWidget {
  @override
  _PizzaDetailsPageState createState() => _PizzaDetailsPageState();
}

class _PizzaDetailsPageState extends State<PizzaDetailsPage> {
  final bloc = PizzaOrderBLoC();

  @override
  Widget build(BuildContext context) {
    return PizzaOrderProvider(
      bloc: bloc,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('New Pizza Orders',
              style: TextStyle(color: Colors.brown, fontSize: 26)),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            PizzaCartIcon(),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              bottom: 50,
              left: 10,
              right: 10,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Expanded(flex: 4, child: _PizzaDetails()),
                    Expanded(flex: 2, child: PizzaIngredients()),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 25,
              height: _pizzaCartSize,
              width: _pizzaCartSize,
              left: MediaQuery.of(context).size.width / 2 - _pizzaCartSize / 2,
              child: PizzaCartButton(onTap: () {
                bloc.startPizzaBlocAnimation();
              }),
            )
          ],
        ),
      ),
    );
  }
}

class _PizzaDetails extends StatefulWidget {
  @override
  __PizzaDetailsState createState() => __PizzaDetailsState();
}

class __PizzaDetailsState extends State<_PizzaDetails>
    with TickerProviderStateMixin {
  // Value notifier

// Animation for ingredients
  AnimationController _animationRotationController;

// Animation for ingredients
  AnimationController _animationController;
  List<Animation> _animationList = <Animation>[];

  BoxConstraints _pizzaConstraints;

  final _keyPizza = GlobalKey();

  Widget _buildIngredientsWidget(Ingredient deletedIngredient) {
    List<Widget> children = [];

    final listIngredients =
        List.from(PizzaOrderProvider.of(context).listIngredients);

    if (deletedIngredient != null) {
      listIngredients.add(deletedIngredient);
    }

    if (_animationList.isNotEmpty) {
      for (int i = 0; i < listIngredients.length; i++) {
        // Get ingredient
        Ingredient ingredient = listIngredients[i];
        final ingredientWidget = Image.asset(ingredient.imageUnit, height: 40);
        for (int j = 0; j < ingredient.positions.length; j++) {
          // Get animation
          final animation = _animationList[j];
          // Get position
          final position = ingredient.positions[j];
          final positionX = position.dx;
          final positionY = position.dy;

          if (i == listIngredients.length - 1 &&
              _animationController.isAnimating) {
            // Set animations
            double fromX = 0.0, fromY = 0.0;

            if (j < 1) {
              // Left
              fromX = -_pizzaConstraints.maxWidth * (1 - animation.value);
            } else if (j < 2) {
              // Right
              fromX = _pizzaConstraints.maxWidth * (1 - animation.value);
            } else if (j < 4) {
              // Top
              fromY = -_pizzaConstraints.maxHeight * (1 - animation.value);
            } else {
              // Bottom
              fromY = _pizzaConstraints.maxHeight * (1 - animation.value);
            }

            final opacity = animation.value;

            if (animation.value > 0) {
              children.add(Opacity(
                opacity: opacity,
                child: Transform(
                    transform: Matrix4.identity()
                      ..translate(
                          fromX + _pizzaConstraints.maxWidth * positionX,
                          fromY + _pizzaConstraints.maxHeight * positionY),
                    child: ingredientWidget),
              ));
            }
          } else {
            children.add(Transform(
                transform: Matrix4.identity()
                  ..translate(_pizzaConstraints.maxWidth * positionX,
                      _pizzaConstraints.maxHeight * positionY),
                child: ingredientWidget));
          }
        }
      }
      return Stack(
        children: children,
      );
    }

    return SizedBox.fromSize();
  }

  void _buildIngredientsAnimation() {
    _animationList.clear();

    _animationList.add(CurvedAnimation(
        curve: Interval(0.0, 0.8, curve: Curves.decelerate),
        parent: _animationController));
    _animationList.add(CurvedAnimation(
        curve: Interval(0.2, 0.8, curve: Curves.decelerate),
        parent: _animationController));
    _animationList.add(CurvedAnimation(
        curve: Interval(0.4, 1.0, curve: Curves.decelerate),
        parent: _animationController));
    _animationList.add(CurvedAnimation(
        curve: Interval(0.1, 0.7, curve: Curves.decelerate),
        parent: _animationController));
    _animationList.add(CurvedAnimation(
        curve: Interval(0.3, 1.0, curve: Curves.decelerate),
        parent: _animationController));
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));
    _animationRotationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));

    // Init widgets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = PizzaOrderProvider.of(context);
      bloc.notifierPizzaBoxAnimation.addListener(() {
        if (bloc.notifierPizzaBoxAnimation.value) {
          _addPizzaCart();
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _animationRotationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = PizzaOrderProvider.of(context);

    return Column(
      children: [
        Expanded(
          child: DragTarget<Ingredient>(
            onAccept: (ingredient) {
              print('Accept');

              bloc.notifierFocused.value = false;

              // Bloc
              bloc.addIngredient(ingredient);

              _buildIngredientsAnimation();
              _animationController.forward(from: 0.0);
            },
            onWillAccept: (ingredient) {
              print('onWillAccept');

              bloc.notifierFocused.value = true;

              return !bloc.containsIngredient(ingredient);
            },
            onLeave: (ingredient) {
              print('onLeave');

              bloc.notifierFocused.value = false;
            },
            builder: (BuildContext context, List<dynamic> list,
                List<dynamic> rejects) {
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  _pizzaConstraints = constraints;
                  return ValueListenableBuilder<PizzaMetadata>(
                      valueListenable: bloc.notifierImagePizza,
                      builder: (context, data, _) {
                        if (data != null) {
                          Future.microtask(() => _startPizzaBoxAnimation(data));
                        }

                        return AnimatedOpacity(
                          duration: Duration(milliseconds: 60),
                          opacity: data != null ? 0.0 : 1,
                          child: ValueListenableBuilder<PizzaSizeState>(
                            valueListenable: bloc.notifierPizzaSize,
                            builder: (context, pizzaSize, _) {
                              return RepaintBoundary(
                                key: _keyPizza,
                                child: RotationTransition(
                                  turns: CurvedAnimation(
                                      curve: Curves.elasticOut,
                                      parent: _animationRotationController),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: ValueListenableBuilder<bool>(
                                            valueListenable:
                                                bloc.notifierFocused,
                                            builder: (context, focused, _) {
                                              return AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 400),
                                                height: focused
                                                    ? constraints.maxHeight *
                                                        pizzaSize.factor
                                                    : constraints.maxHeight *
                                                            pizzaSize.factor -
                                                        10,
                                                child: Stack(
                                                  children: [
                                                    DecoratedBox(
                                                        decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                boxShadow: [
                                                              BoxShadow(
                                                                  blurRadius:
                                                                      14.0,
                                                                  color: Colors
                                                                      .black26,
                                                                  offset:
                                                                      Offset(
                                                                          0.0,
                                                                          2.0),
                                                                  spreadRadius:
                                                                      3.0)
                                                            ]),
                                                        child: Image.asset(
                                                            'assets/images/dish.png')),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Image.asset(
                                                          'assets/images/pizza-1.png'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                      ),
                                      ValueListenableBuilder<Ingredient>(
                                          valueListenable:
                                              bloc.notifierDeletedIngredient,
                                          builder: (BuildContext context,
                                              deletedIngredient, Widget child) {
                                            if (deletedIngredient != null) {
                                              _animateDeletedIngredient(
                                                  deletedIngredient);
                                            }

                                            return AnimatedBuilder(
                                              animation: _animationController,
                                              builder:
                                                  (BuildContext context, _) {
                                                return _buildIngredientsWidget(
                                                    deletedIngredient);
                                              },
                                            );
                                          }),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      });
                },
              );
            },
          ),
        ),
        SizedBox(height: 5),
        ValueListenableBuilder<double>(
            valueListenable: bloc.notifierTotal,
            builder: (context, total, _) {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                        position: animation.drive(Tween<Offset>(
                            begin: Offset(0.0, 0.0),
                            end: Offset(0.0, animation.value))),
                        child: child),
                  );
                },
                child: Text(
                    '\$${total.toString().replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "")}', // Replace decimals if total is trailing zeros
                    key: UniqueKey(),
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown)),
              );
            }),
        SizedBox(height: 15),
        ValueListenableBuilder<PizzaSizeState>(
            valueListenable: bloc.notifierPizzaSize,
            builder: (context, pizzaSize, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PizzaSizeButton(
                    selected: pizzaSize.value == PizzaSizeValue.s,
                    text: 'S',
                    onTap: () {
                      _updatePizzaSize(PizzaSizeValue.s);
                    },
                  ),
                  PizzaSizeButton(
                    selected: pizzaSize.value == PizzaSizeValue.m,
                    text: 'M',
                    onTap: () {
                      _updatePizzaSize(PizzaSizeValue.m);
                    },
                  ),
                  PizzaSizeButton(
                    selected: pizzaSize.value == PizzaSizeValue.l,
                    text: 'L',
                    onTap: () {
                      _updatePizzaSize(PizzaSizeValue.l);
                    },
                  ),
                ],
              );
            })
      ],
    );
  }

  void _updatePizzaSize(PizzaSizeValue value) {
    final bloc = PizzaOrderProvider.of(context);
    bloc.notifierPizzaSize.value = PizzaSizeState(value);
    _animationRotationController.forward(from: 0.0);
  }

  void _animateDeletedIngredient(Ingredient deletedIngredient) async {
    if (deletedIngredient != null) {
      await _animationController.reverse(from: 1.0);
      final bloc = PizzaOrderProvider.of(context);
      bloc.refreshDeletedIngredient();
    }
  }

  void _addPizzaCart() {
    final bloc = PizzaOrderProvider.of(context);

    RenderRepaintBoundary boundary =
        _keyPizza.currentContext.findRenderObject();
    bloc.transformToImage(boundary);
  }

  OverlayEntry _overlayEntry;

  void _startPizzaBoxAnimation(PizzaMetadata metadata) {
    final bloc = PizzaOrderProvider.of(context);

    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(builder: (context) {
        return PizzaOrderAnimation(
            metadata: metadata,
            onCompleted: () {
              _overlayEntry.remove();
              _overlayEntry = null;
              bloc.resetPizzaBlocAnimation();
            });
      });
      Overlay.of(context).insert(_overlayEntry);
    }
  }
}

class PizzaOrderAnimation extends StatefulWidget {
  const PizzaOrderAnimation({Key key, this.metadata, this.onCompleted})
      : super(key: key);
  final PizzaMetadata metadata;
  final VoidCallback onCompleted;

  @override
  _PizzaOrderAnimationState createState() => _PizzaOrderAnimationState();
}

class _PizzaOrderAnimationState extends State<PizzaOrderAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _pizzaScaleAnimation;
  Animation<double> _pizzaOpacityAnimation;
  Animation<double> _boxEnterScaleAnimation;
  Animation<double> _boxExitScaleAnimation;
  Animation<double> _boxExitToCartAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2500));
    _pizzaScaleAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
        CurvedAnimation(curve: Interval(0.0, 0.2), parent: _controller));
    _pizzaOpacityAnimation =
        CurvedAnimation(curve: Interval(0.2, 0.4), parent: _controller);

    _boxEnterScaleAnimation =
        CurvedAnimation(curve: Interval(0.0, 0.2), parent: _controller);
    _boxExitScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(curve: Interval(0.5, 0.7), parent: _controller));

    _boxExitToCartAnimation =
        CurvedAnimation(curve: Interval(0.8, 1.0), parent: _controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metadata = widget.metadata;

    return Positioned(
      width: metadata.size.width,
      height: metadata.size.height,
      top: metadata.position.dy,
      left: metadata.position.dx,
      child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final moveToX = _boxExitToCartAnimation.value > 0
                ? metadata.position.dx +
                    metadata.size.width / 2 * _boxExitToCartAnimation.value
                : 0.0;

            final moveToY = _boxExitToCartAnimation.value > 0
                ? -metadata.size.height / 1.5 * _boxExitToCartAnimation.value
                : 0.0;

            return Opacity(
              opacity: 1 - _boxExitToCartAnimation.value,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translate(moveToX, moveToY)
                  ..rotateZ(_boxExitToCartAnimation.value)
                  ..scale(_boxExitScaleAnimation.value),
                child: Transform.scale(
                  alignment: Alignment.center,
                  scale: 1 - _boxExitToCartAnimation.value,
                  child: Stack(
                    children: [
                      _buildBox(),
                      Opacity(
                        opacity: 1 - _pizzaOpacityAnimation.value,
                        child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..scale(_pizzaScaleAnimation.value)
                              ..translate(
                                  0.0, 20 * 1 - _pizzaOpacityAnimation.value),
                            child: Image.memory(widget.metadata.imageBytes)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget _buildBox() {
    return LayoutBuilder(builder: (context, constraints) {
      final boxHeight = constraints.maxHeight / 2;
      final boxWidth = constraints.maxWidth / 2;
      final minAngle = -45.0;
      final maxAngle = -125.0;
      final boxClosingValue =
          lerpDouble(minAngle, maxAngle, 1 - _pizzaOpacityAnimation.value);

      return Opacity(
        opacity: _boxEnterScaleAnimation.value,
        child: Transform.scale(
          alignment: Alignment.center,
          scale: _boxEnterScaleAnimation.value,
          child: Stack(
            children: [
              Center(
                  child: Transform(
                alignment: Alignment.topCenter,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.003)
                  ..rotateX(degressToRads(minAngle)),
                child: Image.asset(
                  'assets/images/box_inside.png',
                  height: boxHeight,
                  width: boxWidth,
                ),
              )),
              Center(
                  child: Transform(
                alignment: Alignment.topCenter,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.003)
                  ..rotateX(degressToRads(boxClosingValue)),
                child: Image.asset(
                  'assets/images/box_inside.png',
                  height: boxHeight,
                  width: boxWidth,
                ),
              )),
              if (boxClosingValue >= -90)
                Center(
                    child: Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.003)
                    ..rotateX(degressToRads(boxClosingValue)),
                  child: Image.asset(
                    'assets/images/box_front.png',
                    height: boxHeight,
                    width: boxWidth,
                  ),
                ))
            ],
          ),
        ),
      );
    });
  }
}

num degressToRads(num deg) {
  return (deg * pi) / 180.0;
}
