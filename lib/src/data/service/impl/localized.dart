import 'package:invoicer/src/data/model/register.dart';
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
  String get ico => 'Reg. no.';

  @override
  String get dic => 'Tax ID';

  @override
  String get icdph => 'VAT ID';

  @override
  String get vatNonPayer => throw UnsupportedError('no translation');

  @override
  String get vatPar7aReverseChargeMode => 'Invoice is in reverse charge mode. The buyer is obligated to fill in the VAT amounts and pay the tax.';

  @override
  String registerCourt(RegisterCourt court) => switch (court) {
        RegisterCourt.za => 'Business Register of the DC Žilina',
      };

  @override
  String get registerSection => 'section';

  @override
  String get registerInsertNo => 'insert no.';

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
  String get itemNamePc => throw UnsupportedError('no translation');

  @override
  String get itemNameGeneral => 'Software development services';

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
  String get vatNonPayer => 'Nie je platiteľ DPH';

  @override
  String get vatPar7aReverseChargeMode => 'Osoba registrovaná podľa §7a zákona o DPH. Prenesenie daňovej povinnosti.';

  @override
  String registerCourt(RegisterCourt court) => switch (court) {
        RegisterCourt.za => 'Obchodný register Okresného súdu Žilina',
      };

  @override
  String get registerSection => 'oddiel';

  @override
  String get registerInsertNo => 'vložka č.';

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
  String get itemNamePc => 'Výdavky nevyhnutne vynaložené v súvislosti s poskytovanými službami - projekt';

  @override
  String get itemNameGeneral => 'Poskytovanie prográmatorských služieb';

  @override
  String get itemNameProvision => 'Mimoriadna provízia v súlade s čl. IV, ods. 4 Zmluvy o poskytovaní služieb';

  @override
  String get unitPc => 'ks';

  @override
  String get unitHour => 'hod';
}
