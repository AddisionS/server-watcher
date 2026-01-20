import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/domain/entities/user_entity.dart';
// Data Injection Imports
import '../../../home/data/datasource/home_datasource.dart';
import '../../../../home/data/repositories/home_repository_impl.dart';
import '../../../home/domain/usecases/room_fetch_usecase.dart';
import '../../data/datasources/alerts_mock_data_source.dart';
import '../../data/repositories/alerts_repository_impl.dart';
import '../../domain/usecases/get_alerts_usecase.dart';
// Bloc Imports
import '../bloc/alerts_bloc.dart';
import '../bloc/alerts_event.dart';
import '../bloc/alerts_state.dart';
// Layout Import
import '../../../../home/presentation/widgets/main_layout.dart';

class AlertsPage extends StatelessWidget {
  final UserEntity user;

  const AlertsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // 1. Dependency Injection
    final homeRepo = HomeRepositoryImpl(
      remoteDataSource: HomeMockDataSourceImpl(),
    );
    final alertsRepo = AlertsRepositoryImpl(
      remoteDataSource: AlertsMockDataSourceImpl(),
    );

    return BlocProvider(
      create: (_) => AlertsBloc(
        getRoomsUseCase: GetRoomsUseCase(homeRepo),
        getAlertsUseCase: GetAlertsUseCase(alertsRepo),
      )..add(AlertsInitialLoad()),

      // 2. USE MAIN LAYOUT
      child: MainLayout(
        user: user,
        title: "System Alerts",
        body: const _AlertsContent(),
      ),
    );
  }
}

class _AlertsContent extends StatelessWidget {
  const _AlertsContent();

  @override
  Widget build(BuildContext context) {
    // Calculate responsiveness locally
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return BlocBuilder<AlertsBloc, AlertsState>(
      builder: (context, state) {
        if (state is AlertsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AlertsError) return Center(child: Text(state.message));

        if (state is AlertsLoaded) {
          return Column(
            children: [
              // 1. Dropdown Section
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      "Select Room:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 300 : 200,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            // FIX 1: Updated opacity method
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: state.selectedRoom,
                            isExpanded: true,
                            items: state.rooms
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(r),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => context.read<AlertsBloc>().add(
                              AlertsRoomChanged(v!),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // 2. Alerts List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.alerts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final alert = state.alerts[index];
                    final timeString =
                        "${alert.timestamp.year}-${alert.timestamp.month}-${alert.timestamp.day} ${alert.timestamp.hour.toString().padLeft(2, '0')}:${alert.timestamp.minute.toString().padLeft(2, '0')}";

                    return Card(
                      // FIX 2: Updated opacity method
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        // FIX 3: Updated opacity method
                        side: BorderSide(
                          color: Colors.red.withValues(alpha: 0.5),
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 30,
                        ),
                        title: Text(
                          alert.message,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Time: $timeString\nTemp: ${alert.temperature.toStringAsFixed(1)}°C | Hum: ${alert.humidity.toStringAsFixed(1)}%",
                          ),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}
