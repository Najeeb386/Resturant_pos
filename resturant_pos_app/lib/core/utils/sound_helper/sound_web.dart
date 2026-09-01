import 'dart:js' as js;

void playNotificationSound() {
  try {
    js.context.callMethod('eval', [
      '''
      (function() {
        try {
          var ctx = new (window.AudioContext || window.webkitAudioContext)();
          
          function playTone(freq, delay, duration) {
            var osc = ctx.createOscillator();
            var gain = ctx.createGain();
            osc.connect(gain);
            gain.connect(ctx.destination);
            
            osc.type = "sine";
            osc.frequency.value = freq;
            
            var startTime = ctx.currentTime + delay;
            var endTime = startTime + duration;
            
            gain.gain.setValueAtTime(0, ctx.currentTime);
            gain.gain.linearRampToValueAtTime(0.3, startTime);
            gain.gain.exponentialRampToValueAtTime(0.01, endTime);
            
            osc.start(startTime);
            osc.stop(endTime);
          }
          
          playTone(880.0, 0.0, 0.15);
          playTone(1109.73, 0.1, 0.25);
        } catch(e) {
          console.error("JS audio playback error:", e);
        }
      })()
      '''
    ]);
  } catch (e) {
    print('Web sound play error: $e');
  }
}
