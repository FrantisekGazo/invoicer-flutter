enum ProjectType {
  mobile,
  desktop,
  general,
  provision,
}

abstract class ProjectTypeUtil {
  static ProjectType forName(String name) {
    for (final type in ProjectType.values) {
      if (type.name == name.toLowerCase()) {
        return type;
      }
    }
    throw StateError('ProjectType with name $name does not exist');
  }
}
