import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/modules/home_module/bingo_controller.dart';
import 'package:get/get.dart';

class GameControls extends GetView<BingoController> {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        
        Obx(() {
          final phase = controller.phase.value;
          final isRunning = phase == GamePhase.running;
          final isPaused = phase == GamePhase.paused;

          final label =
              isRunning
                  ? controller.giveMeString('pause')
                  : (isPaused
                      ? controller.giveMeString('resume')
                      : controller.giveMeString('start'));

          final icon =
              isRunning ? Icons.pause_circle_filled : Icons.play_circle_filled;

          final bg =
              isRunning
                  ? Colors.orange.shade700
                  : (isPaused
                      ? Colors.blueGrey.shade600
                      : Colors.green.shade600);

          return ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: bg,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: controller.toggleGame,
            icon: Icon(icon),
            label: Text(label),
          );
        }),
        const SizedBox(height: 10),

        
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: () async => controller.drawNumber(forced: true),
                icon: const Icon(Icons.casino),
                label: Text(controller.giveMeString('give_one')),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  foregroundColor: Colors.red.shade400,
                ),
                onPressed: () => controller.resetGame(),
                icon: const Icon(Icons.refresh),
                label: Text(controller.giveMeString('restart')),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        
        Obx(
          () => Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    backgroundColor:
                        controller.lineClaimed.value
                            ? Colors.teal.shade200
                            : Colors.teal.shade600,
                  ),
                  onPressed:
                      controller.lineClaimed.value
                          ? null
                          : () => controller.claimLine(),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    controller.lineClaimed.value
                        ? controller.giveMeString('paied_line')
                        : controller.giveMeString('pay_line'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    backgroundColor:
                        controller.bingoClaimed.value
                            ? Colors.purple.shade200
                            : Colors.purple.shade600,
                  ),
                  onPressed:
                      controller.bingoClaimed.value
                          ? null
                          : () => controller.claimBingo(),
                  icon: const Icon(Icons.emoji_events_outlined),
                  label: Text(
                    controller.bingoClaimed.value
                        ? controller.giveMeString('paied_bingo')
                        : controller.giveMeString('pay_bingo'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
