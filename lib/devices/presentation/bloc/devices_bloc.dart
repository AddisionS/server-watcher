import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/device_usecases.dart';
import 'package:file_saver/file_saver.dart';
import 'devices_event.dart';
import 'devices_state.dart';

class DevicesBloc extends Bloc<DevicesEvent, DevicesState> {
  final GetDevicesUseCase getDevices;
  final AddDeviceUseCase addDevice;
  final UpdateDeviceUseCase updateDevice;
  final RemoveDeviceUseCase removeDevice;
  final RefreshDeviceStatusesUseCase refreshDeviceStatuses;

  Timer? _statusTimer;

  DevicesBloc({
    required this.getDevices,
    required this.addDevice,
    required this.updateDevice,
    required this.removeDevice,
    required this.refreshDeviceStatuses,
  }) : super(DevicesLoading()) {
    // 1. Load List
    on<LoadDevices>((event, emit) async {
      emit(DevicesLoading());
      try {
        final devices = await getDevices();
        emit(
          DevicesLoaded(
            devices: devices,
            selectedDeviceId: devices.isNotEmpty ? devices.first.id : null,
          ),
        );
        // Immediately fetch live statuses after loading devices
        add(RefreshDeviceStatuses());
        // Start periodic status polling every 30 seconds
        _statusTimer?.cancel();
        _statusTimer = Timer.periodic(
          const Duration(seconds: 30),
          (_) => add(RefreshDeviceStatuses()),
        );
      } catch (e) {
        print('❌ [DevicesBloc] LoadDevices failed: $e');
        emit(DevicesError("Failed to load devices: $e"));
      }
    });

    // 6. Refresh statuses only (no loading flash)
    on<RefreshDeviceStatuses>((event, emit) async {
      if (state is! DevicesLoaded) return;
      final current = state as DevicesLoaded;
      final ids = current.devices.map((d) => d.id).toList();
      if (ids.isEmpty) return;
      try {
        final statuses = await refreshDeviceStatuses(ids);
        emit(current.copyWith(deviceStatuses: statuses));
      } catch (_) {
        // Silently ignore — stale statuses are better than a crash
      }
    });

    // 2. Select Device (UI Highlight)
    on<SelectDevice>((event, emit) {
      if (state is DevicesLoaded) {
        emit((state as DevicesLoaded).copyWith(selectedDeviceId: event.deviceId));
      }
    });

    // 3. Add Device
    on<AddDeviceRequested>((event, emit) async {
      emit(DevicesLoading());
      try {
        // A. Call API -> Get File Data
        final firmware = await addDevice(event.roomName);

        // B. Trigger Download
        await FileSaver.instance.saveFile(
          name: firmware.fileName,
          bytes: firmware.fileBytes,
          mimeType: MimeType.text,
        );

        emit(DevicesOperationSuccess("Device added & Firmware downloaded!"));

        // C. Refresh List to show the new device
        add(LoadDevices());
      } catch (e) {
        emit(DevicesError("Failed to add device: $e"));
      }
    });

    // 4. Update Device
    on<UpdateDeviceRequested>((event, emit) async {
      emit(DevicesLoading());
      try {
        await updateDevice(event.id, event.newRoomName);
        emit(DevicesOperationSuccess("Device updated"));
        add(LoadDevices()); // Reload
      } catch (e) {
        emit(DevicesError("Failed to update"));
      }
    });

    // 5. Remove Device
    on<RemoveDeviceRequested>((event, emit) async {
      emit(DevicesLoading());
      try {
        await removeDevice(event.id);
        emit(DevicesOperationSuccess("Device removed"));
        add(LoadDevices()); // Reload
      } catch (e) {
        emit(DevicesError("Failed to delete"));
      }
    });
  }

  @override
  Future<void> close() {
    _statusTimer?.cancel();
    return super.close();
  }
}
