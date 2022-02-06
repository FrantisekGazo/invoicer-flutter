import 'package:invoicer/src/data/model/supplier.dart';

///
/// Handles supplier data storage.
///
abstract class SupplierDao {
  Future<Supplier> get();

  Future<void> set(Supplier supplier);
}
