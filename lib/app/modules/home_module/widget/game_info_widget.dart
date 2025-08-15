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
              decoration: const InputDecoration(
                labelText: 'Nº de Jugadores',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: controller.setPlayerCount,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ticketPriceController,
              decoration: const InputDecoration(
                labelText: 'Precio del Cartón (€)',
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
