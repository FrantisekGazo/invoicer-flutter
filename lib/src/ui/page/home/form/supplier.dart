import 'package:flutter/material.dart';
import 'package:invoicer/src/data/model/supplier.dart';

///
/// Shows non-editable supplier info.
///
class SupplierInfoItem extends StatelessWidget {
  final Supplier supplier;

  const SupplierInfoItem({
    super.key,
    required this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final email = supplier.email;
    final phone = supplier.phone;
    final dic = supplier.dic;
    final icdph = supplier.icdph;
    final ico = supplier.ico;
    final bankAccount = supplier.bankAccount;

    return DefaultTextStyle.merge(
      style: theme.textTheme.bodySmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Supplier:'),
          const SizedBox(height: 16),
          Text(
            supplier.name,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text(supplier.address.join('\n')),
          const SizedBox(height: 8),
          Text('IČO: $ico', style: theme.textTheme.bodyMedium),
          Text('DIČ: $dic'),
          if (icdph != null) Text('IČ DPH: $icdph'),
          const SizedBox(height: 8),
          if (email != null) Text('E-mail: $email'),
          if (phone != null) Text('Phone: $phone'),
          const SizedBox(height: 8),
          const Text('Bank account:'),
          Text(bankAccount.iban, style: theme.textTheme.bodyMedium),
          Text('SWIFT: ${bankAccount.swift}'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
