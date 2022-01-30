enum ProjectType {
  mobile,
  desktop,
  general,
  provision,
}

abstract class ProjectTypeUtil {
  ProjectType forName(String name) {
    for (final type in ProjectType.values) {
      if (name == type.name) {
        return type;
      }
    }
    throw StateError('ProjectType with name $name does not exist');
  }
}
