import 'dart:typed_data';
import '../repositories/export_repository.dart';

class DownloadReportUseCase {
  final ExportRepository repository;
  DownloadReportUseCase(this.repository);

  Future<Uint8List> call(String room, DateTime start, DateTime end) async {
    return await repository.generateCsvReport(room, start, end);
  }
}
