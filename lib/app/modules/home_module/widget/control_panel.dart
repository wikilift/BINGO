import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/modules/home_module/bingo_controller.dart';
import 'package:flutter_application_1/app/modules/home_module/widget/game_controls.dart';
import 'package:flutter_application_1/app/modules/home_module/widget/game_info_widget.dart';
import 'package:flutter_application_1/app/modules/home_module/widget/last_number_display.dart';
import 'package:flutter_application_1/app/modules/home_module/widget/prize_displays.dart';
import 'package:flutter_application_1/app/modules/home_module/widget/section_title.dart';
import 'package:flutter_application_1/app/modules/home_module/widget/speed_control.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class ControlPanel extends GetView<BingoController> {
  final TextEditingController playerCountController;
  final TextEditingController ticketPriceController;

  const ControlPanel({
    super.key,
    required this.playerCountController,
    required this.ticketPriceController,
  });

  @override
  Widget build(BuildContext context) {
    const baseWidth = 480.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final pad = (constraints.biggest.shortestSide * 0.03).clamp(10.0, 24.0);

        return Padding(
          padding: EdgeInsets.all(pad),

          child: FittedBox(
            alignment: Alignment.topLeft,
            fit: BoxFit.contain,
            child: ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: baseWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionTitle(title: 'Último Número'),
                  const LastNumberDisplay(),
                  const SizedBox(height: 16),

                  const SectionTitle(title: 'Controles'),
                  const GameControls(),
                  const SizedBox(height: 16),

                  const SectionTitle(title: 'Configuración'),
                  const SpeedControl(),
                  const SizedBox(height: 16),

                  const SectionTitle(title: 'Información de Partida'),
                  GameInfo(
                    playerCountController: playerCountController,
                    ticketPriceController: ticketPriceController,
                  ),
                  const SizedBox(height: 16),

                  const SectionTitle(title: 'Premios'),
                  const PrizesDisplay(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
