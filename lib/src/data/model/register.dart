import 'package:meta/meta.dart';

enum RegisterCourt {
  za('ZA'),
  ;

  final String id;

  const RegisterCourt(this.id);

  static RegisterCourt forId(String id) {
    for (final value in values) {
      if (value.id == id) {
        return value;
      }
    }
    throw StateError('RegisterCourt with id $id does not exist!');
  }
}

@immutable
class RegisterInsertDetails {
  final RegisterCourt court;
  final String section;
  final String insertNo;

  const RegisterInsertDetails({
    required this.court,
    required this.section,
    required this.insertNo,
  });

  RegisterInsertDetails.fromJson(Map<String, dynamic> data)
      : this(
          court: RegisterCourt.forId(data['court']),
          section: data['section'],
          insertNo: data['insert'],
        );

  Map<String, dynamic> toJson() {
    return {
      'court': court.id,
      'section': section,
      'insert': insertNo,
    };
  }
}
