import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/app/modules/home_module/bingo_controller.dart';
import 'package:get/get.dart';

class GameInfo extends GetView<BingoController> {
  final TextEditingController playerCountController;
  final TextEditingController ticketPriceController;

  const GameInfo({
    super.key,
    required this.playerCountController,
    required this.ticketPriceController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: playerCountController,
              decoration: InputDecoration(
                labelText: controller.giveMeString('player_number'),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: controller.setPlayerCount,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ticketPriceController,
              decoration: InputDecoration(
                labelText: controller.giveMeString('price_to_play'),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: controller.setTicketPrice,
            ),
          ],
        ),
      ),
    );
  }
}
