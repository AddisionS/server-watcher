import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../home/presentation/widgets/main_layout.dart';
import '../bloc/devices_bloc.dart';
import '../bloc/devices_event.dart';
import '../bloc/devices_state.dart';
import '../widgets/device_horizontal_list.dart';

class DeviceManagerPage extends StatefulWidget {
  final UserEntity user;
  const DeviceManagerPage({super.key, required this.user});

  @override
  State<DeviceManagerPage> createState() => _DeviceManagerPageState();
}

class _DeviceManagerPageState extends State<DeviceManagerPage> {
  final _roomController = TextEditingController();

  void _showAddDialog(BuildContext context) {
    final addController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Device"),
        content: TextField(
          controller: addController,
          decoration: const InputDecoration(labelText: "Room Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (addController.text.isNotEmpty) {
                context.read<DevicesBloc>().add(
                  AddDeviceRequested(addController.text),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      user: widget.user,
      title: "Device Manager",
      body: BlocConsumer<DevicesBloc, DevicesState>(
        listener: (context, state) {
          if (state is DevicesOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is! DevicesLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.devices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.devices_other,
                    size: 80,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No devices configured yet.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text("Add Your First Device"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final selectedDevice = state.selectedDevice;
          if (selectedDevice != null &&
              _roomController.text != selectedDevice.roomName) {
            _roomController.text = selectedDevice.roomName;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top List
              const SizedBox(height: 20),
              const DeviceHorizontalList(isHomePage: false),
              const Divider(height: 40),

              // 2. Details Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: selectedDevice == null
                      ? const Center(child: Text("Select a device to edit"))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Device Details",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ID (Read-only)
                            ListTile(
                              title: const Text("Device ID"),
                              subtitle: Text(
                                selectedDevice.id,
                                style: const TextStyle(fontSize: 18),
                              ),
                              leading: const Icon(Icons.qr_code),
                            ),
                            const SizedBox(height: 20),

                            // Room Name (Editable)
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _roomController,
                                    decoration: const InputDecoration(
                                      labelText: "Room Location",
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.room),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<DevicesBloc>().add(
                                      UpdateDeviceRequested(
                                        id: selectedDevice.id,
                                        newRoomName: _roomController.text,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.save),
                                  label: const Text("Update"),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),

                            // Actions Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _showAddDialog(context),
                                  icon: const Icon(Icons.add),
                                  label: const Text("Add New Device"),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Confirm Delete
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Delete Device?"),
                                        content: Text(
                                          "Are you sure you want to remove ${selectedDevice.roomName}?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () {
                                              context.read<DevicesBloc>().add(
                                                RemoveDeviceRequested(
                                                  selectedDevice.id,
                                                ),
                                              );
                                              Navigator.pop(ctx);
                                            },
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.withOpacity(
                                      0.1,
                                    ),
                                    foregroundColor: Colors.red,
                                  ),
                                  icon: const Icon(Icons.delete),
                                  label: const Text("Remove Device"),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
