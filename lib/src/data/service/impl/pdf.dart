import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:invoicer/src/data/model/client.dart';
import 'package:invoicer/src/data/model/currency.dart';
import 'package:invoicer/src/data/model/invoice.dart';
import 'package:invoicer/src/data/model/supplier.dart';
import 'package:invoicer/src/data/service/file.dart';
import 'package:invoicer/src/data/service/font.dart';
import 'package:invoicer/src/data/service/pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfBuilderServiceImpl implements PdfBuilderService {
  final FileService _fileService;
  final FontService _fontService;

  PdfBuilderServiceImpl(
    this._fileService,
    this._fontService,
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

    return Document(theme: theme)
      ..addPage(
        Page(
          build: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: InvoiceTitle(
                  number: invoice.number,
                ),
              ),
              SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SupplierContainer(supplier: invoice.supplier),
                  ),
                  Expanded(
                    child: CustomerContainer(client: invoice.client),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: CustomVerticalDivider(),
              ),
              InvoiceDatesContainer(invoice: invoice),
              PaymentInfoContainer(invoice: invoice),
              SizedBox(height: 24),
              InvoiceTable(invoice: invoice),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: SignatureContainer(
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
  final String number;

  InvoiceTitle({
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
            text: 'Invoice  ',
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
  final Supplier supplier;

  SupplierContainer({
    required this.supplier,
  });

  @override
  Widget build(Context context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SUPPLIER',
          style: theme.defaultTextStyle.copyWith(
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 12),
        Text(supplier.name, style: theme.header5),
        ...supplier.address.map((it) => Text(it)),
        SizedBox(height: 4),
        Text('Identification number: ${supplier.dic}'),
        Text('VAT number: ${supplier.icdph}'),
        Text(
          'Invoice is in reverse charge mode.',
          style: theme.defaultTextStyle.copyWith(
            fontSize: 8,
          ),
        ),
        Text(
          'The buyer is obligated to fill in the VAT amounts and pay the tax.',
          style: theme.defaultTextStyle.copyWith(
            fontSize: 8,
          ),
        ),
        if (supplier.phone != null || supplier.email != null)
          SizedBox(height: 4),
        if (supplier.phone != null) Text('Phone: ${supplier.phone}'),
        if (supplier.email != null) Text('Email: ${supplier.email}'),
      ],
    );
  }
}

class CustomerContainer extends StatelessWidget {
  final Client client;

  CustomerContainer({
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
                    Text('VAT number: ${client.icdph}'),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 16,
            child: Container(
              color: PdfColor.fromHex('#FFFFFF'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'CUSTOMER',
                  style: theme.defaultTextStyle.copyWith(
                    letterSpacing: 2,
                  ),
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
  final Invoice invoice;
  static final _dateFormatter = DateFormat('dd.MM.yyyy');

  InvoiceDatesContainer({
    required this.invoice,
  });

  @override
  Widget build(Context context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InfoItem(
            title: 'Issued date',
            value: _dateFormatter.format(invoice.issueDate),
          ),
          InfoItem(
            title: 'Delivery date',
            value: _dateFormatter.format(invoice.deliveryDate),
          ),
          InfoItem(
            title: 'Due date',
            value: _dateFormatter.format(invoice.dueDate),
          ),
        ],
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final String title;
  final String value;

  InfoItem({
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

class PaymentInfoContainer extends StatelessWidget {
  final Invoice invoice;

  PaymentInfoContainer({
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
            InfoItem(
              title: 'IBAN',
              value: bankAccount.iban,
            ),
            InfoItem(
              title: 'SWIFT',
              value: bankAccount.swift,
            ),
            InfoItem(
              title: 'VS',
              value: invoice.number,
            ),
            InfoItem(
              title: 'Total price',
              value: invoice.formattedTotalPrice,
            ),
          ],
        ),
      ),
    );
  }
}

class SignatureContainer extends StatelessWidget {
  /// Signature image file content.
  final Uint8List signature;

  SignatureContainer({
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
          CustomVerticalDivider(),
          SizedBox(height: 2),
          Align(
            alignment: Alignment.center,
            child: Text(
              'Signature',
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
  final Invoice invoice;

  InvoiceTable({
    required this.invoice,
  });

  @override
  Widget build(Context context) {
    final theme = Theme.of(context);
    final currency = invoice.supplier.currency;

    final headers = [
      '#',
      'Description',
      'Amount',
      'Unit',
      'Unit cost [${currency.symbol}]',
      'Price [${currency.symbol}]',
    ];
    final values = invoice.items
        .mapIndexed(
          (i, item) => <String>[
            '${i + 1}',
            item.name,
            item.amount.toStringAsFixed(1),
            item.unit,
            currency.format(item.price, noSymbol: true),
            currency.format(item.totalPrice, noSymbol: true),
          ],
        )
        .toList();
    final totalValues = [
      '',
      'Total',
      '',
      '',
      '',
      currency.format(invoice.totalPrice, noSymbol: true),
    ];

    return Table(
      columnWidths: {
        0: const FixedColumnWidth(14.0),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(
            color: PdfColors.grey200,
            border: Border(bottom: BorderSide(width: 0.5)),
          ),
          children: headers
              .mapIndexed(
                (i, header) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 6,
                  ),
                  child: Align(
                    alignment: (i == 0)
                        ? Alignment.center
                        : (i == 1)
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                    child: Text(header, style: theme.header5),
                  ),
                ),
              )
              .toList(),
        ),
        ...values.map(
          (itemValues) => TableRow(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 0.5)),
            ),
            children: itemValues
                .mapIndexed(
                  (i, value) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 4,
                    ),
                    child: Align(
                      alignment: (i == 0)
                          ? Alignment.center
                          : (i == 1)
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                      child: Text(value),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        TableRow(
          decoration: const BoxDecoration(
            color: PdfColors.grey200,
          ),
          children: totalValues
              .mapIndexed(
                (i, value) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 4,
                  ),
                  child: Align(
                    alignment: (i == 0)
                        ? Alignment.center
                        : (i == 1)
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                    child: Text(value, style: theme.header5),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

///
/// Use this cause [Divider] from pdf package min height is 1.
///
class CustomVerticalDivider extends StatelessWidget {
  @override
  Widget build(Context context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(width: 0.5)),
      ),
    );
  }
}
