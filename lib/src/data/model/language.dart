enum Language {
  sk,
  en,
}

abstract class LanguageUtil {
  static Language forName(String name) {
    for (final lang in Language.values) {
      if (lang.name == name) {
        return lang;
      }
    }
    throw StateError('Language with name $name does not exist');
  }
}
