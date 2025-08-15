import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class BingoController extends GetxController {
  final FlutterTts flutterTts = FlutterTts();

  final RxList<int> availableNumbers = <int>[].obs;
  final RxList<int> calledNumbers = <int>[].obs;
  final RxInt lastCalledNumber = 0.obs;
  final RxBool isGameRunning = false.obs;
  final RxDouble speed = 3.0.obs;
  final RxBool spanishMode = false.obs;
  final RxDouble lastLinePaid = 0.0.obs;
  final RxDouble lastBingoPaid = 0.0.obs;

  final List<String> bingoPhrases = [];
  final List<String> deniedLinePhrases = [];
  final List<String> deniedBingoPhrases = [];
  final List<String> plusPhrases = [];

  final Random _rng = Random();
  final mapStrings = <String, dynamic>{};

  static const Set<int> _alwaysNickname = {90, 15, 22};
  double _nicknameChance = 0.20;

  static const Map<int, String> _fallbackNicknames = {
    90: 'el abuelo',
    15: 'la niña bonita',
    22: 'los dos patitos',
  };

  final RxList<Map<String, dynamic>> voices = <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>?> selectedVoice = Rx<Map<String, dynamic>?>(
    null,
  );

  final RxBool lineClaimed = false.obs;
  final RxBool bingoClaimed = false.obs;

  final RxInt playerCount = 10.obs;
  final RxDouble ticketPrice = 5.0.obs;
  final RxDouble totalPot = 0.0.obs;
  final RxDouble linePrize = 0.0.obs;
  final RxDouble bingoPrize = 0.0.obs;

  final List<String> startPhrases = [];
  final List<String> endPhrases = [];
  final List<String> linePhrases = [];
  final Map<int, String> nicknames = {};

  bool _autoLoopRunning = false;
  bool _isSpeaking = false;

  @override
  void onInit() async {
    super.onInit();
    _initializeTTS();
    resetGame();
    everAll([playerCount, ticketPrice], (_) => _calculatePrizes());
    _calculatePrizes();
    await _loadPhrases().then((_) async => await Get.forceAppUpdate());
  }

  void resetGame() {
    stopGame();
    lastCalledNumber.value = 0;
    calledNumbers.clear();
    availableNumbers.value = List.generate(90, (i) => i + 1);
    lineClaimed.value = false;
    bingoClaimed.value = false;
    lastLinePaid.value = 0.0;
    lastBingoPaid.value = 0.0;
  }

  Future<double> claimLine() async {
    if (lineClaimed.value) return 0.0;

    if (calledNumbers.length < 5) {
      final deny =
          deniedLinePhrases.isNotEmpty
              ? deniedLinePhrases[Random().nextInt(deniedLinePhrases.length)]
              : giveMeString('not_line_allowed');
      await _speak(deny);
      return 0.0;
    }

    final wasRunning = isGameRunning.value;
    isGameRunning.value = false;

    try {
      final phrase =
          linePhrases.isNotEmpty
              ? linePhrases[Random().nextInt(linePhrases.length)]
              : giveMeString('line_fallback');
      await _speak(phrase);

      lastLinePaid.value = linePrize.value;
      lineClaimed.value = true;
      return lastLinePaid.value;
    } finally {
      if (wasRunning && availableNumbers.isNotEmpty && !bingoClaimed.value) {
        isGameRunning.value = true;
        _runAutoLoop();
      }
    }
  }

  Future<double> claimBingo() async {
    if (bingoClaimed.value) return 0.0;

    if (calledNumbers.length < 15) {
      final deny =
          deniedBingoPhrases.isNotEmpty
              ? deniedBingoPhrases[Random().nextInt(deniedBingoPhrases.length)]
              : giveMeString('not_bingo_allowed');
      await _speak(deny);
      return 0.0;
    }

    isGameRunning.value = false;
    _autoLoopRunning = false;

    final multiplier = (calledNumbers.length == 15) ? 10 : 1;
    lastBingoPaid.value = bingoPrize.value * multiplier;

    if (bingoPhrases.isNotEmpty) {
      await _speak(bingoPhrases[Random().nextInt(bingoPhrases.length)]);
    } else {
      await _speak(giveMeString('bingo_fallback'));
    }

    if (multiplier > 1) {
      await _speak('${giveMeString('plus_ball')} $multiplier.');
    }

    bingoClaimed.value = true;

    if (endPhrases.isNotEmpty) {
      await _speak(endPhrases[Random().nextInt(endPhrases.length)]);
    }

    return lastBingoPaid.value;
  }

  void startGame() async {
    if (isGameRunning.value) return;
    isGameRunning.value = true;

    if (startPhrases.isNotEmpty) {
      await _speak(startPhrases[Random().nextInt(startPhrases.length)]);
    }

    _runAutoLoop();
  }

  Future<void> stopGame() async {
    isGameRunning.value = false;
    _autoLoopRunning = false;

    if (endPhrases.isNotEmpty) {
      await _speak(endPhrases[Random().nextInt(endPhrases.length)]);
    }
  }

  void toggleGame() {
    if (isGameRunning.value) {
      stopGame();
    } else {
      if (availableNumbers.isNotEmpty) startGame();
    }
  }

  Map<String, dynamic>? _pickDefaultSpanishVoice(
    List<Map<String, dynamic>> list,
  ) {
    String norm(String s) => s
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');

    final monica = list.firstWhereOrNull((v) {
      final name = norm((v['name'] ?? '').toString());
      final loc = (v['locale'] ?? '').toString().toLowerCase();
      return name.contains('monica') && loc.startsWith('es');
    });
    if (monica != null) return monica;

    final anyEs = list.firstWhereOrNull((v) {
      final loc = (v['locale'] ?? '').toString().toLowerCase();
      return loc.startsWith('es');
    });
    if (anyEs != null) return anyEs;

    return list.isNotEmpty ? list.first : null;
  }

  Future<void> drawNumber() async {
    if (_isSpeaking) return;
    if (availableNumbers.isEmpty) {
      stopGame();
      return;
    }

    final randomIndex = Random().nextInt(availableNumbers.length);
    final number = availableNumbers.removeAt(randomIndex);

    lastCalledNumber.value = number;
    calledNumbers.add(number);

    await _speakNumber(number);

    if (calledNumbers.length == 15) {
      final plus =
          plusPhrases.isNotEmpty
              ? plusPhrases[Random().nextInt(plusPhrases.length)]
              : '¡BOLA PLUS!';
      await _speak(plus);
    }

    if (availableNumbers.isEmpty) {
      await stopGame();
    }
  }

  Future<void> _runAutoLoop() async {
    if (_autoLoopRunning) return;
    _autoLoopRunning = true;

    while (_autoLoopRunning &&
        isGameRunning.value &&
        availableNumbers.isNotEmpty) {
      final cycleStart = DateTime.now();

      await drawNumber();

      final elapsedMs = DateTime.now().difference(cycleStart).inMilliseconds;
      final targetMs = (speed.value * 1000).toInt();
      final remaining = targetMs - elapsedMs;

      if (remaining > 0 && _autoLoopRunning && isGameRunning.value) {
        await Future.delayed(Duration(milliseconds: remaining));
      }
    }

    _autoLoopRunning = false;
    if (availableNumbers.isEmpty) {
      await stopGame();
    }
  }

  void _calculatePrizes() {
    totalPot.value = playerCount.value * ticketPrice.value;
    linePrize.value = totalPot.value * 0.30;
    bingoPrize.value = totalPot.value * 0.70;
  }

  Future<void> _initializeTTS() async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.awaitSpeakCompletion(true);

    await _loadVoices();
  }

  Future<void> _loadVoices() async {
    final v = await flutterTts.getVoices;
    final list =
        (v as List)
            .whereType<Map>()
            .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
            .toList();

    list.sort((a, b) {
      final la = (a['locale'] ?? '').toString().toLowerCase();
      final lb = (b['locale'] ?? '').toString().toLowerCase();
      final pa = la.startsWith('es') ? 0 : 1;
      final pb = lb.startsWith('es') ? 0 : 1;
      if (pa != pb) return pa - pb;
      return (a['name'] ?? '').toString().compareTo(
        (b['name'] ?? '').toString(),
      );
    });

    voices.assignAll(list);

    final def = _pickDefaultSpanishVoice(list);
    if (def != null) {
      await setVoice(def);
    } else if (list.isNotEmpty) {
      await setVoice(list.first);
    }
  }

  Future<void> setVoice(Map<String, dynamic> voice) async {
    selectedVoice.value = voice;
    try {
      await flutterTts.setVoice({
        'name': (voice['name'] ?? '').toString(),
        'locale': (voice['locale'] ?? '').toString(),
      });

      final loc = (voice['locale'] ?? '').toString();
      if (loc.isNotEmpty) {
        await flutterTts.setLanguage(loc);
      }
    } catch (_) {
      if ((voice['name'] ?? '').toString().isNotEmpty) {
        await flutterTts.setVoice({'name': voice['name']});
      }
      final loc = (voice['locale'] ?? '').toString();
      if (loc.isNotEmpty) {
        await flutterTts.setLanguage(loc);
      }
    }
  }

  Future<void> previewVoice() async {
    final sample = giveMeString("voice_test");
    await _speak(sample);
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;

    if (_isSpeaking) {
      while (_isSpeaking) {
        await Future.delayed(const Duration(milliseconds: 20));
      }
    }

    _isSpeaking = true;
    try {
      await flutterTts.speak(text);
    } finally {
      _isSpeaking = false;
    }
  }

  Future<void> _speakNumber(int number) async {
    String utterance = number.toString();

    if (spanishMode.value) {
      final forceNickname = _alwaysNickname.contains(number);
      final useNickname =
          forceNickname || (_rng.nextDouble() < _nicknameChance);

      if (useNickname) {
        final nickFromAssets = nicknames[number];
        final nick =
            (nickFromAssets != null && nickFromAssets.trim().isNotEmpty)
                ? nickFromAssets
                : _fallbackNicknames[number];

        if (nick != null && nick.trim().isNotEmpty) {
          utterance = "$number, $nick";
        }
      }
    }

    await _speak(utterance);
  }

  void setNicknameChance(double value) {
    _nicknameChance = value.clamp(0.0, 1.0);
  }

  String giveMeString(String s) {
    if (mapStrings.containsKey(s)) {
      return mapStrings[s];
    }
    return "no error on json db";
  }

  Future<void> _loadPhrases() async {
    try {
      final raw = await rootBundle.loadString('assets/raw/data.json');
      final map = json.decode(raw) as Map<String, dynamic>;
      mapStrings.addAll((map['strings'] ?? {}) as Map<String, dynamic>);
      final phrases = (map['phrases'] ?? {}) as Map<String, dynamic>;
      _nicknameChance = map['chance_phrases'] ?? _nicknameChance;
      startPhrases
        ..clear()
        ..addAll(List<String>.from(phrases['start'] ?? const []));
      endPhrases
        ..clear()
        ..addAll(List<String>.from(phrases['end'] ?? const []));
      linePhrases
        ..clear()
        ..addAll(List<String>.from(phrases['line'] ?? const []));

      nicknames
        ..clear()
        ..addAll(
          ((map['nicknames'] ?? {}) as Map<String, dynamic>).map(
            (k, v) => MapEntry(int.tryParse(k) ?? -1, v.toString()),
          )..removeWhere((k, _) => k < 1 || k > 90),
        );
    } catch (e) {
      print("Exception loading json :$e");
    }
  }

  void setSpeed(double newSpeed) {
    speed.value = newSpeed;
  }

  void setPlayerCount(String value) {
    playerCount.value = int.tryParse(value) ?? 0;
  }

  void setTicketPrice(String value) {
    ticketPrice.value = double.tryParse(value) ?? 0.0;
  }

  void setSpanishMode(bool enabled) {
    spanishMode.value = enabled;
  }

  Future<void> speakLineAward() async {
    if (linePhrases.isNotEmpty) {
      await _speak(linePhrases[Random().nextInt(linePhrases.length)]);
    }
  }
}
