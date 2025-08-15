import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/modules/home_module/bingo_controller.dart';
import 'package:get/get.dart';

class SpeedControl extends GetView<BingoController> {
  const SpeedControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Obx(
              () => SwitchListTile.adaptive(
                title: Text(controller.giveMeString('spanish_mode')),
                subtitle: Text(
                  controller.giveMeString('spanish_bingo_explanation'),
                ),
                value: controller.spanishMode.value,
                onChanged: controller.setSpanishMode,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final voices = controller.voices;
                    final selected = controller.selectedVoice.value;
                    return DropdownButtonFormField<Map<String, dynamic>>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: controller.giveMeString('tts_voice'),
                        border: OutlineInputBorder(),
                      ),
                      value:
                          selected != null && voices.contains(selected)
                              ? selected
                              : null,
                      items:
                          voices.map((v) {
                            final name = (v['name'] ?? 'voice').toString();
                            final locale = (v['locale'] ?? '').toString();
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: v,
                              child: Text(
                                '$name  ${locale.isNotEmpty ? "($locale)" : ""}',
                              ),
                            );
                          }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          controller.setVoice(v);
                        }
                      },
                    );
                  }),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: controller.previewVoice,
                  icon: const Icon(Icons.volume_up),
                  label: Text(controller.giveMeString('test')),
                ),
              ],
            ),

            const Divider(height: 24),

            Text(controller.giveMeString('speed_priority')),
            Obx(
              () => Text(
                '${controller.giveMeString('one_by')} ${controller.speed.value.toStringAsFixed(1)} s',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Obx(
              () => Slider(
                value: controller.speed.value,
                min: 1.0,
                max: 10.0,
                divisions: 18,
                label: controller.speed.value.toStringAsFixed(1),
                onChanged: controller.setSpeed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
