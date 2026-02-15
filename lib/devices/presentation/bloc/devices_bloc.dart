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

  DevicesBloc({
    required this.getDevices,
    required this.addDevice,
    required this.updateDevice,
    required this.removeDevice,
  }) : super(DevicesLoading()) {
    // 1. Load List
    on<LoadDevices>((event, emit) async {
      emit(DevicesLoading());
      try {
        final devices = await getDevices();
        // Default to first device if none selected, or keep selection if possible
        emit(
          DevicesLoaded(
            devices: devices,
            selectedDeviceId: devices.isNotEmpty ? devices.first.id : null,
          ),
        );
      } catch (e) {
        emit(DevicesError("Failed to load devices"));
      }
    });

    // 2. Select Device (UI Highlight)
    on<SelectDevice>((event, emit) {
      if (state is DevicesLoaded) {
        final current = state as DevicesLoaded;
        emit(
          DevicesLoaded(
            devices: current.devices,
            selectedDeviceId: event.deviceId,
          ),
        );
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
}
