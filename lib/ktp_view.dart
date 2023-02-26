import 'dart:math';

import 'package:flutter/material.dart';

class KTPView extends StatefulWidget {
  const KTPView({Key? key}) : super(key: key);

  @override
  State<KTPView> createState() => _KTPViewState();
}

class _KTPViewState extends State<KTPView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late TweenSequence tweenSequence;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));

    _animationController.forward();
    var weight = 100 / 3;
    tweenSequence = TweenSequence(
      [
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: weight),
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: weight),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: weight),
      ],
    );
    tweenSequence.animate(_animationController);

    _animationController.addListener(() {
      var value = _animationController.value;
      print("_opacityTween: $value");
    });
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.stop();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController.view,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
            opacity: tweenSequence.evaluate(_animationController),
            child: child);
      },
      child: Container(
        color: Colors.green,
        child: Image.network(
          'https://about.lovia.id/wp-content/uploads/2020/05/ktp-1024x660.jpg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
