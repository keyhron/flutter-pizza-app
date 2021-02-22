import 'package:flutter/material.dart';

// Bloc
import 'package:pizza_app/src/providers/pizza_order_provider.dart';

class PizzaCartIcon extends StatefulWidget {
  @override
  PizzaCartIconState createState() => PizzaCartIconState();
}

class PizzaCartIconState extends State<PizzaCartIcon>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  Animation<double> _animationScaleOut;
  Animation<double> _animationScaleIn;

  int counter = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));

    _animationScaleOut =
        CurvedAnimation(curve: Interval(0.0, 0.5), parent: _controller);

    _animationScaleIn =
        CurvedAnimation(curve: Interval(0.5, 1.0), parent: _controller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = PizzaOrderProvider.of(context);
      bloc.notifierCartIconAnimation.addListener(() {
        counter = bloc.notifierCartIconAnimation.value;
        _controller.forward(from: 0.0);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          double scale;
          const scaleFactor = 0.5;
          if (_animationScaleOut.value < 1.0) {
            scale = 1.0 + scaleFactor * _animationScaleOut.value;
          } else if (_animationScaleOut.value <= 1.0) {
            scale = (1.0 + scaleFactor) - scaleFactor * _animationScaleIn.value;
          }

          return Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.shopping_cart_outlined, color: Colors.brown),
                ),
                if (_animationScaleOut.value > 0 && counter > 0)
                  Positioned(
                      top: 8,
                      right: 9,
                      child: Transform.scale(
                        scale: _animationScaleOut.value,
                        child: CircleAvatar(
                          backgroundColor: Colors.redAccent,
                          child: Text(
                            counter.toString(),
                            style: TextStyle(fontSize: 8.0),
                          ),
                          radius: 6,
                        ),
                      ))
              ],
            ),
          );
        });
  }
}
