import 'package:invoicer/src/data/model/register.dart';

///
/// Provides localized data.
///
abstract class LocalizedService {
  /// Get translations for an invoice.
  /// [en] If true then texts are in English, otherwise in Slovak.
  LocalizedInvoice getLocalizedInvoice(bool en);
}

///
/// Invoice translations.
///
abstract class LocalizedInvoice {
  String get invoice;

  String get supplier;

  String get client;

  String get ico;

  String get dic;

  String get icdph;

  String get vatNonPayer;

  String get vatPar7aReverseChargeMode;

  String registerCourt(RegisterCourt court);

  String get registerSection;

  String get registerInsertNo;

  String get phone;

  String get email;

  String get issueDate;

  String get deliveryDate;

  String get dueDate;

  String get iban;

  String get swift;

  String get variableSymbol;

  String get discount;

  String get total;

  String get totalPrice;

  String get signature;

  String get itemNumber;

  String get itemName;

  String get itemAmount;

  String get itemUnit;

  String get itemUnitCost;

  String get itemPrice;

  String get itemNamePc;

  String get itemNameGeneral;

  String get itemNameProvision;

  String get unitPc;

  String get unitHour;
}
