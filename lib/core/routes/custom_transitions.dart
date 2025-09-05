import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Transición personalizada de fade con slide
class FadeSlideTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 0.3);
    const end = Offset.zero;
    const transitionCurve = Curves.easeInOutCubic;
    
    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: transitionCurve),
    );
    var offsetAnimation = animation.drive(tween);
    
    var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
      CurveTween(curve: Curves.easeInOut),
    );
    var fadeAnimation = animation.drive(fadeTween);
    
    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
}

/// Transición personalizada de slide desde la derecha
class SlideFromRightTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const transitionCurve = Curves.easeInOutCubic;
    
    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: transitionCurve),
    );
    var offsetAnimation = animation.drive(tween);
    
    var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
      CurveTween(curve: Curves.easeInOut),
    );
    var fadeAnimation = animation.drive(fadeTween);
    
    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
}

/// Helper class para acceder a las transiciones
class CustomTransitions {
  static CustomTransition get fadeSlide => FadeSlideTransition();
  static CustomTransition get slideFromRight => SlideFromRightTransition();
}