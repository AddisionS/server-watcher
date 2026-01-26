import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Domain & Data Imports
import '../../../../auth/domain/entities/user_entity.dart';
import '../../domain/usecases/room_fetch_usecase.dart';
import '../../domain/usecases/data_fetch_usecase.dart';
import '../../data/datasources/home_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/usecases/thresholds_fetch_usecase.dart';

// Export Feature Imports
import '../../../export/data/datasources/export_mock_data_source.dart';
import '../../../export/data/repositories/export_repository_impl.dart';
import '../../../export/domain/usecases/download_report_usecase.dart';
import '../../../export/presentation/bloc/export_bloc.dart';
import '../../../export/presentation/widgets/export_section.dart';

// Home Widgets & Bloc
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/sensor_gauge.dart';
import '../widgets/sensor_chart.dart';
import '../widgets/main_layout.dart'; // <--- IMPORT THE NEW LAYOUT

class HomePage extends StatelessWidget {
  final UserEntity user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // 1. Dependency Injection
    final dataSource = HomeMockDataSourceImpl();
    final repo = HomeRepositoryImpl(remoteDataSource: dataSource);

    final exportRepo = ExportRepositoryImpl(ExportMockDataSourceImpl());
    final downloadUseCase = DownloadReportUseCase(exportRepo);

    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (_) => HomeBloc(
            getRoomsUseCase: GetRoomsUseCase(repo),
            getSensorStreamUseCase: GetSensorStreamUseCase(repo),
            getThresholdsUseCase: GetThresholdsUseCase(repo),
          )..add(HomeInitialLoad()),
        ),
        BlocProvider<ExportBloc>(create: (_) => ExportBloc(downloadUseCase)),
      ],

      // 2. USE MAIN LAYOUT (Replaces Scaffold, AppBar, Drawer, ResponsiveLayout)
      child: MainLayout(
        user: user,
        title: "Dashboard",
        body: const HomeContent(), // Content is now cleaner
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    // We check width locally just to decide if graphs should be Row or Column
    // This allows the inner content to be responsive even if the Sidebar is fixed.
    final bool isWideScreen = MediaQuery.of(context).size.width >= 1000;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HomeError) return Center(child: Text(state.message));

        if (state is HomeLoaded) {
          // Safety Check
          final double latestTemp = state.sensorData.isNotEmpty
              ? state.sensorData.last.temperature
              : 0.0;
          final double latestHum = state.sensorData.isNotEmpty
              ? state.sensorData.last.humidity
              : 0.0;
          final thresholds = state.thresholds;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // --- 1. TOP BAR (Dropdown) ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 300, // Fixed width for web look
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      // Use Theme colors (border transparent white in dark mode)
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: state.selectedRoom,
                        isExpanded: true,
                        items: state.rooms
                            .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            context.read<HomeBloc>().add(HomeRoomChanged(v!)),
                      ),
                    ),
                  ),
                ),

                // --- 2. GAUGES SECTION ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    // Subtle background for dark mode
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Temperature Gauge
                      SensorGauge(
                        title: "Temperature",
                        value: double.parse(latestTemp.toStringAsFixed(1)),
                        unit: "°C",
                        axisMax: 50,
                        subThreshold: thresholds.subTemp,
                        threshold: thresholds.thresTemp,
                      ),
                      // Humidity Gauge
                      SensorGauge(
                        title: "Humidity",
                        value: double.parse(latestHum.toStringAsFixed(1)),
                        unit: "%",
                        axisMax: 100,
                        subThreshold: thresholds.subHum,
                        threshold: thresholds.thresHum,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- 3. GRAPHS LAYOUT ---
                if (isWideScreen)
                  // Side-by-Side for Wide Screens
                  AspectRatio(
                    aspectRatio: 3.5,
                    child: Row(
                      children: [
                        Expanded(
                          child: SensorChart(
                            title: "Temperature",
                            data: state.sensorData,
                            isTemperature: true,
                            lineColor: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: SensorChart(
                            title: "Humidity",
                            data: state.sensorData,
                            isTemperature: false,
                            lineColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Stacked for Narrow Screens (Tablets/Small Laptops)
                  Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.8,
                        child: SensorChart(
                          title: "Temperature",
                          data: state.sensorData,
                          isTemperature: true,
                          lineColor: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AspectRatio(
                        aspectRatio: 1.8,
                        child: SensorChart(
                          title: "Humidity",
                          data: state.sensorData,
                          isTemperature: false,
                          lineColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 30),

                // --- 4. EXPORT SECTION ---
                ExportSection(currentRoom: state.selectedRoom),

                const SizedBox(height: 40),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
