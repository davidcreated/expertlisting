import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../constants/app_strings.dart';

sealed class AppException implements Exception {
  const AppException();

  String get title;

  String get message;
}

class NoInternetException extends AppException {
  const NoInternetException();

  @override
  String get title => AppStrings.errors.noInternetTitle;

  @override
  String get message => AppStrings.errors.noInternetMessage;

  @override
  String toString() => 'NoInternetException';
}

class NetworkException extends AppException {
  const NetworkException({this.detail});

  final String? detail;

  @override
  String get title => AppStrings.errors.networkTitle;

  @override
  String get message => AppStrings.errors.networkMessage;

  @override
  String toString() => 'NetworkException${detail != null ? ': $detail' : ''}';
}

class ApiException extends AppException {
  const ApiException({this.statusCode, this.endpoint, this.serverMessage});

  final int? statusCode;
  final String? endpoint;
  final String? serverMessage;

  @override
  String get title => AppStrings.errors.serverTitle;

  @override
  String get message => serverMessage?.trim().isNotEmpty == true
      ? serverMessage!.trim()
      : AppStrings.errors.serverMessage;

  @override
  String toString() =>
      'ApiException(status: $statusCode, endpoint: $endpoint, '
      'message: $serverMessage)';
}

class ParsingException extends AppException {
  const ParsingException({
    required this.detail,
    this.endpoint,
    this.expectedType,
    this.innerError,
  });

  final String detail;
  final String? endpoint;
  final String? expectedType;
  final Object? innerError;

  @override
  String get title => AppStrings.errors.parsingTitle;

  @override
  String get message => AppStrings.errors.parsingMessage;

  @override
  String toString() =>
      'ParsingException: $detail'
      '${endpoint != null ? ' [endpoint: $endpoint]' : ''}'
      '${expectedType != null ? ' [expected: $expectedType]' : ''}'
      '${innerError != null ? ' [error: $innerError]' : ''}';
}

class UnexpectedException extends AppException {
  const UnexpectedException([this.detail]);

  final Object? detail;

  @override
  String get title => AppStrings.errors.unexpectedTitle;

  @override
  String get message => AppStrings.errors.unexpectedMessage;

  @override
  String toString() =>
      'UnexpectedException${detail != null ? ': $detail' : ''}';
}

AppException asAppException(Object error) {
  if (error is AppException) return error;
  if (error is SocketException) return const NoInternetException();
  if (error is TimeoutException) return const NetworkException(detail: 'timeout');
  if (error is DioException) return _fromDioException(error);
  return UnexpectedException(error);
}

AppException _fromDioException(DioException error) {
  if (error.error is SocketException) return const NoInternetException();

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.connectionError:
      return NetworkException(detail: error.type.name);
    case DioExceptionType.cancel:
      return NetworkException(detail: error.type.name);
    case DioExceptionType.badCertificate:
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      break;
  }

  final status = error.response?.statusCode;
  if (status == HttpStatus.badGateway ||
      status == HttpStatus.gatewayTimeout ||
      status == HttpStatus.requestTimeout) {
    return NetworkException(detail: 'status $status');
  }

  return ApiException(
    statusCode: status,
    endpoint: error.requestOptions.path,
    serverMessage: _serverMessageOf(error.response?.data),
  );
}

String? _serverMessageOf(Object? data) {
  if (data is Map<String, dynamic>) {
    final candidate = data['message'] ?? data['error'] ?? data['detail'];
    if (candidate is String) return candidate;
  }
  if (data is String && data.trim().isNotEmpty) return data;
  return null;
}
