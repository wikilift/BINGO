import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/modules/home_module/bingo_controller.dart';
import 'package:flutter_application_1/app/modules/home_module/widget/bingo_grid.dart';
import 'package:flutter_application_1/app/modules/home_module/widget/control_panel.dart';
import 'package:get/get.dart';

class BingoView extends GetView<BingoController> {
  BingoView({super.key});

  final playerCountController = TextEditingController();
  final ticketPriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    playerCountController.text = controller.playerCount.value.toString();
    ticketPriceController.text = controller.ticketPrice.value.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bingo Wikilift'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;

          if (isWide) {
            return Row(
              children: [
                Expanded(flex: 3, child: const BingoGrid()),
                const VerticalDivider(width: 1),

                Expanded(
                  flex: 2,
                  child: ControlPanel(
                    playerCountController: playerCountController,
                    ticketPriceController: ticketPriceController,
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Expanded(flex: 3, child: const BingoGrid()),
                const Divider(height: 1),
                Expanded(
                  flex: 2,
                  child: ControlPanel(
                    playerCountController: playerCountController,
                    ticketPriceController: ticketPriceController,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
