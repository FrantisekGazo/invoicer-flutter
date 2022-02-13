import 'package:get_it/get_it.dart';
import 'package:invoicer/src/data/model/invoice.dart';
import 'package:pdf/widgets.dart' as pw;

///
/// Handles PDF document creation.
///
abstract class PdfBuilderService extends Disposable {
  /// Build a PDF invoice.
  Future<pw.Document> build(Invoice invoice);
}
