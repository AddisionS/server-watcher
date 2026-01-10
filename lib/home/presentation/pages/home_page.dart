import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../domain/usecases/room_fetch_usecase.dart';
import '../../domain/usecases/data_fetch_usecase.dart';
import '../../data/datasource/home_datasource.dart';
import '../../data/repos/home_repository_impl.dart';
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
    // Dependency Injection (Same as before)
    final dataSource = HomeMockDataSourceImpl();
    final repo = HomeRepositoryImpl(remoteDataSource: dataSource);

    return BlocProvider(
      create: (_) => HomeBloc(
        getRoomsUseCase: GetRoomsUseCase(repo),
        getSensorStreamUseCase: GetSensorStreamUseCase(repo),
      )..add(HomeInitialLoad()),
      child: Scaffold(
        // On Mobile: Show AppBar. On Desktop: Hide it (Custom design)
        appBar: MediaQuery.of(context).size.width < 800
            ? AppBar(
                title: Text("Dashboard (${user.role})"),
                backgroundColor: user.role == 'admin'
                    ? const Color.fromARGB(255, 243, 124, 124)
                    : const Color.fromARGB(255, 98, 143, 221),
              )
            : null,

        // On Mobile: Show Drawer. On Desktop: Null
        drawer: MediaQuery.of(context).size.width < 800
            ? HomeDrawer(user: user)
            : null,

        body: ResponsiveLayout(
          // 1. MOBILE VIEW (Existing Vertical Column)
          mobileBody: _HomeContent(user: user, isDesktop: false),

          // 2. DESKTOP VIEW (Sidebar + Content)
          desktopBody: Row(
            children: [
              // Permanent Sidebar
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
                    automaticallyImplyLeading: false, // Hide hamburger
                  ),
                  body: _HomeContent(user: user, isDesktop: true),
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
class _HomeContent extends StatelessWidget {
  final bool isDesktop;
  final UserEntity user;

  const _HomeContent({required this.isDesktop, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HomeError) return Center(child: Text(state.message));

        if (state is HomeLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Dropdown
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: isDesktop
                        ? 300
                        : double.infinity, // Smaller dropdown on desktop
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
                const SizedBox(height: 20),

                // Graphs Layout
                // On Desktop: Show graphs side-by-side. On Mobile: Top-to-bottom.
                if (isDesktop)
                  Row(
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
                  )
                else
                  Column(
                    children: [
                      SensorChart(
                        title: "Temperature",
                        data: state.sensorData,
                        isTemperature: true,
                        lineColor: Colors.red,
                      ),
                      SensorChart(
                        title: "Humidity",
                        data: state.sensorData,
                        isTemperature: false,
                        lineColor: Colors.blue,
                      ),
                    ],
                  ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
