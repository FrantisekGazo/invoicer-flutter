import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:invoicer/src/data/service/file.dart';
import 'package:invoicer/src/data/service/navigation.dart';
import 'package:invoicer/src/util/notifier.dart';

class NavigationServiceImpl implements NavigationService {
  final FileService _fileService;

  final _initialized = MappedValueNotifier<Directory?, bool>(
    initialValue: false,
    map: (dir) {
      return dir != null;
    },
  );

  NavigationServiceImpl(
    this._fileService,
  ) {
    _initialized.setNotifier(_fileService.mainDirectory);
  }

  @override
  ValueListenable<bool> get isInitialized => _initialized;

  @override
  Future<void> initializedApp() async {
    var selected = false;
    do {
      selected = await _fileService.selectMainDirectory();
    } while (!selected);
  }

  @override
  Future<void> onDispose() async {
    _initialized.dispose();
  }
}
