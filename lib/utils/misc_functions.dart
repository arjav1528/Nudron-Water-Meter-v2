import 'package:vibration/vibration.dart';

class MiscellaneousFunctions {
  static bool isEmailValid(String email) {
    String pattern = r"^[a-zA-Z0-9+_.-]{1,64}@[a-zA-Z0-9.-]{3,191}";
// r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }

  static vibratePhone() async {
    bool? can = await Vibration.hasVibrator();
    if (can != null && can) {
      bool? hasAmpcontrol = await Vibration.hasAmplitudeControl();
      if (hasAmpcontrol != null && hasAmpcontrol) {
        Vibration.vibrate(duration: 400, amplitude: 64);
      } else {
        Vibration.vibrate(duration: 400);
      }
    }
  }
}
