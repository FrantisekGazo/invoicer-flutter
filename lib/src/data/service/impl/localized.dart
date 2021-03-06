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
  String get itemUnitCost => 'Unit cost';

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
  String get invoice => 'Fakt??ra';

  @override
  String get supplier => 'Dod??vate??';

  @override
  String get client => 'Odoberate??';

  @override
  String get ico => 'I??O';

  @override
  String get dic => 'DI??';

  @override
  String get icdph => 'I?? DPH';

  @override
  String get dphNo => 'Nie je platite?? DPH';

  @override
  String get dphPar7Part1 => 'Osoba registrovan?? pod??a ??7a z??kona o DPH.';

  @override
  String get dphPar7Part2 => 'Prenesenie da??ovej povinnosti.';

  @override
  String get phone => 'Telef??n';

  @override
  String get email => 'Email';

  @override
  String get issueDate => 'D??tum vystavenia';

  @override
  String get deliveryDate => 'D??tum dodania';

  @override
  String get dueDate => 'D??tum splatnosti';

  @override
  String get iban => 'IBAN';

  @override
  String get swift => 'SWIFT';

  @override
  String get variableSymbol => 'VS';

  @override
  String get discount => 'Z??ava za doklad';

  @override
  String get total => 'Celkom';

  @override
  String get totalPrice => 'Suma na ??hradu';

  @override
  String get signature => 'Podpis';

  @override
  String get itemNumber => '??.';

  @override
  String get itemName => 'N??zov polo??ky';

  @override
  String get itemAmount => 'Po??et';

  @override
  String get itemUnit => 'MJ';

  @override
  String get itemUnitCost => 'Jedn. cena';

  @override
  String get itemPrice => 'Cena';

  @override
  String get itemNameMobile => 'Vy??voj mobilnej aplika??cie - projekt';

  @override
  String get itemNameDesktop => 'Vy??voj desktop aplika??cie - projekt';

  @override
  String get itemNamePc =>
      'V??davky nevyhnutne vynalo??en?? v s??vislosti s poskytovan??mi slu??bami - projekt';

  @override
  String get itemNameGeneral => 'Poskytovanie progr??matorsk??ch slu??ieb';

  @override
  String get itemNameProvision =>
      'Mimoriadna prov??zia v s??lade s ??l. IV, ods. 4 Zmluvy o poskytovan?? slu??ieb';

  @override
  String get unitPc => 'ks';

  @override
  String get unitHour => 'hod';
}
