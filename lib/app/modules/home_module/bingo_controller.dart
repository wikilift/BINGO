

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart' as p;

enum GamePhase { idle, running, paused, ended }

class BingoController extends GetxController {
  final FlutterTts flutterTts = FlutterTts();

  final GetStorage _box = GetStorage('bingo');
  static const _kCustomConfigKey = 'custom_config_json';
  static const _kUseCustomConfigKey = 'use_custom_config';

  final RxList<int> availableNumbers = <int>[].obs;
  final RxList<int> calledNumbers = <int>[].obs;
  final RxInt lastCalledNumber = 0.obs;
  final RxBool isGameRunning = false.obs;
  final RxDouble speed = 3.0.obs;
  final RxBool spanishMode = false.obs;
  final RxDouble lastLinePaid = 0.0.obs;
  final RxDouble lastBingoPaid = 0.0.obs;

  final Rx<GamePhase> phase = GamePhase.idle.obs;
  bool get isRunning => phase.value == GamePhase.running;
  bool get isPaused => phase.value == GamePhase.paused;
  bool get isIdle => phase.value == GamePhase.idle;

  final List<String> bingoPhrases = [];
  final List<String> deniedLinePhrases = [];
  final List<String> deniedBingoPhrases = [];
  final List<String> plusPhrases = [];
  final List<String> pausePhrases = [];
  final List<String> resumePhrases = [];

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

  final RxInt playerCount = 3.obs;
  final RxDouble ticketPrice = 1.0.obs;
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
    resetGame(silent: true);
    everAll([playerCount, ticketPrice], (_) => _calculatePrizes());
    _calculatePrizes();
    await _loadConfigFromStorageOrAssets();
    await Get.forceAppUpdate();
  }

  void _syncIsGameRunningFlag() {
    isGameRunning.value = isRunning;
  }

  Future<void> startGame() async {
    if (!isIdle) return; 
    phase.value = GamePhase.running;
    _syncIsGameRunningFlag();

    if (startPhrases.isNotEmpty) {
      await _speak(startPhrases[Random().nextInt(startPhrases.length)]);
    }

    _runAutoLoop();
  }

  Future<void> pauseGame({bool mustSpeak = true}) async {
    if (!isRunning) return;
    phase.value = GamePhase.paused;
    _syncIsGameRunningFlag();

    if (pausePhrases.isNotEmpty && mustSpeak) {
      await _speak(pausePhrases[Random().nextInt(pausePhrases.length)]);
    }
  }

  Future<void> resumeGame() async {
    if (!isPaused) return;
    phase.value = GamePhase.running;
    _syncIsGameRunningFlag();

    if (resumePhrases.isNotEmpty) {
      await _speak(resumePhrases[Random().nextInt(resumePhrases.length)]);
    }

    _runAutoLoop();
  }

  
  Future<void> endGame({bool speak = true}) async {
    phase.value = GamePhase.ended;
    _autoLoopRunning = false;
    _syncIsGameRunningFlag();

    if (speak && endPhrases.isNotEmpty) {
      await _speak(endPhrases[Random().nextInt(endPhrases.length)]);
    }
  }

  
  Future<void> resetGame({bool silent = false}) async {
    if (!silent) {
      await endGame(speak: true);
    } else {
      phase.value = GamePhase.idle;
      _autoLoopRunning = false;
      _syncIsGameRunningFlag();
    }

    lastCalledNumber.value = 0;
    calledNumbers.clear();
    availableNumbers.value = List.generate(90, (i) => i + 1);
    lineClaimed.value = false;
    bingoClaimed.value = false;
    lastLinePaid.value = 0.0;
    lastBingoPaid.value = 0.0;

    phase.value = GamePhase.idle;
    _syncIsGameRunningFlag();
  }

  
  void toggleGame() {
    if (isRunning) {
      pauseGame();
    } else if (isPaused) {
      resumeGame();
    } else if (isIdle) {
      startGame();
    }
  }

  String? _validateConfig(Map<String, dynamic> map) {
    if (map.containsKey('chance_phrases')) {
      final v = map['chance_phrases'];
      if (v is! num || v < 0 || v > 1) {
        return 'chance_phrases debe ser número entre 0 y 1';
      }
    }

    if (!map.containsKey('phrases') || map['phrases'] is! Map) {
      return 'Falta "phrases" o no es un objeto';
    }
    final ph = map['phrases'] as Map;
    for (final k in ['start', 'end', 'line']) {
      if (ph[k] != null && ph[k] is! List) {
        return '"phrases.$k" debe ser una lista de strings';
      }
    }

    if (!map.containsKey('nicknames') || map['nicknames'] is! Map) {
      return 'Falta "nicknames" o no es un objeto';
    }

    final nicks = map['nicknames'] as Map;
    for (final entry in nicks.entries) {
      final key = int.tryParse(entry.key.toString());
      if (key == null || key < 1 || key > 90) {
        return 'nicknames: clave inválida ${entry.key} (use 1..90)';
      }
      if (entry.value is! String) {
        return 'nicknames[$key] debe ser string';
      }
    }

    if (map['strings'] != null && map['strings'] is! Map) {
      return '"strings" debe ser un objeto si se incluye';
    }
    return null;
  }

  Future<void> _loadConfigFromStorageOrAssets() async {
    try {
      final stored = _box.read(_kCustomConfigKey);
      final useCustom = _box.read(_kUseCustomConfigKey) == true;
      if (useCustom && stored is String && stored.isNotEmpty) {
        final map = json.decode(stored) as Map<String, dynamic>;
        final err = _validateConfig(map);
        if (err == null) {
          _applyConfig(map);
          return;
        } else {
          Get.snackbar('Config', 'JSON guardado no válido: $err');
        }
      }

      await _loadPhrasesFromAssets();
    } catch (e) {
      await _loadPhrasesFromAssets();
    }
  }

  Future<void> _loadPhrasesFromAssets() async {
    try {
      final raw = await rootBundle.loadString('assets/raw/data.json');
      final map = json.decode(raw) as Map<String, dynamic>;
      _applyConfig(map);
    } catch (e) {
      print("Exception loading json from assets: $e");
    }
  }

  void _applyConfig(Map<String, dynamic> map) {
    mapStrings
      ..clear()
      ..addAll((map['strings'] ?? {}) as Map<String, dynamic>);

    final phrases = (map['phrases'] ?? {}) as Map<String, dynamic>;
    _nicknameChance =
        (map['chance_phrases'] is num)
            ? (map['chance_phrases'] as num).toDouble().clamp(0.0, 1.0)
            : _nicknameChance;

    startPhrases
      ..clear()
      ..addAll(List<String>.from(phrases['start'] ?? const []));
    endPhrases
      ..clear()
      ..addAll(List<String>.from(phrases['end'] ?? const []));
    linePhrases
      ..clear()
      ..addAll(List<String>.from(phrases['line'] ?? const []));

    bingoPhrases
      ..clear()
      ..addAll(List<String>.from(phrases['bingo'] ?? const []));
    deniedLinePhrases
      ..clear()
      ..addAll(List<String>.from(phrases['denied_line'] ?? const []));
    deniedBingoPhrases
      ..clear()
      ..addAll(List<String>.from(phrases['denied_bingo'] ?? const []));
    plusPhrases
      ..clear()
      ..addAll(List<String>.from(phrases['plus'] ?? const []));

    nicknames
      ..clear()
      ..addAll(
        ((map['nicknames'] ?? {}) as Map<String, dynamic>).map(
          (k, v) => MapEntry(int.tryParse(k) ?? -1, v.toString()),
        )..removeWhere((k, _) => k < 1 || k > 90),
      );
    pausePhrases
      ..clear()
      ..addAll(List<String>.from(phrases['pause'] ?? const []));
    resumePhrases
      ..clear()
      ..addAll(List<String>.from(phrases['resume'] ?? const []));
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

    final wasRunning = isRunning;
    if (wasRunning) {
      await pauseGame(mustSpeak: false);
    }

    final phrase =
        linePhrases.isNotEmpty
            ? linePhrases[Random().nextInt(linePhrases.length)]
            : giveMeString('line_fallback');
    await _speak(phrase);

    lastLinePaid.value = linePrize.value;
    lineClaimed.value = true;

    final player = AudioPlayer();
    try {
      await player.play(AssetSource('sound/line.mp3'));
    } catch (_) {}

    
    return lastLinePaid.value;
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

    phase.value = GamePhase.running; 
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

    
    final player = AudioPlayer();
    try {
      await player.play(AssetSource('sound/bingo.mp3'));
    } catch (_) {}

    
    await endGame(speak: true);
    return lastBingoPaid.value;
  }

  Future<void> stopGame() async {
    isGameRunning.value = false;
    _autoLoopRunning = false;

    if (endPhrases.isNotEmpty) {
      await _speak(endPhrases[Random().nextInt(endPhrases.length)]);
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

  Future<void> drawNumber({bool forced = false}) async {
    if (!forced) {
      if (_isSpeaking || phase.value != GamePhase.running) return;
      if (availableNumbers.isEmpty) {
        await endGame(speak: true);
        return;
      }
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
      await endGame(speak: true);
    }
  }

  Future<void> _runAutoLoop() async {
    if (_autoLoopRunning) return;
    _autoLoopRunning = true;

    while (_autoLoopRunning &&
        phase.value == GamePhase.running &&
        availableNumbers.isNotEmpty) {
      final cycleStart = DateTime.now();

      await drawNumber();

      final elapsedMs = DateTime.now().difference(cycleStart).inMilliseconds;
      final targetMs = (speed.value * 1000).toInt();
      final remaining = targetMs - elapsedMs;

      if (remaining > 0 &&
          _autoLoopRunning &&
          phase.value == GamePhase.running) {
        await Future.delayed(Duration(milliseconds: remaining));
      }
    }

    _autoLoopRunning = false;
    if (availableNumbers.isEmpty) {
      await endGame(speak: true);
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
    final val = mapStrings[s];
    if (val is String && val.isNotEmpty) return val;
    return s;
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

  Future<void> exportTemplateJson() async {
    try {
      final raw = await rootBundle.loadString('assets/raw/data.json');
      final suggestedName = 'bingo_template.json';

      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: giveMeString('save_lang'),
        fileName: suggestedName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (savePath == null) return;

      final f = File(savePath.endsWith('.json') ? savePath : '$savePath.json');
      await f.writeAsString(raw);

      Get.snackbar(
        giveMeString('config'),
        '${giveMeString('saved_path')}\n${p.basename(f.path)}',
      );
    } catch (e) {
      Get.snackbar(
        giveMeString('config'),
        '${giveMeString('error_saving_json')} $e',
      );
    }
  }

  Future<void> importCustomJson() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final bytes = file.bytes ?? await File(file.path!).readAsBytes();
      final content = utf8.decode(bytes);
      final map = json.decode(content) as Map<String, dynamic>;

      final err = _validateConfig(map);
      if (err != null) {
        Get.snackbar('Config', 'JSON inválido: $err');
        return;
      }

      _applyConfig(map);
      await _box.write(_kCustomConfigKey, content);
      await _box.write(_kUseCustomConfigKey, true);

      Get.snackbar(giveMeString('config'), giveMeString('error_apply_json'));
    } catch (e) {
      Get.snackbar(
        giveMeString('config'),
        '${giveMeString('error_import_json')} $e',
      );
    }
  }
}
