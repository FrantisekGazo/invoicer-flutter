import 'dart:convert';
import 'dart:io';

import 'package:invoicer/src/data/dao/supplier.dart';
import 'package:invoicer/src/data/model/supplier.dart';
import 'package:invoicer/src/data/service/file.dart';

///
/// Stores supplier data in a local file.
///
class FileSupplierDaoImpl implements SupplierDao {
  final FileService _fileService;
  final String _fileName;

  FileSupplierDaoImpl(
    this._fileService,
    this._fileName,
  );

  File _getFile() {
    final mainDir = _fileService.mainDirectory.value;
    if (mainDir == null) {
      throw StateError('Main directory missing!');
    }
    return _fileService.getFile(_fileName);
  }

  @override
  Future<Supplier> get() async {
    final file = _getFile();
    final strData = await file.readAsString();
    final jsonData = json.decode(strData);
    return Supplier.fromJson(jsonData);
  }

  @override
  Future<void> set(Supplier supplier) async {
    final file = _getFile();
    final data = supplier.toJson();
    final strData = json.encode(data);
    await file.writeAsString(strData);
  }
}
