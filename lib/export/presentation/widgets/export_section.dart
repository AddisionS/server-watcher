import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../bloc/export_state.dart';

class ExportSection extends StatefulWidget {
  final String currentRoom; // We need to know which room to export
  const ExportSection({super.key, required this.currentRoom});

  @override
  State<ExportSection> createState() => _ExportSectionState();
}

class _ExportSectionState extends State<ExportSection> {
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExportBloc, ExportState>(
      listener: (context, state) {
        if (state is ExportSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Report downloaded successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _selectedDateRange = null;
          });
        } else if (state is ExportFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
          setState(() {
            _selectedDateRange = null;
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is ExportLoading;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Export Data Report",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text("Select a date range to download CSV logs."),
                const SizedBox(height: 16),

                Row(
                  children: [
                    // 1. Date Picker Button
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _selectedDateRange == null
                              ? "Select Date Range"
                              : "${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}",
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                final picked = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(2023),
                                  lastDate: DateTime.now(),
                                  builder: (context, child) {
                                    // Force dark theme support if needed or custom colors
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        datePickerTheme:
                                            const DatePickerThemeData(
                                              rangeSelectionBackgroundColor:
                                                  Colors.blueAccent,
                                            ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() => _selectedDateRange = picked);
                                }
                              },
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 2. Download Button
                    ElevatedButton.icon(
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.download),
                      label: const Text("Download CSV"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: (isLoading || _selectedDateRange == null)
                          ? null
                          : () {
                              // Trigger BLoC
                              context.read<ExportBloc>().add(
                                ExportReportRequested(
                                  room: widget.currentRoom,
                                  dateRange: _selectedDateRange!,
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
