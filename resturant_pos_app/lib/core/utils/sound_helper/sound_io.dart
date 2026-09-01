import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

void playNotificationSound() {
  try {
    FlutterRingtonePlayer().playNotification();
  } catch (e) {
    print('IO notification sound play error: $e');
  }
}
