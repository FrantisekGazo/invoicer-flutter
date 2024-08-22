enum Language {
  sk,
  en,
  ;

  static Language forName(String name) {
    for (final lang in Language.values) {
      if (lang.name == name.toLowerCase()) {
        return lang;
      }
    }
    throw StateError('Language with name $name does not exist!');
  }
}
