import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:invoicer/src/data/service/file.dart';
import 'package:macos_secure_bookmarks/macos_secure_bookmarks.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileServiceImpl implements FileService {
  static const _spKeyMainDirBookmark = 'main_dir_bookmark';

  final _secureBookmarks = SecureBookmarks();
  final _mainDir = ValueNotifier<Directory?>(null);

  @override
  ValueListenable<Directory?> get mainDirectory => _mainDir;

  @override
  Future<bool> resetMainDirectory() async {
    final mainDir = await _chooseMainDir();
    if (mainDir != null) {
      _mainDir.value = mainDir;
      return true;
    }

    return false;
  }

  @override
  Future<bool> setupMainDirectory() async {
    final previousMainDir = await _getPreviouslyUsedMainDir();
    if (previousMainDir != null) {
      _mainDir.value = previousMainDir;
      return true;
    }

    return await resetMainDirectory();
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
  Future<void> onDispose() async {
    final mainDir = _mainDir.value;
    if (mainDir != null) {
      await _secureBookmarks.stopAccessingSecurityScopedResource(mainDir);
    }
    _mainDir.dispose();
  }

  Future<Directory?> _getPreviouslyUsedMainDir() async {
    final sp = await SharedPreferences.getInstance();
    final storedBookmark = sp.getString(_spKeyMainDirBookmark);
    if (storedBookmark == null) {
      return null;
    }

    final resolvedFile = await _secureBookmarks.resolveBookmark(storedBookmark);
    await _secureBookmarks.startAccessingSecurityScopedResource(resolvedFile);
    return Directory(resolvedFile.path);
  }

  Future<Directory?> _chooseMainDir() async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Invoicer directory',
    );
    if (path == null) {
      return null;
    }
    final mainDir = Directory(path);

    final bookmark = await _secureBookmarks.bookmark(mainDir);
    final sp = await SharedPreferences.getInstance();
    sp.setString(_spKeyMainDirBookmark, bookmark);

    return mainDir;
  }
}
