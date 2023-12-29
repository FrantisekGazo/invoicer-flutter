import 'package:invoicer/src/data/service/localized.dart';

class LocalizedServiceImpl implements LocalizedService {
  @override
  LocalizedInvoice getLocalizedInvoice(bool en) {
    return en ? const _EnLocalizedDocument() : const _SkLocalizedDocument();
  }
}

class _EnLocalizedDocument implements LocalizedInvoice {
  const _EnLocalizedDocument();

  @override
  String get invoice => 'Invoice';

  @override
  String get supplier => 'Supplier';

  @override
  String get client => 'Customer';

  @override
  String get ico => 'Identification number';

  @override
  String get dic => 'Tax number';

  @override
  String get icdph => 'VAT number';

  @override
  String get dphNo => throw UnsupportedError('no translation');

  @override
  String get dphPar7Part1 => 'Invoice is in reverse charge mode.';

  @override
  String get dphPar7Part2 =>
      'The buyer is obligated to fill in the VAT amounts and pay the tax.';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get issueDate => 'Issue date';

  @override
  String get deliveryDate => 'Delivery date';

  @override
  String get dueDate => 'Due date';

  @override
  String get iban => 'IBAN';

  @override
  String get swift => 'SWIFT';

  @override
  String get variableSymbol => 'VS';

  @override
  String get discount => 'Discount';

  @override
  String get total => 'Total';

  @override
  String get totalPrice => 'Total price';

  @override
  String get signature => 'Signature';

  @override
  String get itemNumber => '#';

  @override
  String get itemName => 'Description';

  @override
  String get itemAmount => 'Amount';

  @override
  String get itemUnit => 'Unit';

  @override
  String get itemUnitCost => 'Unit Price';

  @override
  String get itemPrice => 'Price';

  @override
  String get itemNameMobile => 'Mobile application development - project';

  @override
  String get itemNameDesktop => 'Desktop application development - project';

  @override
  String get itemNamePc => throw UnsupportedError('no translation');

  @override
  String get itemNameGeneral => 'Application development';

  @override
  String get itemNameProvision => throw UnsupportedError('no translation');

  @override
  String get unitPc => 'pc';

  @override
  String get unitHour => 'h';
}

class _SkLocalizedDocument implements LocalizedInvoice {
  const _SkLocalizedDocument();

  @override
  String get invoice => 'Faktúra';

  @override
  String get supplier => 'Dodávateľ';

  @override
  String get client => 'Odoberateľ';

  @override
  String get ico => 'IČO';

  @override
  String get dic => 'DIČ';

  @override
  String get icdph => 'IČ DPH';

  @override
  String get dphNo => 'Nie je platiteľ DPH';

  @override
  String get dphPar7Part1 => 'Osoba registrovaná podľa §7a zákona o DPH.';

  @override
  String get dphPar7Part2 => 'Prenesenie daňovej povinnosti.';

  @override
  String get phone => 'Telefón';

  @override
  String get email => 'Email';

  @override
  String get issueDate => 'Dátum vystavenia';

  @override
  String get deliveryDate => 'Dátum dodania';

  @override
  String get dueDate => 'Dátum splatnosti';

  @override
  String get iban => 'IBAN';

  @override
  String get swift => 'SWIFT';

  @override
  String get variableSymbol => 'VS';

  @override
  String get discount => 'Zľava za doklad';

  @override
  String get total => 'Celkom';

  @override
  String get totalPrice => 'Suma na úhradu';

  @override
  String get signature => 'Podpis';

  @override
  String get itemNumber => 'Č.';

  @override
  String get itemName => 'Názov položky';

  @override
  String get itemAmount => 'Počet';

  @override
  String get itemUnit => 'MJ';

  @override
  String get itemUnitCost => 'Jedn. cena';

  @override
  String get itemPrice => 'Cena';

  @override
  String get itemNameMobile => 'Vývoj mobilnej aplikácie - projekt';

  @override
  String get itemNameDesktop => 'Vývoj desktop aplikácie - projekt';

  @override
  String get itemNamePc =>
      'Výdavky nevyhnutne vynaložené v súvislosti s poskytovanými službami - projekt';

  @override
  String get itemNameGeneral => 'Poskytovanie prográmatorských služieb';

  @override
  String get itemNameProvision =>
      'Mimoriadna provízia v súlade s čl. IV, ods. 4 Zmluvy o poskytovaní služieb';

  @override
  String get unitPc => 'ks';

  @override
  String get unitHour => 'hod';
}
