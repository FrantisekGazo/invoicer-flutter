import 'package:invoicer/src/data/model/project.dart';
import 'package:meta/meta.dart';

@immutable
class Client {
  final String name;
  final String type;
  final int order;
  final List<String> address;
  final String? ico;
  final String? dic;
  final String? icdph;
  final double price;
  final List<Project> projects;

  const Client({
    required this.name,
    required this.type,
    required this.address,
    this.ico,
    this.dic,
    this.icdph,
    required this.projects,
    required this.price,
    this.order = 0,
  });

  bool get isForeign {
    return address.last != 'Slovensko' && address.last != 'Slovakia';
  }
}
