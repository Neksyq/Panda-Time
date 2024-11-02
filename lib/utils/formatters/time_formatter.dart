/// Converts seconds to a formatted time string (HH:MM:SS)
String formatTime(int value) {
  int hours = value ~/ 3600;
  int minutes = ((value % 3600)) ~/ 60;
  int seconds = value % 60;

  String formattedHours = hours.toString().padLeft(2, '0');
  String formattedMinutes = minutes.toString().padLeft(2, '0');
  String formattedSeconds = seconds.toString().padLeft(2, '0');

  return "$formattedHours:$formattedMinutes:$formattedSeconds";
}
