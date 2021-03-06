import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:invoicer/src/data/service/file.dart';

class FileServiceImpl implements FileService {
  final _mainDir = ValueNotifier<Directory?>(null);

  @override
  ValueListenable<Directory?> get mainDirectory => _mainDir;

  @override
  Future<bool> selectMainDirectory() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      _mainDir.value = Directory(path);
      return true;
    }
    return false;
  }

  @override
  File getFile(String relativePath) {
    final mainDirPath = _mainDir.value?.path;
    if (mainDirPath == null) {
      throw StateError('Main directory not setup');
    }
    return File('$mainDirPath/$relativePath');
  }

  @override
  FutureOr onDispose() async {
    _mainDir.dispose();
  }
}
