import 'package:flutter/material.dart';

/// Modal animado que aparece desde abajo con transiciones suaves
class AnimatedBottomSheet extends StatefulWidget {
  final Widget child;
  final bool isVisible;
  final VoidCallback onDismiss;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final Duration animationDuration;

  const AnimatedBottomSheet({
    Key? key,
    required this.child,
    required this.isVisible,
    required this.onDismiss,
    this.initialChildSize = 0.75,
    this.minChildSize = 0.5,
    this.maxChildSize = 0.9,
    this.animationDuration = const Duration(milliseconds: 400),
  }) : super(key: key);

  @override
  State<AnimatedBottomSheet> createState() => _AnimatedBottomSheetState();
}

class _AnimatedBottomSheetState extends State<AnimatedBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late AnimationController _sheetController;
  late Animation<double> _overlayAnimation;
  late Animation<Offset> _sheetAnimation;

  @override
  void initState() {
    super.initState();

    _overlayController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _sheetController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _overlayAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    ));

    _sheetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _sheetController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.isVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSheet();
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _showSheet();
      } else {
        _hideSheet();
      }
    }
  }

  void _showSheet() {
    _overlayController.forward();
    _sheetController.forward();
  }

  void _hideSheet() async {
    await Future.wait([
      _sheetController.reverse(),
      _overlayController.reverse(),
    ]);
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_overlayController, _sheetController]),
      builder: (context, child) {
        // Si no está visible y las animaciones están en 0, no mostrar nada
        if (!widget.isVisible &&
            _overlayController.value == 0 &&
            _sheetController.value == 0) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: [
            // Overlay SIN gesture detector - solo visual
            Container(
              color: Colors.black54.withOpacity(_overlayAnimation.value * 0.5),
            ),

            // Sheet deslizable desde abajo
            SlideTransition(
              position: _sheetAnimation,
              child: NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  // Detectar cuando se desliza hacia abajo para cerrar
                  if (notification.extent < widget.minChildSize * 0.7) {
                    widget.onDismiss();
                  }
                  return true;
                },
                child: DraggableScrollableSheet(
                  initialChildSize: widget.initialChildSize,
                  minChildSize: widget.minChildSize,
                  maxChildSize: widget.maxChildSize,
                  snap: true,
                  snapSizes: [widget.minChildSize, widget.initialChildSize],
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Indicador de arrastre mejorado
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Container(
                                width: 50,
                                height: 5,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),

                          // Contenido del sheet
                          Expanded(child: widget.child),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
