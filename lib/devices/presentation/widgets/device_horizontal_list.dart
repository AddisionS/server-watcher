// lib/devices/presentation/widgets/device_horizontal_list.dart

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final deviceState = context.read<DevicesBloc>().state;

      if (deviceState is DevicesLoaded &&
          deviceState.selectedDeviceId != null) {
        final deviceId = deviceState.selectedDeviceId!;
        context.read<DevicesBloc>().add(SelectDevice(deviceId));
        if (widget.isHomePage) {
          final liveState =
              deviceState.deviceStatuses[deviceId]?.state ?? 'unknown';
          if (liveState != 'dead' && liveState != 'unknown') {
            context.read<HomeBloc>().add(HomeDeviceChanged(deviceId));
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: BlocBuilder<DevicesBloc, DevicesState>(
        builder: (context, state) {
          if (state is DevicesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DevicesError) return Center(child: Text(state.message));

          if (state is DevicesLoaded) {
            return RawScrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 1,
              radius: const Radius.circular(20),
              thumbColor: Colors.grey.withValues(alpha: 0.5),
              trackColor: Colors.grey.withValues(alpha: 0.1),
              padding: const EdgeInsets.only(bottom: 1),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  itemCount: state.devices.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final device = state.devices[index];
                    final isSelected = device.id == state.selectedDeviceId;

                    final statusInfo = state.deviceStatuses[device.id];
                    final liveState = statusInfo?.state ?? 'unknown';
                    final alertActive = statusInfo?.alertActive ?? false;

                    Color statusColor;
                    String statusLabel;
                    print(statusInfo);
                    print(liveState);
                    print(alertActive);
                    if (alertActive) {
                      statusColor = Colors.red;
                      statusLabel = 'ALERT';
                    } else if (liveState == 'alive') {
                      statusColor = Colors.green;
                      statusLabel = 'ONLINE';
                    } else {
                      statusColor = const Color.fromARGB(255, 133, 133, 133);
                      statusLabel = liveState == 'dead' ? 'OFFLINE' : 'UNKNOWN';
                    }

                    return GestureDetector(
                      onTap: () {
                        context.read<DevicesBloc>().add(
                          SelectDevice(device.id),
                        );
                        if (widget.isHomePage &&
                            liveState != 'dead' &&
                            liveState != 'unknown') {
                          context.read<HomeBloc>().add(
                            HomeDeviceChanged(device.id),
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
                                  statusLabel,
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
