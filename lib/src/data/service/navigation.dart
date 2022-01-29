import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

abstract class NavigationService extends Disposable {
  ValueListenable<bool> get isInitialized;

  Future<void> initializedApp();
}
