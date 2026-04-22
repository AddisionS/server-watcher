import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Domain & Data Imports
import '../../../../auth/domain/entities/user_entity.dart';
import '../../domain/usecases/data_fetch_usecase.dart';
import '../../data/datasources/home_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../../config/data/datasources/config_data_source.dart';
import '../../../config/data/repositories/config_repository_impl.dart';
import '../../../config/domain/usecases/get_thresholds_usecase.dart';

// Export Feature Imports
import '../../../export/data/datasources/export_data_source.dart';
import '../../../export/data/repositories/export_repository_impl.dart';
import '../../../export/domain/usecases/download_report_usecase.dart';
import '../../../export/presentation/bloc/export_bloc.dart';
import '../../../export/presentation/widgets/export_section.dart';

// Devices Feature Imports
import '../../../../devices/presentation/widgets/device_horizontal_list.dart';
import '../../../../devices/presentation/bloc/devices_bloc.dart';
import '../../../../devices/presentation/bloc/devices_state.dart';

// Home Widgets & Bloc
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/sensor_gauge.dart';
import '../widgets/sensor_chart.dart';
import '../widgets/main_layout.dart';

class HomePage extends StatefulWidget {
  final UserEntity user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Repos declared here, initialized in initState
  late final HomeRepositoryImpl _homeRepo;
  late final ConfigRepositoryImpl _configRepo;
  late final ExportRepositoryImpl _exportRepo;

  @override
  void initState() {
    super.initState();

    // Safe to context.read here — widget is fully mounted in the tree
    final httpClient = context.read<http.Client>();
    final sharedPrefs = context.read<SharedPreferences>();

    _homeRepo = HomeRepositoryImpl(
      remoteDataSource: HomeRemoteDataSourceImpl(
        client: httpClient,
        sharedPreferences: sharedPrefs,
      ),
    );

    _configRepo = ConfigRepositoryImpl(
      remoteDataSource: ConfigRemoteDataSourceImpl(
        client: httpClient,
        sharedPreferences: sharedPrefs,
      ),
    );

    _exportRepo = ExportRepositoryImpl(ExportDataSourceImpl(httpClient, sharedPrefs));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (_) => HomeBloc(
            getSensorStreamUseCase: GetSensorStreamUseCase(_homeRepo),
            getThresholdsUseCase: GetThresholdsUseCase(_configRepo),
          )..add(HomeInitialLoad()),
        ),
        BlocProvider<ExportBloc>(
          create: (_) => ExportBloc(DownloadReportUseCase(_exportRepo)),
        ),
      ],
      child: BlocListener<DevicesBloc, DevicesState>(
        listenWhen: (prev, curr) =>
            prev is DevicesLoading && curr is DevicesLoaded,
        listener: (context, state) {
          if (state is DevicesLoaded) {
            if (state.devices.isNotEmpty) {
              final firstDeviceId = state.devices.first.id;
              context.read<HomeBloc>().add(HomeDeviceChanged(firstDeviceId));
            } else {
              context.read<HomeBloc>().add(HomeStopPolling());
            }
          }
        },
        child: MainLayout(
          user: widget.user, // widget.user because we're inside State now
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
    final theme = Theme.of(context);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HomeError) {
          return Center(
            child: Text('Please logout and retry.\nError: ${state.message}'),
          );
        }

        if (state is HomeLoaded) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Device",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const DeviceHorizontalList(isHomePage: true),
                const SizedBox(height: 20),

                // --- GAUGES ---
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SensorGauge(
                          title: "Temperature",
                          value: double.parse(latestTemp.toStringAsFixed(1)),
                          unit: "°C",
                          axisMax: 100,
                          subThreshold: thresholds.subTemp,
                          threshold: thresholds.thresTemp,
                        ),
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
                ),

                const SizedBox(height: 30),

                // --- GRAPHS ---
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
                            lineColor: theme.colorScheme.error,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: SensorChart(
                            title: "Humidity",
                            data: state.sensorData,
                            isTemperature: false,
                            lineColor: theme.colorScheme.primary,
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
                          lineColor: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AspectRatio(
                        aspectRatio: 2,
                        child: SensorChart(
                          title: "Humidity",
                          data: state.sensorData,
                          isTemperature: false,
                          lineColor: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 30),
                ExportSection(
                  currentRoom:
                      (context.read<DevicesBloc>().state is DevicesLoaded)
                      ? (context.read<DevicesBloc>().state as DevicesLoaded)
                                .selectedDevice
                                ?.roomName ??
                            ""
                      : "",
                ),
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
