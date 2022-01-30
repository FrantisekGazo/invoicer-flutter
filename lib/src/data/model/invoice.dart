import 'dart:io';

import 'package:meta/meta.dart';

@immutable
class Invoice {
  final String number;
  final File signature;

  const Invoice({
    required this.number,
    required this.signature,
  });
}
