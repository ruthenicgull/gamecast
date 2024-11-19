// import 'dart:math';
// import 'package:flutter/material.dart';

// class CustomCaptchaService {
//   static String _generateRandomString(int length) {
//     const chars =
//         'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Excluding similar looking characters
//     final random = Random();
//     return List.generate(length, (index) => chars[random.nextInt(chars.length)])
//         .join();
//   }

//   static Widget buildCaptchaWidget({
//     required String captchaText,
//     double fontSize = 32.0,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Stack(
//         children: [
//           CustomPaint(
//             size: const Size(120, 50),
//             painter: CaptchaPainter(),
//           ),
//           Text(
//             captchaText,
//             style: TextStyle(
//               fontSize: fontSize,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Monospace',
//               letterSpacing: 8,
//               color: Colors.blue[900],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CaptchaPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final random = Random();
//     final paint = Paint()
//       ..color = Colors.grey.withOpacity(0.3)
//       ..strokeWidth = 1.5
//       ..style = PaintingStyle.stroke;

//     for (var i = 0; i < 5; i++) {
//       final startX = random.nextDouble() * size.width;
//       final startY = random.nextDouble() * size.height;
//       final endX = random.nextDouble() * size.width;
//       final endY = random.nextDouble() * size.height;

//       canvas.drawLine(
//         Offset(startX, startY),
//         Offset(endX, endY),
//         paint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

import 'dart:math';

import 'package:flutter/material.dart';

class CustomCaptchaService {
  static final _random = Random.secure();
  static const _chars =
      'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789';

  static String generateRandomString(int length) {
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(_random.nextInt(_chars.length)),
      ),
    );
  }

  static Widget buildCaptchaWidget({
    required String captchaText,
    double fontSize = 32.0,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Add noise lines
          CustomPaint(
            size: const Size(120, 50),
            painter: CaptchaPainter(),
          ),
          // Captcha text
          Text(
            captchaText,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'Monospace',
              letterSpacing: 8,
              color: Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }
}

class CaptchaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Add random lines
    for (var i = 0; i < 5; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final endX = random.nextDouble() * size.width;
      final endY = random.nextDouble() * size.height;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
