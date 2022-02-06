import 'package:meta/meta.dart';

@immutable
class BankAccount {
  final String iban;
  final String swift;

  const BankAccount({
    required this.iban,
    required this.swift,
  });

  BankAccount.fromJson(Map<String, dynamic> data)
      : this(
          iban: data['iban'],
          swift: data['swift'],
        );

  Map<String, dynamic> toJson() {
    return {
      'iban': iban,
      'swift': swift,
    };
  }
}
