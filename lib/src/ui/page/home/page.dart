import 'dart:io';

import 'package:flutter/material.dart';
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
  late final SupplierDao _supplierDao;
  late final FileService _fileService;
  late final PdfBuilderService _pdfBuilderService;

  @override
  void initState() {
    _supplierDao = inject();
    _fileService = inject();
    _pdfBuilderService = inject();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoicer'),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
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
                        const SizedBox(width: 16),
                        DatePickerItem(label: 'Issued', date: _dateIssue),
                        const SizedBox(width: 16),
                        DatePickerItem(label: 'Due', date: _dateDue),
                      ],
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
      items: const [
        InvoiceItem(
          name: 'Application development',
          amount: 1,
          unit: 'pc',
          price: 4620,
        ),
      ],
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

  @override
  void dispose() {
    _loading.dispose();
    _number.dispose();
    _dateIssue.dispose();
    _dateDue.dispose();
    super.dispose();
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
