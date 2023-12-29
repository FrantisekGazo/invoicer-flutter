import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class InvoiceItemModel implements Disposable {
  final TextEditingController name;
  final TextEditingController quantity;
  final TextEditingController unit;
  final TextEditingController unitPrice;

  InvoiceItemModel({
    String? name,
    double? quantity,
    String? unit,
    double? unitPrice,
  })  : this.name = TextEditingController(text: name),
        this.quantity = TextEditingController(text: (quantity ?? 1).toString()),
        this.unit = TextEditingController(text: unit ?? 'MD'),
        this.unitPrice = TextEditingController(text: unitPrice?.toString() ?? '');

  @override
  Future<void> onDispose() async {
    name.dispose();
    quantity.dispose();
    unit.dispose();
    unitPrice.dispose();
  }
}

class InvoiceItemView extends StatelessWidget {
  final InvoiceItemModel model;
  final ValueSetter<InvoiceItemModel> onDeleted;

  const InvoiceItemView({
    super.key,
    required this.model,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(controller: model.name),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: TextField(
            controller: model.quantity,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: TextField(
            controller: model.unit,
            keyboardType: TextInputType.text,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: TextField(
            controller: model.unitPrice,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        SizedBox(
          width: 48,
          child: Center(
            child: IconButton(
              onPressed: () => onDeleted.call(model),
              icon: const Icon(Icons.delete),
            ),
          ),
        ),
      ],
    );
  }
}

class InvoiceItemHeaderView extends StatelessWidget {
  const InvoiceItemHeaderView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: Theme.of(context).textTheme.labelSmall,
      child: const Row(
        children: <Widget>[
          Expanded(
            child: Text('Name'),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text('Quantity'),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text('Unit'),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text('Unit Price'),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }
}
