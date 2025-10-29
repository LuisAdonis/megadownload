import 'package:app/core/services/key_value_storage_service_impl.dart';
import 'package:app/features/widgets/riverpod/notifier_general.dart';
import 'package:app/features/widgets/riverpod/state_general.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final generalProvider = StateNotifierProvider<GeneralNotifier, GeneralState>((ref) {
  final keyValue = KeyValueStorageServiceImpl();
  return GeneralNotifier(keyValue: keyValue);
});
