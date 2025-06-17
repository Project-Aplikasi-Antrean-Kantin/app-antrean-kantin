class ApiException implements Exception {
  final status;
  final message;

  const ApiException({required this.status, required this.message});
}
