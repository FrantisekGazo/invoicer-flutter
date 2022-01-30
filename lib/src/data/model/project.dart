import 'package:invoicer/src/data/model/project_type.dart';
import 'package:meta/meta.dart';

@immutable
class Project {
  final String name;
  final ProjectType type;
  final List<String> aliases;
  final double? defaultPrice;

  const Project({
    required this.name,
    required this.type,
    required this.aliases,
    this.defaultPrice,
  });
}
