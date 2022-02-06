import 'dart:io';

import 'package:flutter/material.dart';
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
  final _logs = ValueNotifier('');
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
        builder: (context, loading, _) => Stack(
          children: [
            if (loading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<String>(
                valueListenable: _logs,
                builder: (context, logs, _) => Text(logs),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: ElevatedButton(
                  onPressed: loading ? null : _run,
                  child: const Text('Run'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _run() async {
    _loading.value = true;

    final supplier = await _supplierDao.get();
    final invoice = Invoice(
      number: '20XX00Y',
      supplier: supplier,
      client: supplier.clients.last,
      items: const [
        InvoiceItem(
          name: 'Application development',
          amount: 1,
          unit: 'pc',
          price: 1000,
        ),
      ],
      issueDate: DateTime(2020, 8, 15),
      deliveryDate: DateTime(2020, 8, 15),
      dueDate: DateTime(2020, 8, 30),
    );
    final pdf = await _pdfBuilderService.build(invoice);

    final dir = _fileService.mainDirectory.value!;
    final file = File('${dir.path}/invoices/example.pdf');
    await file.writeAsBytes(await pdf.save());
    _logs.value = 'file: ${file.path}';

    _loading.value = false;
  }

  @override
  void dispose() {
    _loading.dispose();
    super.dispose();
  }
}
