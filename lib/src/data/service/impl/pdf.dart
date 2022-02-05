import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:invoicer/src/data/model/client.dart';
import 'package:invoicer/src/data/model/currency.dart';
import 'package:invoicer/src/data/model/invoice.dart';
import 'package:invoicer/src/data/model/language.dart';
import 'package:invoicer/src/data/model/supplier.dart';
import 'package:invoicer/src/data/service/file.dart';
import 'package:invoicer/src/data/service/font.dart';
import 'package:invoicer/src/data/service/localized.dart';
import 'package:invoicer/src/data/service/pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfBuilderServiceImpl implements PdfBuilderService {
  final FileService _fileService;
  final FontService _fontService;
  final LocalizedService _localizedService;

  PdfBuilderServiceImpl(
    this._fileService,
    this._fontService,
    this._localizedService,
  );

  @override
  Future<Document> build(Invoice invoice) async {
    final regularFont = Font.ttf(await _fontService.getRegular());
    final boldFont = Font.ttf(await _fontService.getBold());
    final theme = ThemeData(
      defaultTextStyle: TextStyle(font: regularFont, fontSize: 10),
      header0: TextStyle(font: regularFont, fontSize: 10),
      header5: TextStyle(font: boldFont, fontSize: 10),
      header4: TextStyle(font: boldFont, fontSize: 12),
      header3: TextStyle(font: boldFont, fontSize: 14),
      header2: TextStyle(font: boldFont, fontSize: 16),
      header1: TextStyle(font: boldFont, fontSize: 18),
    );
    final signature = _fileService.getFile(invoice.supplier.signaturePath);
    final signatureBytes = await signature.readAsBytes();
    final localized =
        _localizedService.getLocalizedDoc(invoice.client.isForeign);

    return Document(theme: theme)
      ..addPage(
        Page(
          build: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: InvoiceTitle(
                  localized: localized,
                  number: invoice.number,
                ),
              ),
              SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SupplierContainer(
                      localized: localized,
                      supplier: invoice.supplier,
                      client: invoice.client,
                    ),
                  ),
                  Expanded(
                    child: ClientContainer(
                      localized: localized,
                      client: invoice.client,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _CustomVerticalDivider(),
              ),
              InvoiceDatesContainer(
                localized: localized,
                invoice: invoice,
              ),
              PaymentInfoContainer(
                localized: localized,
                invoice: invoice,
              ),
              SizedBox(height: 24),
              InvoiceTable(
                localized: localized,
                invoice: invoice,
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: SignatureContainer(
                      localized: localized,
                      signature: signatureBytes,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  FutureOr onDispose() async {}
}

class InvoiceTitle extends StatelessWidget {
  final LocalizedDocument localized;
  final String number;

  InvoiceTitle({
    required this.localized,
    required this.number,
  });

  @override
  Widget build(Context context) {
    final theme = Theme.of(context);

    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(
        children: [
          TextSpan(
            text: '${localized.invoice}  ',
            style: theme.defaultTextStyle.copyWith(
              fontSize: theme.header4.fontSize,
            ),
          ),
          TextSpan(text: number, style: theme.header4),
        ],
      ),
    );
  }
}

class SupplierContainer extends StatelessWidget {
  final LocalizedDocument localized;
  final Supplier supplier;
  final Client client;

  SupplierContainer({
    required this.localized,
    required this.supplier,
    required this.client,
  });

  @override
  Widget build(Context context) {
    final theme = Theme.of(context);
    final stylePar7 = theme.defaultTextStyle.copyWith(fontSize: 8);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localized.supplier.toUpperCase(),
          style: theme.defaultTextStyle.copyWith(letterSpacing: 2),
        ),
        SizedBox(height: 12),
        Text(supplier.name, style: theme.header5),
        ...supplier.address.map((it) => Text(it)),
        SizedBox(height: 4),
        Text('${localized.ico}: ${supplier.ico}'),
        if (client.lang != Language.en)
          Text('${localized.dic}: ${supplier.dic}'),
        ...(client.isForeign)
            ? [
                Text('${localized.icdph}: ${supplier.icdph}'),
                SizedBox(height: 4),
                Text(localized.dphPar7Part1, style: stylePar7),
                Text(localized.dphPar7Part2, style: stylePar7),
              ]
            : [
                SizedBox(height: 4),
                Text(localized.dphNo, style: stylePar7),
              ],
        SizedBox(height: 4),
        if (supplier.phone != null)
          Text('${localized.phone}: ${supplier.phone}'),
        if (supplier.email != null)
          Text('${localized.email}: ${supplier.email}'),
      ],
    );
  }
}

class ClientContainer extends StatelessWidget {
  final LocalizedDocument localized;
  final Client client;

  ClientContainer({
    required this.localized,
    required this.client,
  });

  @override
  Widget build(Context context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 150),
      child: Stack(
        children: [
          Positioned(
            top: 7,
            left: 1,
            right: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(width: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 14,
                  bottom: 14,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(client.name, style: theme.header5),
                    ...client.address.map((it) => Text(it)),
                    SizedBox(height: 4),
                    if (client.ico != null)
                      Text('${localized.ico}: ${client.ico}'),
                    if (client.dic != null)
                      Text('${localized.dic}: ${client.dic}'),
                    if (client.icdph != null)
                      Text('${localized.icdph}: ${client.icdph}'),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 16,
            child: Container(
              color: PdfColors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  localized.client.toUpperCase(),
                  style: theme.defaultTextStyle.copyWith(letterSpacing: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InvoiceDatesContainer extends StatelessWidget {
  final LocalizedDocument localized;
  final Invoice invoice;
  static final _dateFormatter = DateFormat('dd.MM.yyyy');

  InvoiceDatesContainer({
    required this.localized,
    required this.invoice,
  });

  @override
  Widget build(Context context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoItem(
            title: localized.issueDate,
            value: _dateFormatter.format(invoice.issueDate),
          ),
          _InfoItem(
            title: localized.deliveryDate,
            value: _dateFormatter.format(invoice.deliveryDate),
          ),
          _InfoItem(
            title: localized.dueDate,
            value: _dateFormatter.format(invoice.dueDate),
          ),
        ],
      ),
    );
  }
}

class PaymentInfoContainer extends StatelessWidget {
  final LocalizedDocument localized;
  final Invoice invoice;

  PaymentInfoContainer({
    required this.localized,
    required this.invoice,
  });

  @override
  Widget build(Context context) {
    final bankAccount = invoice.supplier.bankAccount;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(width: 0.5),
        borderRadius: BorderRadius.circular(4),
        color: PdfColors.grey200,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _InfoItem(
              title: localized.iban,
              value: bankAccount.iban,
            ),
            _InfoItem(
              title: localized.swift,
              value: bankAccount.swift,
            ),
            _InfoItem(
              title: localized.variableSymbol,
              value: invoice.number,
            ),
            _InfoItem(
              title: localized.totalPrice,
              value: invoice.formattedTotalPrice,
            ),
          ],
        ),
      ),
    );
  }
}

class SignatureContainer extends StatelessWidget {
  final LocalizedDocument localized;

  /// Signature image file content.
  final Uint8List signature;

  SignatureContainer({
    required this.localized,
    required this.signature,
  });

  @override
  Widget build(Context context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 100,
      height: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image(MemoryImage(signature)),
          ),
          _CustomVerticalDivider(),
          SizedBox(height: 2),
          Align(
            alignment: Alignment.center,
            child: Text(
              localized.signature,
              style: theme.defaultTextStyle.copyWith(
                fontSize: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InvoiceTable extends StatelessWidget {
  final LocalizedDocument localized;
  final Invoice invoice;

  InvoiceTable({
    required this.localized,
    required this.invoice,
  });

  @override
  Widget build(Context context) {
    final theme = Theme.of(context);
    final styleH = theme.header5;
    final currency = invoice.supplier.currency;

    final headers = [
      Text(localized.itemNumber, style: styleH),
      Text(localized.itemName, style: styleH),
      Text(localized.itemAmount, style: styleH),
      Text(localized.itemUnit, style: styleH),
      Text('${localized.itemUnitCost} [${currency.symbol}]', style: styleH),
      Text('${localized.itemPrice} [${currency.symbol}]', style: styleH),
    ];
    final values = invoice.items
        .mapIndexed(
          (i, item) => <Widget>[
            Text('${i + 1}'),
            Text(item.name),
            Text(item.amount.toStringAsFixed(1)),
            Text(item.unit),
            Text(currency.format(item.price, noSymbol: true)),
            Text(currency.format(item.totalPrice, noSymbol: true)),
          ],
        )
        .toList();
    final footers = [
      Text(''),
      Text(localized.total, style: styleH),
      Text(''),
      Text(''),
      Text(''),
      Text(currency.format(invoice.totalPrice, noSymbol: true), style: styleH),
    ];

    return Table(
      children: [
        TableRow(
          decoration: const BoxDecoration(
            color: PdfColors.grey200,
            border: Border(bottom: BorderSide(width: 0.5)),
          ),
          children: headers.mapIndexed(InvoiceTableCell.new).toList(),
        ),
        ...values.map(
          (itemValues) => TableRow(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 0.5)),
            ),
            children: itemValues.mapIndexed(InvoiceTableCell.new).toList(),
          ),
        ),
        TableRow(
          decoration: const BoxDecoration(
            color: PdfColors.grey200,
          ),
          children: footers.mapIndexed(InvoiceTableCell.new).toList(),
        ),
      ],
    );
  }
}

class InvoiceTableCell extends StatelessWidget {
  final int index;
  final Widget child;

  InvoiceTableCell(this.index, this.child);

  @override
  Widget build(Context context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 6,
      ),
      child: Align(
        alignment: (index == 0)
            ? Alignment.center
            : (index == 1)
                ? Alignment.centerLeft
                : Alignment.centerRight,
        child: child,
      ),
    );
  }
}

///
/// Shows a title & value in a column.
///
class _InfoItem extends StatelessWidget {
  final String title;
  final String value;

  _InfoItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(Context context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.defaultTextStyle),
        Text(value, style: theme.header5),
      ],
    );
  }
}

///
/// Use this cause [Divider] from pdf package min height is 1.
///
class _CustomVerticalDivider extends StatelessWidget {
  @override
  Widget build(Context context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(width: 0.5)),
      ),
    );
  }
}
