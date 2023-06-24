import 'dart:io';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:invoicer/src/data/dao/supplier.dart';
import 'package:invoicer/src/data/model/client.dart';
import 'package:invoicer/src/data/model/invoice.dart';
import 'package:invoicer/src/data/model/supplier.dart';
import 'package:invoicer/src/data/service/file.dart';
import 'package:invoicer/src/data/service/pdf.dart';
import 'package:invoicer/src/ui/page/home/page.dart';
import 'package:invoicer/src/util/notifier.dart';
import 'package:mutex/mutex.dart';

enum InvoiceDataState {
  none,
  initializing,
  initFailed,
  ready,
  creating,
}

abstract class HomePageModel {
  ValueNotifier<InvoiceDataState> get state;

  ValueListenable<Directory?> get outputDir;

  TextEditingController get invoiceNumber;

  ValueNotifier<DateTime> get dateDue;

  ValueNotifier<DateTime> get dateIssued;

  ValueNotifier<Client?> get client;

  ValueListenable<List<Client>> get availableClients;

  ValueNotifier<List<InvoiceItemModel>> get items;

  Future<bool> submit();

  void dispose();

  void resetMainDir();

  void reload();

  void openInvoicesDir();
}

class HomePageModelImpl implements HomePageModel {
  final SupplierDao _supplierDao;
  final FileService _fileService;
  final PdfBuilderService _pdfBuilderService;

  final _state = ValueNotifier(InvoiceDataState.none);
  final _stateMutex = Mutex();
  final _supplier = ValueNotifier<Supplier?>(null);
  final _availableClients = MappedValueNotifier<Supplier?, List<Client>>(
    initialValue: const [],
    map: (supplier) => supplier?.clients ?? const [],
  );
  final _client = ValueNotifier<Client?>(null);
  final _invoiceNumber = TextEditingController();
  final _dateIssued = ValueNotifier(DateTime.now());
  final _dateDue = ValueNotifier(DateTime.now());
  final _items = ValueNotifier<List<InvoiceItemModel>>(const []);

  HomePageModelImpl(
    this._supplierDao,
    this._fileService,
    this._pdfBuilderService,
  ) {
    _availableClients.setNotifier(_supplier);
  }

  @override
  ValueNotifier<InvoiceDataState> get state => _state;

  @override
  ValueListenable<Directory?> get outputDir => _fileService.mainDirectory;

  @override
  ValueListenable<List<Client>> get availableClients => _availableClients;

  @override
  ValueNotifier<Client?> get client => _client;

  @override
  TextEditingController get invoiceNumber => _invoiceNumber;

  @override
  ValueNotifier<DateTime> get dateIssued => _dateIssued;

  @override
  ValueNotifier<DateTime> get dateDue => _dateDue;

  @override
  ValueNotifier<List<InvoiceItemModel>> get items => _items;

  @override
  void reload() {
    _stateMutex.protect(() async {
      _state.value = InvoiceDataState.initializing;

      final outDir = outputDir.value;
      if (outDir == null) {
        _state.value = InvoiceDataState.initFailed;
        return false;
      }

      final supplier = await _supplierDao.get();
      _supplier.value = supplier;

      if (supplier.clients.isEmpty) {
        _state.value = InvoiceDataState.initFailed;
        return false;
      }

      _client.value = supplier.clients
          .lastWhere((it) => it.name.toLowerCase().contains('ventrata'));
      _resetInvoiceNumber();
      final now = DateTime.now();
      _dateIssued.value = now;
      _dateDue.value = DateTime(now.year, now.month + 1, 0);
      _items.value = [
        InvoiceItemModel(name: 'Application development'),
      ];

      await Future.delayed(const Duration(milliseconds: 500));

      _state.value = InvoiceDataState.ready;
      return true;
    });
  }

  @override
  Future<bool> submit() {
    return _stateMutex.protect(() async {
      if (_state.value != InvoiceDataState.ready) {
        return false;
      }
      _state.value = InvoiceDataState.creating;

      final supplier = _supplier.value;
      final client = _client.value;
      final number = _invoiceNumber.text;
      final issueDate = _dateIssued.value;
      final dueDate = _dateDue.value;
      final items = _items.value;

      if (supplier == null || client == null) {
        _state.value = InvoiceDataState.ready;
        return false;
      }

      final invoice = Invoice(
        number: number,
        supplier: supplier,
        client: client,
        items: items
            .map(
              (it) => InvoiceItem(
                name: it.name.text,
                amount: it.quantity.value,
                unit: 'pc',
                price: double.tryParse(it.price.text) ?? 0,
              ),
            )
            .toList(),
        issueDate: issueDate,
        deliveryDate: dueDate,
        dueDate: dueDate,
      );
      final pdf = await _pdfBuilderService.build(invoice);

      final file = _fileService.createInvoiceFiles(number);
      await file.writeAsBytes(await pdf.save());

      _resetInvoiceNumber();
      await Future.delayed(const Duration(milliseconds: 500));

      _state.value = InvoiceDataState.ready;
      return true;
    });
  }

  @override
  void resetMainDir() {
    _fileService.resetMainDirectory();
  }

  @override
  void openInvoicesDir() {
    _fileService.openInvoicesDir();
  }

  @override
  void dispose() {
    _state.dispose();
    _supplier.dispose();
    _invoiceNumber.dispose();
    _dateIssued.dispose();
    _dateDue.dispose();
    for (final item in _items.value) {
      item.onDispose();
    }
    _items.dispose();
  }

  void _resetInvoiceNumber() {
    final invoices = _fileService.getInvoiceFiles();
    final lastNumber = invoices
        .map((it) {
          final id = it.path.split('/').last.replaceFirst('.pdf', '');
          return int.tryParse(id);
        })
        .whereNotNull()
        .sorted((a, b) => a - b)
        .lastOrNull;
    final minNumber = DateTime.now().year * 1000;
    final newNumber = math.max(lastNumber ?? 0, minNumber) + 1;
    _invoiceNumber.value = TextEditingValue(text: newNumber.toString());
  }
}
