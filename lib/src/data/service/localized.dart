abstract class LocalizedService {
  LocalizedDocument getLocalizedDoc(bool en);
}

abstract class LocalizedDocument {
  String get invoice;

  String get supplier;

  String get client;

  String get ico;

  String get dic;

  String get icdph;

  String get dphNo;

  String get dphPar7Part1;

  String get dphPar7Part2;

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

  String get itemNameMobile;

  String get itemNameDesktop;

  String get itemNamePc;

  String get itemNameGeneral;

  String get itemNameProvision;

  String get unitPc;

  String get unitHour;
}
