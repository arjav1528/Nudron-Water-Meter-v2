class CustomException implements Exception {
  final dynamic message;

  CustomException([this.message]);

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return "Something went wrong";
    return "$message";
  }
}

class SilentException implements Exception {
  final dynamic message;

  SilentException([this.message]);

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return "Something went wrong";
    return "$message";
  }
}

