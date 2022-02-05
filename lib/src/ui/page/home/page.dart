import 'dart:io';

import 'package:flutter/material.dart';
import 'package:invoicer/src/data/di.dart';
import 'package:invoicer/src/data/model/bank_account.dart';
import 'package:invoicer/src/data/model/client.dart';
import 'package:invoicer/src/data/model/currency.dart';
import 'package:invoicer/src/data/model/invoice.dart';
import 'package:invoicer/src/data/model/language.dart';
import 'package:invoicer/src/data/model/project.dart';
import 'package:invoicer/src/data/model/project_type.dart';
import 'package:invoicer/src/data/model/supplier.dart';
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
  late final FileService _fileService;
  late final PdfBuilderService _pdfBuilderService;

  @override
  void initState() {
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

    final dir = _fileService.mainDirectory.value;
    if (dir != null) {
      final invoice = Invoice(
        number: '20XX00Y',
        supplier: const Supplier(
          name: 'Adam Smith',
          address: [
            'Aaaaaa XXXX/Y',
            '01234 Aaaaaa',
            'Slovakia',
          ],
          ico: '1234567890',
          dic: '0987654321',
          icdph: 'SK0987654321',
          phone: '+421 949 111 222',
          email: 'test@gmail.com',
          numbering: 'YYYYccc',
          currency: Currency.eur,
          bankAccount: BankAccount(
            iban: 'SK12 1111 2222 3333 4444',
            swift: 'ASDFGH',
          ),
          signaturePath: 'assets/signature.png',
          clients: [],
        ),
        client: const Client(
          name: 'Company A',
          address: [
            'Zzzzzz CCCCC/O',
            '56789 Bbbbbbb',
            'Česká Republika',
          ],
          ico: '121212121212',
          dic: '45454545454',
          icdph: 'CZ45454545454',
          projects: [],
          lang: Language.en,
        ),
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

      final file = File('${dir.path}/invoices/example.pdf');
      await file.writeAsBytes(await pdf.save());
      _logs.value = 'file: ${file.path}';
    } else {
      _logs.value = 'no path';
    }

    _loading.value = false;
  }

  @override
  void dispose() {
    _loading.dispose();
    super.dispose();
  }
}
