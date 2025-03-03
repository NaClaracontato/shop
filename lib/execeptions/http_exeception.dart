class HttpExeception implements Exception {
  final String message;
  final int statusCode;

  HttpExeception({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() {
    return message;
  }
}
