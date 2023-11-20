import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:invoicer/src/data/di.dart';
import 'package:invoicer/src/data/model/client.dart';
import 'package:invoicer/src/data/model/supplier.dart';
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
        body: Builder(
          builder: (context) {
            switch (state) {
              case InvoiceDataState.initializing:
                return const Column(
                  children: [
                    LinearProgressIndicator(),
                    Spacer(),
                  ],
                );
              case InvoiceDataState.initFailed:
                return Column(
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
                );
              case InvoiceDataState.ready:
              case InvoiceDataState.creating:
                return Padding(
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
                      ValueListenableBuilder<List<InvoiceItemModel>>(
                        valueListenable: _model.items,
                        builder: (context, items, _) => Column(
                          children: items.map((it) => InvoiceItemView(model: it)).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              case InvoiceDataState.none:
                // nothing to show
                return Container();
            }
          },
        ),
        floatingActionButton: (state == InvoiceDataState.ready)
            ? FloatingActionButton(
                onPressed: () async {
                  final success = await _model.submit();
                  if (mounted) {
                    final snackBar = SnackBar(
                      content: Text(
                        success
                            ? 'Invoice ${_model.invoiceNumber.text} successfully created'
                            : 'Invoice creation failed',
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: const Icon(Icons.arrow_circle_down),
              )
            : (state == InvoiceDataState.creating)
                ? FloatingActionButton(
                    onPressed: null,
                    child: SizedBox.fromSize(
                      size: const Size.square(24),
                      child: const CircularProgressIndicator(),
                    ),
                  )
                : null,
      ),
    );
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
        this.price = TextEditingController(text: price?.toString() ?? '100');

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
    super.key,
    required this.model,
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
    super.key,
    required this.label,
    required this.date,
  });

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
          firstDate: value.add(const Duration(days: -365)),
          lastDate: value.add(const Duration(days: 365)),
        );
        if (selected != null) {
          date.value = selected;
        }
      },
    );
  }
}

class ClientPickerItem extends StatelessWidget {
  final ValueNotifier<Client?> selected;
  final ValueListenable<List<Client>> clients;

  const ClientPickerItem({
    super.key,
    required this.selected,
    required this.clients,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Client>>(
      valueListenable: clients,
      builder: (context, all, _) => ValueListenableBuilder<Client?>(
        valueListenable: selected,
        builder: (context, selectedClient, _) {
          final theme = Theme.of(context);
          final address = selectedClient?.address;
          final dic = selectedClient?.dic;
          final icdph = selectedClient?.icdph;
          final ico = selectedClient?.ico;

          return DefaultTextStyle.merge(
            style: theme.textTheme.bodySmall,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Client:'),
                DropdownButton<Client>(
                  items: all
                      .map(
                        (it) => DropdownMenuItem<Client>(
                          value: it,
                          child: Text(it.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    selected.value = value;
                  },
                  value: selectedClient,
                ),
                if (address != null) Text(address.join('\n')),
                const SizedBox(height: 8),
                if (ico != null) Text('IČO: $ico'),
                if (dic != null) Text('DIČ: $dic'),
                if (icdph != null) Text('IČ DPH: $icdph'),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SupplierInfoItem extends StatelessWidget {
  final Supplier supplier;

  const SupplierInfoItem({
    super.key,
    required this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final email = supplier.email;
    final phone = supplier.phone;
    final dic = supplier.dic;
    final icdph = supplier.icdph;
    final ico = supplier.ico;
    final bankAccount = supplier.bankAccount;

    return DefaultTextStyle.merge(
      style: theme.textTheme.bodySmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Supplier:'),
          const SizedBox(height: 16),
          Text(
            supplier.name,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text(supplier.address.join('\n')),
          const SizedBox(height: 8),
          Text('IČO: $ico', style: theme.textTheme.bodyMedium),
          if (dic != null) Text('DIČ: $dic'),
          if (icdph != null) Text('IČ DPH: $icdph'),
          const SizedBox(height: 8),
          if (email != null) Text('E-mail: $email'),
          if (phone != null) Text('Phone: $phone'),
          const SizedBox(height: 8),
          const Text('Bank account:'),
          Text(bankAccount.iban, style: theme.textTheme.bodyMedium),
          Text('SWIFT: ${bankAccount.swift}'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
