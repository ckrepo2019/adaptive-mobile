// lib/utils/retry.dart
import 'dart:async';

/// Generic retry utility for async operations.
///
/// Usage:
/// final data = await retry(() => api.fetch(), retries: 3,
///   shouldRetry: (res) => res is ApiResponse && !res.success);
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
