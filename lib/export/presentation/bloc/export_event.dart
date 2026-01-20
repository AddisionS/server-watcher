import 'package:flutter/material.dart';

abstract class ExportEvent {}

class ExportReportRequested extends ExportEvent {
  final String room;
  final DateTimeRange dateRange; // Flutter's built-in range object

  ExportReportRequested({required this.room, required this.dateRange});
}
