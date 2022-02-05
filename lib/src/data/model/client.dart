import 'package:invoicer/src/data/model/language.dart';
import 'package:invoicer/src/data/model/project.dart';
import 'package:meta/meta.dart';

@immutable
class Client {
  final String name;
  final List<String> address;
  final String? ico;
  final String? dic;
  final String? icdph;
  final List<Project> projects;
  final int? order;

  /// invoice language
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

  bool get isForeign {
    return address.last != 'Slovensko' && address.last != 'Slovakia';
  }
}
