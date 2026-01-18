import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Imports

import '../../../../auth/domain/entities/user_entity.dart';
import '../../../home/data/datasource/home_datasource.dart';
import '../../../home/data/repositories/home_repository_impl.dart';
import '../../../home/domain/usecases/room_fetch_usecase.dart';
import '../../../../home/presentation/widgets/home_drawer.dart';
import '../../../../home/presentation/widgets/responsive_layout.dart';
import '../../data/datasource/history_mock_data_source.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/usecases/get_history_usecase.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../../../../home/presentation/widgets/sensor_chart.dart';

class HistoryPage extends StatelessWidget {
  final UserEntity user;

  const HistoryPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Dependency Injection
    // 1. Home feature tools (for rooms)
    final homeDataSource = HomeMockDataSourceImpl();
    final homeRepo = HomeRepositoryImpl(
      remoteDataSource: homeDataSource,
    ); //<-- gets room using this repo

    // 2. History feature tools (for logs)
    final historyDataSource = HistoryMockDataSourceImpl();
    final historyRepo = HistoryRepositoryImpl(
      remoteDataSource: historyDataSource,
    ); //<-- gets logs using this repo

    return BlocProvider(
      create: (_) => HistoryBloc(
        getRoomsUseCase: GetRoomsUseCase(homeRepo),
        getHistoryUseCase: GetHistoryUseCase(historyRepo),
      )..add(HistoryInitialLoad()),
      child: Scaffold(
        appBar: MediaQuery.of(context).size.width < 800
            ? AppBar(
                title: const Text("24h Log"),
                backgroundColor: user.role == 'admin'
                    ? Colors.redAccent
                    : Colors.blueAccent,
              )
            : null,
        drawer: MediaQuery.of(context).size.width < 800
            ? HomeDrawer(user: user)
            : null,
        body: ResponsiveLayout(
          mobileBody: _HistoryContent(isDesktop: false, user: user),
          desktopBody: Row(
            children: [
              SizedBox(width: 250, child: HomeDrawer(user: user)),
              Expanded(
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text("24h Log"),
                    backgroundColor: user.role == 'admin'
                        ? Colors.redAccent
                        : Colors.blueAccent,
                    automaticallyImplyLeading: false,
                  ),
                  body: _HistoryContent(isDesktop: true, user: user),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryContent extends StatelessWidget {
  final bool isDesktop;
  final UserEntity user;

  const _HistoryContent({required this.isDesktop, required this.user});

  @override
  Widget build(BuildContext context) {
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
              // --- 1. Dropdown (Same as before) ---
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
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
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
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

              // --- 2. THE GRAPHS (New Section) ---
              // We put this in a scrollable area so it doesn't overflow on small screens
              AspectRatio(
                aspectRatio: isDesktop
                    ? 3.0
                    : 1.2, // Fixed height for charts area
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: isDesktop
                      ? Row(
                          children: [
                            Expanded(
                              child: SensorChart(
                                title: "24h Temperature",
                                data: graphData, // Use the Reversed List
                                isTemperature: true,
                                lineColor: Colors.red,
                              ),
                            ),
                            Expanded(
                              child: SensorChart(
                                title: "24h Humidity",
                                data: graphData, // Use the Reversed List
                                isTemperature: false,
                                lineColor: Colors.blue,
                              ),
                            ),
                          ],
                        )
                      : PageView(
                          // On mobile, swipe between graphs
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

              // --- 3. The Log List (Existing) ---
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.historyData.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final data = state.historyData[index];
                    final timeString =
                        "${data.timestamp.hour.toString().padLeft(2, '0')}:${data.timestamp.minute.toString().padLeft(2, '0')}";

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: const Icon(
                          Icons.access_time,
                          size: 20,
                          color: Colors.black54,
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
