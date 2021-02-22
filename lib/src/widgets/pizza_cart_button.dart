import 'package:flutter/material.dart';

class PizzaCartButton extends StatefulWidget {
  const PizzaCartButton({Key key, this.onTap}) : super(key: key);
  final VoidCallback onTap;

  @override
  _PizzaCartButtonState createState() => _PizzaCartButtonState();
}

class _PizzaCartButtonState extends State<PizzaCartButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this,
        lowerBound: 0.5,
        upperBound: 1.0,
        duration: Duration(milliseconds: 150),
        reverseDuration: Duration(milliseconds: 200));

    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _animateButton() async {
    await _animationController.forward(from: 0.0);
    await _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        _animateButton();
      },
      child: AnimatedBuilder(
          animation: _animationController,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFD285),
                      Color(0xFFF8603B),
                    ]),
                boxShadow: [
                  BoxShadow(
                      color: Color(0xFFF8603B),
                      blurRadius: 15.0,
                      offset: Offset(0.0, 4.0),
                      spreadRadius: 2.0)
                ]),
            child: Icon(Icons.shopping_cart_outlined,
                color: Colors.white, size: 28),
          ),
          builder: (BuildContext context, Widget child) {
            return Transform.scale(
                scale: (1.5 - _animationController.value), child: child);
          }),
    );
  }
}
