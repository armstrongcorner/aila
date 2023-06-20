import 'package:aila/core/db/chat_hive_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final localStorageProvider =
    Provider<WSLocalStorage>((ref) => WSLocalStorage());

class WSLocalStorage {
  // static final WSLocalStorage _instance = WSLocalStorage._internal();
  // final String HIVE_ENCRYPT_KEY = 'HIVE_ENCRYPT_KEY';

  // factory WSLocalStorage() => _instance;

  // WSLocalStorage._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    registerAdapter(ChatHiveModelAdapter());
  }

  /// Register a [TypeAdapter] to announce it to Hive.
  void registerAdapter<T>(TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  /// Open box.
  Future<Box<E>> openBox<E>(String name) async {
    try {
      if (Hive.isBoxOpen(name)) {
        return Hive.box(name);
      } else {
        return await Hive.openBox(name);
      }
    } catch (_) {
      throw HiveError('Open box fail');
    }
  }

  Future<void> closeAllBoxes() async {
    await Hive.close();
  }

  /// Deletes all currently open boxes from disk.
  ///
  /// The home directory will not be deleted.
  Future<void> deleteFromDisk() async {
    await Hive.deleteFromDisk();
  }

  /// Removes the file which contains the box and closes the box.
  ///
  /// In the browser, the IndexedDB database is being removed.
  Future<void> deleteBoxFromDisk(String name) async {
    await Hive.deleteBoxFromDisk(name);
  }
}
