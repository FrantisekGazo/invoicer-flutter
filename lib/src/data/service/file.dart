import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

///
/// Provides directories and files allowed for this app.
///
abstract class FileService extends Disposable {
  /// Main directory where app stores document data.
  ValueListenable<Directory?> get mainDirectory;

  /// Set main directory (Use previously selected if any).
  /// Returns true on success
  Future<bool> setupMainDirectory();

  /// Reset main directory.
  /// Returns true on success
  Future<bool> resetMainDirectory();

  /// Get a file from the main directory.
  File getFile(String relativePath);
}
