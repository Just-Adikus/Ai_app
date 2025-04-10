import 'package:flutter/material.dart';

class VoiceWaveAnimation extends StatefulWidget {
  @override
  _VoiceWaveAnimationState createState() => _VoiceWaveAnimationState();
}

class _VoiceWaveAnimationState extends State<VoiceWaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Icon(
            Icons.wifi_tethering,
            size: 50 + _controller.value * 10,
            color: Colors.blue.withOpacity(1 - _controller.value),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
