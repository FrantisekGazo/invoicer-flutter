import 'dart:io';

import 'package:flutter/material.dart';
import 'package:invoicer/src/data/di.dart';
import 'package:invoicer/src/data/model/supplier.dart';
import 'package:invoicer/src/ui/page/home/form/client.dart';
import 'package:invoicer/src/ui/page/home/form/date_picker.dart';
import 'package:invoicer/src/ui/page/home/form/item_row.dart';
import 'package:invoicer/src/ui/page/home/form/supplier.dart';
import 'package:invoicer/src/ui/page/home/model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomePageModel _model;

  @override
  void initState() {
    _model = HomePageModelImpl(
      inject(),
      inject(),
      inject(),
    );
    _model.reload();
    super.initState();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<InvoiceDataState>(
      valueListenable: _model.state,
      builder: (context, state, _) => Scaffold(
        appBar: AppBar(
          title: InkWell(
            onTap: _model.resetMainDir,
            child: Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<Directory?>(
                    valueListenable: _model.outputDir,
                    builder: (context, dir, _) => Text(
                      dir?.path ?? '',
                      style: theme.textTheme.titleSmall,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.edit),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: _model.reload,
              icon: const Icon(Icons.sync),
            ),
            IconButton(
              onPressed: _model.openInvoicesDir,
              icon: const Icon(Icons.folder_copy_outlined),
            ),
          ],
        ),
        body: switch (state) {
          InvoiceDataState.none => Container(),
          InvoiceDataState.initializing => const Column(
              children: [
                LinearProgressIndicator(),
                Spacer(),
              ],
            ),
          InvoiceDataState.initFailed => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Initialization failed!'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _model.reload,
                  child: const Text('Try again'),
                ),
              ],
            ),
          InvoiceDataState.ready || InvoiceDataState.creating => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _model.invoiceNumber,
                      decoration: const InputDecoration(
                        label: Text('Number'),
                      ),
                    ),
                  ),
                  const Divider(height: 16),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      ValueListenableBuilder<Supplier?>(
                        valueListenable: _model.supplier,
                        builder: (context, supplier, _) =>
                            (supplier != null) ? SupplierInfoItem(supplier: supplier) : const SizedBox.shrink(),
                      ),
                      ClientPickerItem(
                        clients: _model.clients,
                        selected: _model.client,
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      DatePickerItem(
                        label: 'Issued',
                        date: _model.dateIssued,
                      ),
                      DatePickerItem(
                        label: 'Due',
                        date: _model.dateDue,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    'Items:',
                    style: theme.textTheme.titleMedium,
                  ),
                  const InvoiceItemHeaderView(),
                  Expanded(
                    child: ListView(
                      children: [
                        ValueListenableBuilder<List<InvoiceItemModel>>(
                          valueListenable: _model.items,
                          builder: (context, items, _) => Column(
                            children: items
                                .map(
                                  (it) => InvoiceItemView(
                                    model: it,
                                    onDeleted: _model.removeItem,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          onPressed: _model.addItem,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        },
        floatingActionButton: switch (state) {
          InvoiceDataState.ready => FloatingActionButton(
              onPressed: () async {
                final success = await _model.submit();
                if (mounted) {
                  final snackBar = SnackBar(
                    content: Text(
                      success ? 'Invoice ${_model.invoiceNumber.text} successfully created' : 'Invoice creation failed',
                    ),
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              child: const Icon(Icons.arrow_circle_down),
            ),
          InvoiceDataState.creating => FloatingActionButton(
              onPressed: null,
              child: SizedBox.fromSize(
                size: const Size.square(24),
                child: const CircularProgressIndicator(),
              ),
            ),
          _ => null,
        },
      ),
    );
  }
}
