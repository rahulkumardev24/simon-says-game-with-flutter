import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class AppUtils {
  /// load max score
  static Future<int> loadMaxScore({required String key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;

    /// maxScore
  }

  /// Save max score
  static Future<void> saveMaxScore(
      {required int score, required String key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, score);
  }

  /// Mute status
  static Future<void> saveMute(bool value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("checkMute", value);
  }

  static Future<bool> loadMute() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool("checkMute") ?? true;
  }

  /// Vibration
  static Future<void> saveVibration(bool value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("checkVibration", value);
  }

  static Future<bool> loadVibration() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool("checkVibration") ?? true;
  }

  static Future<void> playVibration({
    int durationMs = 100,
    required bool isVibrate,
  }) async {
    if (!isVibrate) return;

    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: durationMs);
    }
  }

  /// Sound
  static Future<void> playSound(
      {required String fileName, required bool isMute}) async {
    if (!isMute) return;

    final player = AudioPlayer();
    await player.play(AssetSource(fileName));
  }
}
