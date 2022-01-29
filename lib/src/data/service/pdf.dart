import 'package:get_it/get_it.dart';
import 'package:pdf/widgets.dart' as pw;

abstract class PdfBuilderService extends Disposable {
  Future<pw.Document> build();
}
