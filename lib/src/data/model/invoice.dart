import 'package:invoicer/src/data/model/client.dart';
import 'package:invoicer/src/data/model/currency.dart';
import 'package:invoicer/src/data/model/supplier.dart';
import 'package:meta/meta.dart';

@immutable
class Invoice {
  final String number;
  final Supplier supplier;
  final Client client;
  final List<InvoiceItem> items;
  final DateTime dueDate;
  final DateTime issueDate;
  final DateTime deliveryDate;

  const Invoice({
    required this.number,
    required this.supplier,
    required this.client,
    required this.items,
    required this.dueDate,
    required this.issueDate,
    required this.deliveryDate,
  });

  double get totalPrice =>
      items.fold<double>(0, (acc, it) => acc + it.totalPrice);

  String get formattedTotalPrice => supplier.currency.format(totalPrice);
}

@immutable
class InvoiceItem {
  final String name;
  final double amount;
  final String unit;
  final double price;

  const InvoiceItem({
    required this.name,
    required this.amount,
    required this.unit,
    required this.price,
  });

  double get totalPrice => amount * price;
}
