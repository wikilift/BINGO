import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/modules/home_module/bingo_controller.dart';
import 'package:flutter_application_1/app/modules/home_module/widget/prize_row.dart';
import 'package:get/get.dart';

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
                label: controller.giveMeString('total_cash'),
                value: '€${controller.totalPot.value.toStringAsFixed(2)}',
              ),
              const Divider(),
              PrizeRow(
                label: controller.giveMeString('win_line'),
                value: '€${controller.linePrize.value.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 6),
              PrizeRow(
                label: controller.giveMeString('win_bingo'),
                value: '€${controller.bingoPrize.value.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
