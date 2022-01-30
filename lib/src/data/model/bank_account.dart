import 'package:meta/meta.dart';

@immutable
class BankAccount {
  final String iban;
  final String swift;

  const BankAccount({
    required this.iban,
    required this.swift,
  });
}
