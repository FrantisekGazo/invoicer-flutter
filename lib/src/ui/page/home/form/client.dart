import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:invoicer/src/data/model/client.dart';

///
/// Shows a dropdown with all clients and their details.
///
class ClientPickerItem extends StatelessWidget {
  final ValueNotifier<Client?> selected;
  final ValueListenable<List<Client>> clients;

  const ClientPickerItem({
    super.key,
    required this.selected,
    required this.clients,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Client>>(
      valueListenable: clients,
      builder: (context, all, _) => ValueListenableBuilder<Client?>(
        valueListenable: selected,
        builder: (context, selectedClient, _) {
          final theme = Theme.of(context);
          final address = selectedClient?.address;
          final dic = selectedClient?.dic;
          final icdph = selectedClient?.icdph;
          final ico = selectedClient?.ico;

          return DefaultTextStyle.merge(
            style: theme.textTheme.bodySmall,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Client:'),
                DropdownButton<Client>(
                  items: all
                      .map(
                        (it) => DropdownMenuItem<Client>(
                          value: it,
                          child: Text(it.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    selected.value = value;
                  },
                  value: selectedClient,
                ),
                if (address != null) Text(address.join('\n')),
                const SizedBox(height: 8),
                if (ico != null) Text('IČO: $ico'),
                if (dic != null) Text('DIČ: $dic'),
                if (icdph != null) Text('IČ DPH: $icdph'),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
