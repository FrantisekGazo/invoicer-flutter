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

  Project.fromJson(Map<String, dynamic> data)
      : this(
          name: data['name'],
          type: ProjectTypeUtil.forName(data['type']),
          aliases: (data['aliases'] != null)
              ? (data['aliases'] as List).cast<String>()
              : const [],
          defaultPrice: data['default_price'],
        );

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
      'aliases': aliases,
      'default_price': defaultPrice,
    };
  }
}
