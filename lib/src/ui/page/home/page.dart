import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:invoicer/src/data/dao/supplier.dart';
import 'package:invoicer/src/data/di.dart';
import 'package:invoicer/src/data/model/invoice.dart';
import 'package:invoicer/src/data/service/file.dart';
import 'package:invoicer/src/data/service/pdf.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _loading = ValueNotifier(false);
  final _number = TextEditingController(text: '2022002');
  final _dateIssue = ValueNotifier(DateTime.now());
  final _dateDue = ValueNotifier(
    DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
  );
  final _items = ValueNotifier(const <InvoiceItemModel>[]);
  late final SupplierDao _supplierDao;
  late final FileService _fileService;
  late final PdfBuilderService _pdfBuilderService;

  @override
  void initState() {
    _supplierDao = inject();
    _fileService = inject();
    _pdfBuilderService = inject();
    _items.value = [
      InvoiceItemModel(name: 'Application development'),
    ];
    super.initState();
  }

  @override
  void dispose() {
    _loading.dispose();
    _number.dispose();
    _dateIssue.dispose();
    _dateDue.dispose();
    for (final item in _items.value) {
      item.onDispose();
    }
    _items.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<Directory?>(
          valueListenable: _fileService.mainDirectory,
          builder: (context, dir, _) => Text(
            dir?.path ?? '',
            style: theme.textTheme.subtitle1,
            overflow: TextOverflow.fade,
          ),
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _loading,
        builder: (context, loading, _) => Column(
          children: [
            SizedBox(
              height: 4,
              child: loading ? const LinearProgressIndicator() : null,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 16,
                      children: [
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: _number,
                            decoration: const InputDecoration(
                              label: Text('Number'),
                            ),
                          ),
                        ),
                        DatePickerItem(label: 'Issued', date: _dateIssue),
                        DatePickerItem(label: 'Due', date: _dateDue),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Items:',
                      style: theme.textTheme.subtitle1,
                    ),
                    ValueListenableBuilder<List<InvoiceItemModel>>(
                      valueListenable: _items,
                      builder: (context, items, _) => Column(
                        children: items
                            .map((it) => InvoiceItemView(model: it))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _loading,
        builder: (context, loading, _) => loading
            ? const SizedBox.shrink()
            : FloatingActionButton(
                child: const Icon(Icons.arrow_circle_down),
                onPressed: _run,
              ),
      ),
    );
  }

  Future<void> _run() async {
    _loading.value = true;

    final supplier = await _supplierDao.get();
    final invoice = Invoice(
      number: _number.text,
      supplier: supplier,
      client: supplier.clients.last,
      items: _items.value
          .map(
            (it) => InvoiceItem(
              name: it.name.text,
              amount: it.quantity.value,
              unit: 'pc',
              price: double.tryParse(it.price.text) ?? 0,
            ),
          )
          .toList(),
      issueDate: _dateIssue.value,
      deliveryDate: _dateDue.value,
      dueDate: _dateDue.value,
    );
    final pdf = await _pdfBuilderService.build(invoice);

    final dir = _fileService.mainDirectory.value!;
    final file = File('${dir.path}/invoices/example.pdf');
    await file.writeAsBytes(await pdf.save());

    _loading.value = false;
  }
}

class InvoiceItemModel implements Disposable {
  final TextEditingController name;
  final ValueNotifier<double> quantity;
  final TextEditingController price;

  InvoiceItemModel({
    String? name,
    double? quantity,
    double? price,
  })  : this.name = TextEditingController(text: name),
        this.quantity = ValueNotifier(quantity ?? 1.0),
        this.price = TextEditingController(text: price?.toString());

  @override
  FutureOr onDispose() async {
    name.dispose();
    quantity.dispose();
    price.dispose();
  }
}

class InvoiceItemView extends StatelessWidget {
  final InvoiceItemModel model;

  const InvoiceItemView({
    Key? key,
    required this.model,
  }) : super(key: key);

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
            controller: model.price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
      ],
    );
  }
}

class DatePickerItem extends StatelessWidget {
  static final _dateFormatter = DateFormat('dd/MM/yyyy');

  final String label;
  final ValueNotifier<DateTime> date;

  const DatePickerItem({
    Key? key,
    required this.label,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 4),
            const Icon(Icons.today),
            const SizedBox(width: 4),
            ValueListenableBuilder<DateTime>(
              valueListenable: date,
              builder: (context, dateValue, _) => Text(
                _dateFormatter.format(dateValue),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        final value = date.value;
        final selected = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: value.add(const Duration(days: -30)),
          lastDate: value.add(const Duration(days: 30)),
        );
        if (selected != null) {
          date.value = selected;
        }
      },
    );
  }
}
