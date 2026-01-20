import 'dart:typed_data';
import '../../domain/repositories/export_repository.dart';
import '../datasources/export_mock_data_source.dart';

class ExportRepositoryImpl implements ExportRepository {
  final ExportRemoteDataSource dataSource;
  ExportRepositoryImpl(this.dataSource);

  @override
  Future<Uint8List> generateCsvReport(
    String room,
    DateTime start,
    DateTime end,
  ) {
    return dataSource.fetchCsv(room, start, end);
  }
}
