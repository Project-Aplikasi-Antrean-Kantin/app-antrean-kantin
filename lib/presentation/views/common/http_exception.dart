// Custom exception classes for handling HTTP errors in a reusable way.

class CustomHttpException implements Exception {
  final String message;
  final int statusCode;

  CustomHttpException(this.message, this.statusCode);

  @override
  String toString() => 'HttpException: $message (Status Code: $statusCode)';
}

class BadRequestException extends CustomHttpException {
  BadRequestException(String message) : super(message, 400);
}

class UnauthorizedException extends CustomHttpException {
  UnauthorizedException(String message) : super(message, 401);
}

class ForbiddenException extends CustomHttpException {
  ForbiddenException(String message) : super(message, 403);
}

class NotFoundException extends CustomHttpException {
  NotFoundException(String message) : super(message, 404);
}

class ServerException extends CustomHttpException {
  ServerException(String message) : super(message, 500);
}
