import 'dart:typed_data';

import 'package:get_it/get_it.dart';

abstract class FontService extends Disposable {
  Future<ByteData> getBold();

  Future<ByteData> getRegular();
}
