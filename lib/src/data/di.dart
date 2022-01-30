import 'package:get_it/get_it.dart';
import 'package:invoicer/src/data/service/file.dart';
import 'package:invoicer/src/data/service/font.dart';
import 'package:invoicer/src/data/service/impl/file.dart';
import 'package:invoicer/src/data/service/impl/font.dart';
import 'package:invoicer/src/data/service/impl/navigation.dart';
import 'package:invoicer/src/data/service/impl/pdf.dart';
import 'package:invoicer/src/data/service/navigation.dart';
import 'package:invoicer/src/data/service/pdf.dart';

final getIt = GetIt.instance;
final inject = getIt.get;

Future<void> initDI() async {
  getIt.registerSingleton<FileService>(
    FileServiceImpl(),
  );
  getIt.registerSingleton<FontService>(
    FontServiceImpl(),
  );
  getIt.registerSingleton<PdfBuilderService>(
    PdfBuilderServiceImpl(inject(), inject()),
  );
  getIt.registerSingleton<NavigationService>(
    NavigationServiceImpl(inject()),
  );
}
