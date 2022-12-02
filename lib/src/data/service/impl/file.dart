import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:invoicer/src/data/service/file.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileServiceImpl implements FileService {
  static const _spKeyMainPath = 'main-path';

  final _mainDir = ValueNotifier<Directory?>(null);

  @override
  ValueListenable<Directory?> get mainDirectory => _mainDir;

  @override
  Future<bool> selectMainDirectory() async {
    final previous = await _getInitialDir();
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Invoicer directory',
      initialDirectory: previous?.path,
    );
    if (path != null) {
      await _setInitialDir(path);
      _mainDir.value = Directory(path);
      return true;
    }
    return false;
  }

  Future<Directory?> _getInitialDir() async {
    final sp = await SharedPreferences.getInstance();
    final path = sp.getString(_spKeyMainPath);
    return (path != null)? Directory(path):null;
  }

  Future<void> _setInitialDir(String path) async {
    final sp = await SharedPreferences.getInstance();
    sp.setString(_spKeyMainPath, path);
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
