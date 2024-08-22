import 'package:invoicer/src/data/model/bank_account.dart';
import 'package:invoicer/src/data/model/client.dart';
import 'package:invoicer/src/data/model/currency.dart';
import 'package:invoicer/src/data/model/register.dart';
import 'package:meta/meta.dart';

@immutable
class Supplier {
  final String name;
  final List<String> address;
  final String ico;
  final String? dic;
  final String? icdph;
  final RegisterInsertDetails? register;
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
    this.register,
    this.phone,
    this.email,
    required this.bankAccount,
    required this.currency,
    required this.numbering,
    required this.signaturePath,
    required this.clients,
  });

  Supplier.fromJson(Map<String, dynamic> data)
      : this(
          name: data['name'],
          address: (data['address'] as List).cast<String>(),
          ico: data['ico'],
          dic: data['dic'],
          icdph: data['icdph'],
          register: (data['register'] != null) ? RegisterInsertDetails.fromJson(data['register']) : null,
          phone: data['phone'],
          email: data['email'],
          bankAccount: BankAccount.fromJson(data['bank_account']),
          currency: CurrencyUtil.forName(data['currency']),
          numbering: data['numbering'],
          signaturePath: data['signature'],
          clients: (data['clients'] as List).cast<Map<String, dynamic>>().map(Client.formJson).toList(),
        );

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'ico': ico,
      'dic': dic,
      'icdph': icdph,
      'register': register?.toJson(),
      'phone': phone,
      'email': email,
      'bank_account': bankAccount.toJson(),
      'currency': currency.name,
      'numbering': numbering,
      'signature': signaturePath,
      'clients': clients.map((c) => c.toJson()).toList(),
    };
  }
}
