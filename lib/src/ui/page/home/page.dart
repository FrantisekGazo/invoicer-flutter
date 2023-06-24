import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:invoicer/src/data/di.dart';
import 'package:invoicer/src/ui/page/home/model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
    _model.init();
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
                const Icon(Icons.folder_copy_outlined),
                const SizedBox(width: 8),
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
              ],
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 4,
              child: (state == InvoiceDataState.initializing)
                  ? const LinearProgressIndicator()
                  : null,
            ),
            if (state == InvoiceDataState.initFailed)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Initialization failed!'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _model.init,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            if (state == InvoiceDataState.ready ||
                state == InvoiceDataState.creating)
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
                              controller: _model.invoiceNumber,
                              decoration: const InputDecoration(
                                label: Text('Number'),
                              ),
                            ),
                          ),
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
                      const SizedBox(height: 24),
                      Text(
                        'Items:',
                        style: theme.textTheme.titleMedium,
                      ),
                      ValueListenableBuilder<List<InvoiceItemModel>>(
                        valueListenable: _model.items,
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
