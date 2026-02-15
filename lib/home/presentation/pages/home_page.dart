import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Imports ...
import '../../../../auth/domain/entities/user_entity.dart';
import '../../domain/usecases/data_fetch_usecase.dart';
import '../../data/datasources/home_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../../config/data/datasources/config_mock_data_source.dart';
import '../../../config/data/repositories/config_repository_impl.dart';
import '../../../config/domain/usecases/get_thresholds_usecase.dart';
import '../../../export/data/datasources/export_mock_data_source.dart';
import '../../../export/data/repositories/export_repository_impl.dart';
import '../../../export/domain/usecases/download_report_usecase.dart';
import '../../../export/presentation/bloc/export_bloc.dart';
import '../../../export/presentation/widgets/export_section.dart';
import '../../../../devices/presentation/widgets/device_horizontal_list.dart';
import '../../../../devices/presentation/bloc/devices_bloc.dart';
import '../../../../devices/presentation/bloc/devices_state.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/sensor_gauge.dart';
import '../widgets/sensor_chart.dart';
import '../widgets/main_layout.dart';

class HomePage extends StatelessWidget {
  final UserEntity user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Dependency Injection
    final homeRepo = HomeRepositoryImpl(
      remoteDataSource: HomeMockDataSourceImpl(),
    );
    final configRepo = ConfigRepositoryImpl(
      remoteDataSource: ConfigMockDataSourceImpl(),
    );
    final exportRepo = ExportRepositoryImpl(ExportMockDataSourceImpl());

    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (_) => HomeBloc(
            getSensorStreamUseCase: GetSensorStreamUseCase(homeRepo),
            getThresholdsUseCase: GetThresholdsUseCase(configRepo),
          )..add(HomeInitialLoad()),
        ),
        BlocProvider<ExportBloc>(
          create: (_) => ExportBloc(DownloadReportUseCase(exportRepo)),
        ),
      ],
      child: BlocListener<DevicesBloc, DevicesState>(
        // OPTIMIZATION: When Devices are loaded for the first time,
        // automatically select the first device to start the Home stream.
        listenWhen: (prev, curr) =>
            prev is DevicesLoading && curr is DevicesLoaded,
        listener: (context, state) {
          if (state is DevicesLoaded && state.devices.isNotEmpty) {
            final firstRoom = state.devices.first.roomName;
            context.read<HomeBloc>().add(HomeRoomChanged(firstRoom));
          }
        },
        child: MainLayout(
          user: user,
          title: "Dashboard",
          body: const HomeContent(),
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 1000;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HomeError) return Center(child: Text(state.message));

        if (state is HomeLoaded) {
          final double latestTemp = state.sensorData.isNotEmpty
              ? state.sensorData.last.temperature
              : 0.0;
          final double latestHum = state.sensorData.isNotEmpty
              ? state.sensorData.last.humidity
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. REPLACED DROPDOWN WITH DEVICE LIST ---
                const Text(
                  "Select Device",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const DeviceHorizontalList(isHomePage: true),

                const SizedBox(height: 30),

                // --- 2. GAUGES ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SensorGauge(
                        title: "Temperature",
                        value: double.parse(latestTemp.toStringAsFixed(1)),
                        unit: "°C",
                        axisMax: 50,
                        subThreshold: state.thresholds.subTemp,
                        threshold: state.thresholds.thresTemp,
                      ),
                      SensorGauge(
                        title: "Humidity",
                        value: double.parse(latestHum.toStringAsFixed(1)),
                        unit: "%",
                        axisMax: 100,
                        subThreshold: state.thresholds.subHum,
                        threshold: state.thresholds.thresHum,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- 3. GRAPHS ---
                if (isWideScreen)
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
                      const SizedBox(height: 20),
                      AspectRatio(
                        aspectRatio: 2,
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
