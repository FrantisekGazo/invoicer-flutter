import 'package:invoicer/src/data/model/bank_account.dart';
import 'package:invoicer/src/data/model/client.dart';
import 'package:invoicer/src/data/model/currency.dart';
import 'package:meta/meta.dart';

@immutable
class Supplier {
  final String name;
  final List<String> address;
  final String ico;
  final String? dic;
  final String? icdph;
  final String? phone;
  final String? email;
  final BankAccount bankAccount;
  final Currency currency;
  final String numbering;
  final String signaturePath;
  final List<Client> clients;

  const Supplier({
    required this.name,
    required this.address,
    required this.ico,
    this.dic,
    this.icdph,
    this.phone,
    this.email,
    required this.bankAccount,
    required this.currency,
    required this.numbering,
    required this.signaturePath,
    required this.clients,
  });
}
