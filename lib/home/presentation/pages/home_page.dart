import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../domain/usecases/room_fetch_usecase.dart';
import '../../domain/usecases/data_fetch_usecase.dart';
import '../../data/datasource/home_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/usecases/thresholds_fetch_usecase.dart'; // Import this
import '../widgets/sensor_gauge.dart'; // Import the gauge
import '../../../export/data/datasources/export_mock_data_source.dart';
import '../../../export/data/repositories/export_repository_impl.dart';
import '../../../export/domain/usecases/download_report_usecase.dart';
import '../../../export/presentation/bloc/export_bloc.dart';
import '../../../export/presentation/widgets/export_section.dart'; // Import Widget
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_drawer.dart';
import '../widgets/sensor_chart.dart';
import '../widgets/responsive_layout.dart';

class HomePage extends StatelessWidget {
  final UserEntity user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
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
      child: Scaffold(
        appBar: MediaQuery.of(context).size.width < 800
            ? AppBar(
                title: Text("Dashboard (${user.role})"),
                backgroundColor: user.role == 'admin'
                    ? Colors.redAccent
                    : Colors.blueAccent,
              )
            : null,

        // On Mobile: Show Drawer. On Desktop: Null
        drawer: MediaQuery.of(context).size.width < 800
            ? HomeDrawer(user: user)
            : null,

        body: ResponsiveLayout(
          // 1. MOBILE VIEW (Existing Vertical Column)
          mobileBody: HomeContent(user: user, isDesktop: false),

          // 2. DESKTOP VIEW (Sidebar + Content)
          desktopBody: Row(
            children: [
              SizedBox(
                width: 250,
                child: HomeDrawer(
                  user: user,
                ), // We reuse the drawer as a sidebar!
              ),
              // Content Area
              Expanded(
                child: Scaffold(
                  appBar: AppBar(
                    title: Text("Dashboard (${user.role})"),
                    backgroundColor: user.role == 'admin'
                        ? Colors.redAccent
                        : Colors.blueAccent,
                    automaticallyImplyLeading: false,
                  ),
                  body: HomeContent(user: user, isDesktop: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extract the content into a separate widget to avoid code duplication
class HomeContent extends StatelessWidget {
  final bool isDesktop;
  final UserEntity user;

  const HomeContent({super.key, required this.isDesktop, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HomeError) return Center(child: Text(state.message));

        if (state is HomeLoaded) {
          // Safety Check: Get latest data or defaults if empty
          final double latestTemp = state.sensorData.isNotEmpty
              ? state.sensorData.last.temperature
              : 0.0;
          final double latestHum = state.sensorData.isNotEmpty
              ? state.sensorData.last.humidity
              : 0.0;
          final thresholds = state.thresholds;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // --- TOP BAR ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: isDesktop ? 300 : double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
                        minThreshold: thresholds.subTemp, // Start of Orange
                        maxThreshold: thresholds.thresTemp, // Start of Red
                      ),
                      // Humidity Gauge
                      SensorGauge(
                        title: "Humidity",
                        value: double.parse(latestHum.toStringAsFixed(1)),
                        unit: "%",
                        axisMax: 100,
                        minThreshold: thresholds.subHum,
                        maxThreshold: thresholds.thresHum,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- GRAPHS LAYOUT ---
                if (isDesktop)
                  AspectRatio(
                    aspectRatio: 4.5,
                    child: Row(
                      children: [
                        Expanded(
                          child: SensorChart(
                            title: "Temperature (°C)",
                            data: state.sensorData,
                            isTemperature: true,
                            lineColor: Colors.red,
                          ),
                        ),
                        Expanded(
                          child: SensorChart(
                            title: "Humidity (%)",
                            data: state.sensorData,
                            isTemperature: false,
                            lineColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 2,
                        child: SensorChart(
                          title: "Temperature",
                          data: state.sensorData,
                          isTemperature: true,
                          lineColor: Colors.red,
                        ),
                      ),
                      SensorChart(
                        title: "Humidity",
                        data: state.sensorData,
                        isTemperature: false,
                        lineColor: Colors.blue,
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

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
