import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_client.dart';
import 'network/dio_client.dart';
import 'storage/local_storage.dart';
import 'storage/secure_storage.dart';

/// Provides the app-wide [SharedPreferences] instance.
///
/// Must be overridden in [ProviderScope] during bootstrap (see
/// lib/app/bootstrap) before this is read, since obtaining the instance is
/// asynchronous. Left unimplemented here on purpose: reading it without the
/// override is a bootstrap bug and should fail loudly.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in bootstrap',
  ),
);

final localStorageProvider = Provider<LocalStorage>(
  (ref) => LocalStorage(ref.watch(sharedPreferencesProvider)),
);

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

final dioProvider = Provider<Dio>((ref) => createDioClient());

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(dioProvider)),
);
