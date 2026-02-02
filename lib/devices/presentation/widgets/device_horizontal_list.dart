import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/devices_bloc.dart';
import '../bloc/devices_event.dart';
import '../bloc/devices_state.dart';
import '../../../../home/presentation/bloc/home_bloc.dart';
import '../../../../home/presentation/bloc/home_event.dart';

class DeviceHorizontalList extends StatelessWidget {
  final bool isHomePage; // Behavior flag

  const DeviceHorizontalList({super.key, this.isHomePage = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, // Fixed height for the strip
      child: BlocBuilder<DevicesBloc, DevicesState>(
        builder: (context, state) {
          if (state is DevicesLoading)
            return const Center(child: CircularProgressIndicator());
          if (state is DevicesError) return Center(child: Text(state.message));

          if (state is DevicesLoaded) {
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.devices.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final device = state.devices[index];
                final isSelected = device.id == state.selectedDeviceId;

                // Color Logic
                Color statusColor;
                if (device.status == 'online')
                  statusColor = Colors.green;
                else if (device.status == 'offline')
                  statusColor = Colors.red;
                else
                  statusColor = Colors.orange;

                return GestureDetector(
                  onTap: () {
                    // 1. Update Selection in Device Bloc
                    context.read<DevicesBloc>().add(SelectDevice(device.id));

                    // 2. Logic Split based on Page
                    if (isHomePage) {
                      // If Home: Tell HomeBloc to fetch data for this room
                      context.read<HomeBloc>().add(
                        HomeRoomChanged(device.roomName),
                      );
                    }
                    // Note: If on Manager page, the selection update above is enough to trigger the details view.
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 160,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? statusColor.withOpacity(0.2) // Highlight
                          : Colors.white.withOpacity(
                              0.05,
                            ), // Default dark mode card
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? statusColor : Colors.white12,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          device.roomName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: statusColor),
                            const SizedBox(width: 6),
                            Text(
                              device.status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          device.id,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
