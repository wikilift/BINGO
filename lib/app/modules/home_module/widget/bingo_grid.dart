import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/modules/home_module/bingo_controller.dart';
import 'package:flutter_application_1/app/modules/home_module/widget/number_ball_widget.dart';
import 'package:get/get.dart';

class BingoGrid extends GetView<BingoController> {
  const BingoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: AspectRatio(
            aspectRatio: 10 / 9,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1,
                ),
                itemCount: 90,
                itemBuilder: (context, index) {
                  final number = index + 1;

                  return Obx(() {
                    final isCalled = controller.calledNumbers.contains(number);
                    final isLast = controller.lastCalledNumber.value == number;

                    return NumberBall(
                      number: number,
                      isCalled: isCalled,
                      isLast: isLast,
                    );
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
