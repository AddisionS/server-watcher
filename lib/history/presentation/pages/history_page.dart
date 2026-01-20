import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Domain & Data Imports
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../home/data/datasource/home_datasource.dart';
import '../../../home/data/repositories/home_repository_impl.dart';
import '../../../home/domain/usecases/room_fetch_usecase.dart';
import '../../data/datasource/history_mock_data_source.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/usecases/get_history_usecase.dart';

// Presentation Imports
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../../../../home/presentation/widgets/sensor_chart.dart';
import '../../../../home/presentation/widgets/main_layout.dart';

class HistoryPage extends StatelessWidget {
  final UserEntity user;

  const HistoryPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // 1. Dependency Injection
    final homeDataSource = HomeMockDataSourceImpl();
    final homeRepo = HomeRepositoryImpl(remoteDataSource: homeDataSource);

    final historyDataSource = HistoryMockDataSourceImpl();
    final historyRepo = HistoryRepositoryImpl(
      remoteDataSource: historyDataSource,
    );

    return BlocProvider(
      create: (_) => HistoryBloc(
        getRoomsUseCase: GetRoomsUseCase(homeRepo),
        getHistoryUseCase: GetHistoryUseCase(historyRepo),
      )..add(HistoryInitialLoad()),

      // 2. USE MAIN LAYOUT
      child: MainLayout(
        user: user,
        title: "24h Log",
        body: const _HistoryContent(),
      ),
    );
  }
}

class _HistoryContent extends StatelessWidget {
  const _HistoryContent();

  @override
  Widget build(BuildContext context) {
    // Calculate responsiveness locally
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HistoryError) return Center(child: Text(state.message));

        if (state is HistoryLoaded) {
          // TRICK: Reverse the list for the Graph so time flows Left -> Right
          final graphData = state.historyData.reversed.toList();

          return Column(
            children: [
              // --- 1. Dropdown ---
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
                            color: Theme.of(context).dividerColor,
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
                            onChanged: (v) => context.read<HistoryBloc>().add(
                              HistoryRoomChanged(v!),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
                        backgroundColor: Colors.white10, // Dark mode friendly
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
        return const SizedBox();
      },
    );
  }
}
