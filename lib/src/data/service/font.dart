import 'dart:typed_data';

import 'package:get_it/get_it.dart';

///
/// Provides font data.
///
abstract class FontService extends Disposable {
  Future<ByteData> getBold();

  Future<ByteData> getRegular();
}
