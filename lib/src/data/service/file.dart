import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

abstract class FileService extends Disposable {
  ValueListenable<Directory?> get mainDirectory;

  /// Returns true on success
  Future<bool> selectMainDirectory();

  File getFile(String relativePath);
}
