import 'package:flutter/material.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[400]!,
            Colors.grey[300]!,
          ],
          stops: const [
            0.1,
            0.3,
            0.4,
          ],
          begin: const Alignment(-1.0, -0.3),
          end: const Alignment(1.0, 0.3),
          tileMode: TileMode.clamp,
        ).createShader(bounds);
      },
      child: SizedBox(
        width: width,
        height: height,
      ),
    );
  }
}
