# Server Watcher — Architecture Overview 📐

This document maps the main application layers and shows where responsibilities live.

---

## High-level flow

**Presentation (Blocs)** → **Domain (UseCases)** → **Data (Repositories)** → **DataSources (Mock / Remote)**

- Blocs handle UI state and events.
- UseCases contain single-purpose business rules and call repositories.
- Repositories abstract data operations and delegate to data sources.
- DataSources implement how the data is fetched/stored (mock or API).

---

## Architecture diagram

![Architecture diagram](./architecture.svg)

---

## Key mappings (quick reference)

| Feature | Bloc | UseCases | Repository | DataSource |
|---|---:|---|---|---|
| Auth | `AuthBloc` | `LoginUseCase`, `LogoutUseCase`, `CheckAuthStatusUseCase` | `AuthRepositoryImpl` | `AuthDataSourceImpl` |
| Devices | `DevicesBloc` | `GetDevicesUseCase`, `AddDeviceUseCase`, `UpdateDeviceUseCase`, `RemoveDeviceUseCase` | `DevicesRepositoryImpl` | `DevicesMockDataSourceImpl` (or remote) |
| Home (Dashboard) | `HomeBloc` | `GetRoomsUseCase`, `GetSensorStreamUseCase` | `HomeRepositoryImpl` | `HomeMockDataSourceImpl` |
| Config | (consumed by UI) | `GetThresholdsUseCase` / update usecases | `ConfigRepositoryImpl` | `ConfigMockDataSourceImpl` (or remote) |
| Alerts | `AlertsBloc` (if present) | — | `AlertsRepositoryImpl` | `AlertsMockDataSourceImpl` |
| Export | `ExportBloc` | `DownloadReportUseCase` | `ExportRepositoryImpl` | `ExportMockDataSourceImpl` |
| History | `HistoryBloc` (if present) | — | `HistoryRepositoryImpl` | `HistoryMockDataSourceImpl` |

---

## Notes & best practices 🔧

- For shared state (e.g., device list used by Dashboard and Device Manager), register the repository and bloc at app-level (`main.dart`) using `RepositoryProvider` and `MultiBlocProvider`.
- For isolated page-scoped state, provide the bloc locally inside the page with `BlocProvider(create: ...)`.
- When navigating and you want to reuse an existing bloc, use `BlocProvider.value(value: existingBloc)`.
- To switch from mock to remote: implement the remote data source, then change the repository instantiation in `main.dart` or the page provider to use it.

---
