import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Domain & Data Imports
import '../../../../auth/domain/entities/user_entity.dart';
import '../../data/datasources/history_mock_data_source.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/usecases/get_history_usecase.dart';

// Presentation Imports
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../../../../home/presentation/widgets/sensor_chart.dart';
import '../../../../home/presentation/widgets/main_layout.dart';

// Device Feature Imports
import '../../../../devices/presentation/bloc/devices_bloc.dart';
import '../../../../devices/presentation/bloc/devices_state.dart';
import '../../../../devices/presentation/widgets/device_horizontal_list.dart';

class HistoryPage extends StatelessWidget {
  final UserEntity user;

  const HistoryPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // 1. Dependency Injection (Only History needed now)
    final historyDataSource = HistoryMockDataSourceImpl();
    final historyRepo = HistoryRepositoryImpl(
      remoteDataSource: historyDataSource,
    );

    return BlocProvider(
      create: (context) {
        final bloc = HistoryBloc(
          getHistoryUseCase: GetHistoryUseCase(historyRepo),
        );

        // --- FIX START ---
        // Check the Global Device State IMMEDIATELY upon creation
        final deviceState = context.read<DevicesBloc>().state;

        if (deviceState is DevicesLoaded &&
            deviceState.selectedDeviceId != null) {
          // If we already have a device, fetch data immediately
          bloc.add(HistoryDeviceChanged(deviceState.selectedDeviceId!));
        } else {
          // Otherwise, wait (Initial Load)
          bloc.add(HistoryInitialLoad());
        }
        // --- FIX END ---

        return bloc;
      },

      // Keep the Listener to handle FUTURE changes (User clicks a new device)
      child: BlocListener<DevicesBloc, DevicesState>(
        listener: (context, state) {
          if (state is DevicesLoaded && state.selectedDeviceId != null) {
            context.read<HistoryBloc>().add(
              HistoryDeviceChanged(state.selectedDeviceId!),
            );
          }
        },
        child: MainLayout(
          user: user,
          title: "24h Log",
          body: const _HistoryContent(),
        ),
      ),
    );
  }
}

class _HistoryContent extends StatelessWidget {
  const _HistoryContent();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        // Handle Loading/Error
        if (state is HistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HistoryError) return Center(child: Text(state.message));

        if (state is HistoryLoaded) {
          final graphData = state.historyData.reversed.toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. NEW DEVICE LIST ---
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Select Device",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const DeviceHorizontalList(isHomePage: false),

              const SizedBox(height: 20),

              // --- 2. THE GRAPHS ---
              AspectRatio(
                aspectRatio: isDesktop ? 4 : 1.2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: isDesktop
                      ? Row(
                          children: [
                            Expanded(
                              child: SensorChart(
                                title: "24h Temperature",
                                data: graphData,
                                isTemperature: true,
                                lineColor: Colors.red,
                              ),
                            ),
                            Expanded(
                              child: SensorChart(
                                title: "24h Humidity",
                                data: graphData,
                                isTemperature: false,
                                lineColor: Colors.blue,
                              ),
                            ),
                          ],
                        )
                      : PageView(
                          children: [
                            SensorChart(
                              title: "24h Temperature",
                              data: graphData,
                              isTemperature: true,
                              lineColor: Colors.red,
                            ),
                            SensorChart(
                              title: "24h Humidity",
                              data: graphData,
                              isTemperature: false,
                              lineColor: Colors.blue,
                            ),
                          ],
                        ),
                ),
              ),

              const Divider(thickness: 2),

              // --- 3. The Log List ---
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.historyData.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final data = state.historyData[index];
                    final timeString =
                        "${data.timestamp.hour.toString().padLeft(2, '0')}:${data.timestamp.minute.toString().padLeft(2, '0')}";

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white10,
                        child: const Icon(
                          Icons.access_time,
                          size: 20,
                          color: Colors.white70,
                        ),
                      ),
                      title: Text("Time: $timeString"),
                      subtitle: Text(
                        "Temp: ${data.temperature.toStringAsFixed(1)}°C  |  Hum: ${data.humidity.toStringAsFixed(1)}%",
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        // Initial State (Waiting for selection)
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
