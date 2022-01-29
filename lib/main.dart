import 'package:flutter/material.dart';
import 'package:invoicer/src/data/di.dart';
import 'package:invoicer/src/ui/app.dart';

Future<void> main() async {
  await initDI();
  runApp(const InvoicerApp());
}
