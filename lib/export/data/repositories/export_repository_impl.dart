import 'dart:typed_data';
import '../../domain/repositories/export_repository.dart';
import '../datasources/export_data_source.dart';

class ExportRepositoryImpl implements ExportRepository {
  final ExportDataSource dataSource;
  ExportRepositoryImpl(this.dataSource);

  @override
  Future<Uint8List> generateCsvReport(
    String deviceId,
    DateTime start,
    DateTime end,
  ) {
    return dataSource.fetchCsv(deviceId, start, end);
  }
}
