import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../auth/domain/entities/user_entity.dart';

// Data Injection Imports
import '../../data/datasources/alerts_data_source.dart';
import '../../data/repositories/alerts_repository_impl.dart';
import '../../domain/usecases/get_alerts_usecase.dart';

// Bloc Imports
import '../bloc/alerts_bloc.dart';
import '../bloc/alerts_event.dart';
import '../bloc/alerts_state.dart';

// Layout & Widget Imports
import '../../../../home/presentation/widgets/main_layout.dart';
import '../../../../devices/presentation/bloc/devices_bloc.dart';
import '../../../../devices/presentation/bloc/devices_state.dart';
import '../../../../devices/presentation/widgets/device_horizontal_list.dart';

class AlertsPage extends StatelessWidget {
  final UserEntity user;

  const AlertsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final httpClient = context.read<http.Client>();
    // 1. Dependency Injection
    final alertsRepo = AlertsRepositoryImpl(
      remoteDataSource: AlertsRemoteDataSourceImpl(
        client: httpClient,
        sharedPreferences: context.read<SharedPreferences>(),
      ),
    );

    return BlocProvider(
      create: (context) {
        final bloc = AlertsBloc(getAlertsUseCase: GetAlertsUseCase(alertsRepo));

        // --- FIX START ---
        // Check Global Device State immediately
        final deviceState = context.read<DevicesBloc>().state;

        if (deviceState is DevicesLoaded &&
            deviceState.selectedDeviceId != null) {
          bloc.add(AlertsDeviceChanged(deviceState.selectedDeviceId!));
        } else {
          bloc.add(AlertsInitialLoad());
        }
        // --- FIX END ---

        return bloc;
      },

      child: BlocListener<DevicesBloc, DevicesState>(
        listener: (context, state) {
          if (state is DevicesLoaded && state.selectedDeviceId != null) {
            context.read<AlertsBloc>().add(
              AlertsDeviceChanged(state.selectedDeviceId!),
            );
          }
        },
        child: MainLayout(
          user: user,
          title: "System Alerts",
          body: const _AlertsContent(),
        ),
      ),
    );
  }
}

class _AlertsContent extends StatelessWidget {
  const _AlertsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Device List (ALWAYS VISIBLE)
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Select Device",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const DeviceHorizontalList(isHomePage: false),
        const Divider(),

        // 2. Alerts List (DEPENDS ON STATE)
        Expanded(
          child: BlocBuilder<AlertsBloc, AlertsState>(
            builder: (context, state) {
              if (state is AlertsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AlertsError)
                return Center(child: Text(state.message));

              if (state is AlertsLoaded) {
                if (state.alerts.isEmpty) {
                  return const Center(
                    child: Text("No alerts found for this device."),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.alerts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final alert = state.alerts[index];
                    final ts = alert.timestamp;
                    final timeString =
                        "${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')} ";

                    return Card(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                );
              }
              return const Center(
                child: Text("Select a device to view alerts."),
              );
            },
          ),
        ),
      ],
    );
  }
}
