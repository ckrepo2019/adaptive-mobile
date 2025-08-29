// lib/utils/retry.dart
import 'dart:async';

Future<T> retry<T>(
  Future<T> Function() fn, {
  int retries = 3,
  Duration delay = const Duration(seconds: 1),
  bool Function(T result)? shouldRetry,
}) async {
  T result = await fn();
  int attempt = 0;
  while (attempt < retries && (shouldRetry?.call(result) ?? false)) {
    await Future.delayed(delay);
    result = await fn();
    attempt++;
  }
  return result;
}
