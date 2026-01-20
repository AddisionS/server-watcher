import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_saver/file_saver.dart'; // Import Package
import '../../domain/usecases/download_report_usecase.dart';
import 'export_event.dart';
import 'export_state.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final DownloadReportUseCase downloadReportUseCase;

  ExportBloc(this.downloadReportUseCase) : super(ExportInitial()) {
    on<ExportReportRequested>((event, emit) async {
      emit(ExportLoading());
      try {
        // 1. Get Bytes from Domain
        final bytes = await downloadReportUseCase.call(
          event.room,
          event.dateRange.start,
          event.dateRange.end,
        );

        // 2. Generate Filename
        final fileName =
            "report_${event.room}_${DateTime.now().millisecondsSinceEpoch}";

        // 3. Save to Device (Web triggers download, Mobile saves to folder)
        final path = await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          fileExtension: "csv",
          mimeType: MimeType.csv,
        );

        emit(ExportSuccess(path));
      } catch (e) {
        emit(ExportFailure("Failed to download report"));
      }
    });
  }
}
