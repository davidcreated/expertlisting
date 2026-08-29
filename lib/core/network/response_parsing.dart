import 'package:dio/dio.dart';

import '../error/app_exception.dart';

Future<T> guardApiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on AppException {
    rethrow;
  } catch (error) {
    throw asAppException(error);
  }
}

extension ResponseParsingX<T> on Response<T> {
  E parseObject<Dto, E>({
    required Dto Function(Map<String, dynamic> json) fromJson,
    required E Function(Dto dto) toEntity,
    required String endpoint,
  }) {
    final json = data;
    if (json is! Map<String, dynamic>) {
      throw ParsingException(
        detail: json == null
            ? 'Response body is null'
            : 'Expected a JSON object, got ${json.runtimeType}',
        endpoint: endpoint,
        expectedType: '$Dto',
      );
    }

    try {
      return toEntity(fromJson(json));
    } catch (error) {
      throw ParsingException(
        detail: 'Failed to parse response',
        endpoint: endpoint,
        expectedType: '$Dto',
        innerError: error,
      );
    }
  }
}

List<E> parseItems<Dto, E>({
  required List<dynamic> raw,
  required Dto Function(Map<String, dynamic> json) fromJson,
  required E Function(Dto dto) toEntity,
  required String endpoint,
  void Function(ParsingException error)? onItemError,
}) {
  final results = <E>[];
  for (final item in raw) {
    try {
      results.add(toEntity(fromJson(item as Map<String, dynamic>)));
    } catch (error) {
      onItemError?.call(
        ParsingException(
          detail: 'Failed to parse list item',
          endpoint: endpoint,
          expectedType: '$Dto',
          innerError: error,
        ),
      );
    }
  }
  return results;
}
