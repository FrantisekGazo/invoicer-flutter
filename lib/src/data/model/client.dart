import 'package:invoicer/src/data/model/language.dart';
import 'package:invoicer/src/data/model/project.dart';
import 'package:meta/meta.dart';

@immutable
class Client implements Comparable<Client> {
  final String name;
  final List<String> address;
  final String? ico;
  final String? dic;
  final String? icdph;
  final List<Project> projects;

  /// Used for ordering when invoices for multiple clients are build at once.
  /// So that invoice numbers are are the same on re-run.
  /// If 2 clients have the same [order] then order is determined by [name].
  final int? order;

  /// Invoice language.
  final Language lang;

  const Client({
    required this.name,
    required this.address,
    this.ico,
    this.dic,
    this.icdph,
    required this.projects,
    this.order,
    required this.lang,
  });

  Client.formJson(Map<String, dynamic> data)
      : this(
          name: data['name'],
          address: (data['address'] as List).cast<String>(),
          ico: data['ico'],
          dic: data['dic'],
          icdph: data['icdph'],
          projects: (data['projects'] as List)
              .cast<Map<String, dynamic>>()
              .map(Project.fromJson)
              .toList(),
          order: data['order'],
          lang: (data['lang'] != null)
              ? LanguageUtil.forName(data['lang'])
              : Language.sk,
        );

  bool get isForeign {
    return address.last != 'Slovensko' && address.last != 'Slovakia';
  }

  @override
  int compareTo(Client other) {
    if (this.order == other.order) {
      // if both null or both have the same number
      return this.name.compareTo(other.name);
    } else if (this.order != null && other.order != null) {
      return this.order!.compareTo(other.order!);
    } else if (this.order != null) {
      return -1;
    } else {
      // other.order is non-null
      return 1;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'ico': ico,
      'dic': dic,
      'icdph': icdph,
      'projects': projects.map((project) => project.toJson()).toList(),
      'order': order,
      'lang': lang.name,
    };
  }
}
