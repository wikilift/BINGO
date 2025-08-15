import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/modules/home_module/bingo_controller.dart';
import 'package:flutter_application_1/app/modules/home_module/widget/flip_number.dart';
import 'package:get/get.dart';

class LastNumberDisplay extends GetView<BingoController> {
  const LastNumberDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: LayoutBuilder(
        builder: (context, c) {
          final h = c.maxHeight;
          final minH = (h.isFinite && h > 0) ? h : 120.0;
          return Container(
            height: minH.clamp(90.0, 160.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.teal.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Obx(() {
                final value = controller.lastCalledNumber.value;
                return LayoutBuilder(
                  builder: (context, inner) {
                    final fs = (inner.biggest.shortestSide * 0.5).clamp(
                      36.0,
                      96.0,
                    );
                    return FlipNumber(
                      value: value == 0 ? '--' : value.toString(),
                      style: TextStyle(
                        fontSize: fs,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      duration: const Duration(milliseconds: 450),
                    );
                  },
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
