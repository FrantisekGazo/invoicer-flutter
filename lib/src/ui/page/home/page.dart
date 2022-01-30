import 'dart:io';

import 'package:flutter/material.dart';
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
        signature: File('${dir.path}/assets/signature.png'),
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
