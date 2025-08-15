import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/modules/home_module/bingo_controller.dart';
import 'package:flutter_application_1/app/modules/home_module/widget/prize_row.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class PrizesDisplay extends GetView<BingoController> {
  const PrizesDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Obx(
          () => Column(
            children: [
              PrizeRow(
                label: 'Bote Total:',
                value: '€${controller.totalPot.value.toStringAsFixed(2)}',
              ),
              const Divider(),
              PrizeRow(
                label: 'Premio Línea (30%):',
                value: '€${controller.linePrize.value.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 6),
              PrizeRow(
                label: 'Premio Bingo (70%):',
                value: '€${controller.bingoPrize.value.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
