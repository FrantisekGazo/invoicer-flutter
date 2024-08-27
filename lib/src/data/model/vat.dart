enum VatRegistration {
  no('no'),
  par7a('par7a'),
  yes('yes'),
  ;

  final String id;

  const VatRegistration(this.id);

  static VatRegistration forId(String? id) {
    for (final value in values) {
      if (value.id == id) {
        return value;
      }
    }
    return VatRegistration.no;
  }
}
