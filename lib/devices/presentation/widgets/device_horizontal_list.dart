import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/devices_bloc.dart';
import '../bloc/devices_event.dart';
import '../bloc/devices_state.dart';
import '../../../../home/presentation/bloc/home_bloc.dart';
import '../../../../home/presentation/bloc/home_event.dart';

class DeviceHorizontalList extends StatefulWidget {
  final bool isHomePage;

  const DeviceHorizontalList({super.key, this.isHomePage = false});

  @override
  State<DeviceHorizontalList> createState() => _DeviceHorizontalListState();
}

class _DeviceHorizontalListState extends State<DeviceHorizontalList> {
  // 1. Create a ScrollController
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose(); // Always dispose controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Increased height slightly (100 -> 110) to make room for the scrollbar
    return SizedBox(
      height: 110,
      child: BlocBuilder<DevicesBloc, DevicesState>(
        builder: (context, state) {
          if (state is DevicesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DevicesError) return Center(child: Text(state.message));

          if (state is DevicesLoaded) {
            // 2. Wrap in RawScrollbar for custom styling
            return RawScrollbar(
              controller: _scrollController,
              thumbVisibility: true, // Always visible
              trackVisibility: true, // Show the track background (optional)
              thickness: 1, // Thin style
              radius: const Radius.circular(20), // Rounded edges
              thumbColor: Colors.grey.withValues(alpha: 0.5),
              trackColor: Colors.grey.withValues(alpha: 0.1),
              padding: const EdgeInsets.only(bottom: 1), // Spacing from bottom

              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: ListView.separated(
                  // 3. Attach the SAME controller here
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    12,
                  ), // Bottom padding prevents scrollbar overlapping content
                  itemCount: state.devices.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final device = state.devices[index];
                    final isSelected = device.id == state.selectedDeviceId;

                    Color statusColor;
                    if (device.status == 'online') {
                      statusColor = Colors.green;
                    } else if (device.status == 'offline') {
                      statusColor = Colors.red;
                    } else {
                      statusColor = Colors.orange;
                    }

                    return GestureDetector(
                      onTap: () {
                        context.read<DevicesBloc>().add(
                          SelectDevice(device.id),
                        );
                        if (widget.isHomePage) {
                          context.read<HomeBloc>().add(
                            HomeRoomChanged(device.roomName),
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 160,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? statusColor.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.05),
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
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
