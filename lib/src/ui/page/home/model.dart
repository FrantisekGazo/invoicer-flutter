import 'dart:io';

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

  Future<bool> init();

  Future<bool> createInvoice();

  void dispose();
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
  Future<bool> init() {
    return _stateMutex.protect(() async {
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

      _client.value = supplier.clients.first;
      _invoiceNumber.value = const TextEditingValue(text: '2022004-TEST');
      _dateIssued.value = DateTime.now();
      _dateDue.value =
          DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
      _items.value = [
        InvoiceItemModel(name: 'Application development'),
      ];

      await Future.delayed(const Duration(milliseconds: 500));

      _state.value = InvoiceDataState.ready;
      return true;
    });
  }

  @override
  Future<bool> createInvoice() {
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

      final dir = _fileService.mainDirectory.value!;
      final file = File('${dir.path}/invoices/$number.pdf');
      await file.writeAsBytes(await pdf.save());

      await Future.delayed(const Duration(milliseconds: 500));

      _state.value = InvoiceDataState.ready;
      return true;
    });
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
}