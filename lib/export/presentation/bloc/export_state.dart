abstract class ExportState {}

class ExportInitial extends ExportState {}

class ExportLoading extends ExportState {}

class ExportSuccess extends ExportState {
  final String filePath; // Or just a success message
  ExportSuccess(this.filePath);
}

class ExportFailure extends ExportState {
  final String message;
  ExportFailure(this.message);
}
