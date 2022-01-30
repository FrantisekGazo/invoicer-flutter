import 'dart:async';
import 'dart:typed_data';

import 'package:invoicer/src/data/model/invoice.dart';
import 'package:invoicer/src/data/service/font.dart';
import 'package:invoicer/src/data/service/pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfBuilderServiceImpl implements PdfBuilderService {
  final FontService _fontService;

  PdfBuilderServiceImpl(
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
    final signatureBytes = await invoice.signature.readAsBytes();

    return Document(theme: theme)
      ..addPage(
        Page(
          build: (context) => Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: InvoiceTitle(
                  number: invoice.number,
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: SupplierContainer()),
                  Expanded(child: CustomerContainer()),
                ],
              ),
              SizedBox(height: 24),
              InvoiceDatesContainer(),
              PaymentInfoContainer(),
              SizedBox(height: 24),
              Expanded(
                flex: 1,
                child: Placeholder(),
              ),
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
        Text('John Smith', style: theme.header5),
        Text('Limbová 1234/5'),
        Text('01234 Žzzzzzz'),
        Text('Slovakia'),
        SizedBox(height: 4),
        Text('Identification number: 1234567890'),
        Text('VAT number: SK1234567890'),
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
        SizedBox(height: 4),
        Text('Phone: +421949654321'),
        Text('Email: john.smith@gmail.com'),
      ],
    );
  }
}

class CustomerContainer extends StatelessWidget {
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
                    Text('John Smith', style: theme.header5),
                    Text('Limbová 1234/5'),
                    Text('01234 Žzzzzzz'),
                    Text('Slovakia'),
                    SizedBox(height: 4),
                    Text('VAT number: SK1234567890'),
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
  @override
  Widget build(Context context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InfoItem(
              title: 'Issued date',
              value: '15.03.2021',
            ),
            InfoItem(
              title: 'Delivery date',
              value: '15.03.2021',
            ),
            InfoItem(
              title: 'Due date',
              value: '31.03.2021',
            ),
          ],
        ),
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
  @override
  Widget build(Context context) {
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
              value: 'SK12 1234 5678 9012 3456 7890',
            ),
            InfoItem(
              title: 'SWIFT',
              value: 'BREXSKBX',
            ),
            InfoItem(
              title: 'VS',
              value: '20XX00Y',
            ),
            InfoItem(
              title: 'Total price',
              value: '5 000,00 EUR',
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
          DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(width: 0.5)),
            ),
          ),
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
