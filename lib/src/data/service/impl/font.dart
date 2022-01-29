import 'dart:async';

import 'package:flutter/services.dart';
import 'package:invoicer/src/data/service/font.dart';

class FontServiceImpl implements FontService {
  @override
  Future<ByteData> getBold() async {
    return await rootBundle.load("fonts/OpenSans-Bold.ttf");
  }

  @override
  Future<ByteData> getRegular() async {
    return await rootBundle.load("fonts/OpenSans-Regular.ttf");
  }

  @override
  FutureOr onDispose() async {}
}
