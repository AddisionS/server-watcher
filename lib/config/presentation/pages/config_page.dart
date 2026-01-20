import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Domain & Data Imports
import '../../../auth/domain/entities/user_entity.dart';
import '../../data/datasources/config_mock_data_source.dart';
import '../../data/repositories/config_repository_impl.dart';
import '../../domain/usecases/update_config_usecase.dart';

// Bloc Imports
import '../bloc/config_bloc.dart';
import '../bloc/config_event.dart';
import '../bloc/config_state.dart';

// Layout Import
import '../../../home/presentation/widgets/main_layout.dart'; // <--- IMPORT THIS

class ConfigPage extends StatelessWidget {
  final UserEntity user;

  const ConfigPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // 1. Dependency Injection
    final dataSource = ConfigMockDataSourceImpl();
    final repo = ConfigRepositoryImpl(remoteDataSource: dataSource);

    return BlocProvider(
      create: (context) => ConfigBloc(
        updateThresholdsUseCase: UpdateThresholdsUseCase(repo),
        updateContactsUseCase: UpdateContactsUseCase(repo),
      ),

      // 2. USE MAIN LAYOUT (Cleaner Structure)
      child: MainLayout(
        user: user,
        title: "System Configuration",
        body: BlocListener<ConfigBloc, ConfigState>(
          listener: (context, state) {
            if (state is ConfigSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is ConfigFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: _ConfigForm(),
          ),
        ),
      ),
    );
  }
}

class _ConfigForm extends StatefulWidget {
  const _ConfigForm();

  @override
  State<_ConfigForm> createState() => _ConfigFormState();
}

class _ConfigFormState extends State<_ConfigForm> {
  // Controllers
  final _subTempCtrl = TextEditingController();
  final _thresTempCtrl = TextEditingController();
  final _subHumCtrl = TextEditingController();
  final _thresHumCtrl = TextEditingController();

  final _emailsCtrl = TextEditingController();
  final _phonesCtrl = TextEditingController();

  final _thresholdFormKey = GlobalKey<FormState>();
  final _contactFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _subTempCtrl.dispose();
    _thresTempCtrl.dispose();
    _subHumCtrl.dispose();
    _thresHumCtrl.dispose();
    _emailsCtrl.dispose();
    _phonesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We check width locally just to size buttons
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- SECTION 1: THRESHOLDS ---
        const Text(
          "Sensor Thresholds",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Set the Sub-threshold and threshold values for the server room.",
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 20),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _thresholdFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Temperature Row
                  const Text(
                    "Temperature Range (°C)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(_subTempCtrl, "Sub-Threshold"),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildNumberField(_thresTempCtrl, "Threshold"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Humidity Row
                  const Text(
                    "Humidity Range (%)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(_subHumCtrl, "Sub-Threshold"),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildNumberField(_thresHumCtrl, "Threshold"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Submit Thresholds Button
                  SizedBox(
                    width: isDesktop ? 200 : double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Save Thresholds"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (_thresholdFormKey.currentState!.validate()) {
                          context.read<ConfigBloc>().add(
                            SubmitThresholds(
                              subTemp: double.parse(_subTempCtrl.text),
                              thresTemp: double.parse(_thresTempCtrl.text),
                              subHum: double.parse(_subHumCtrl.text),
                              thresHum: double.parse(_thresHumCtrl.text),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),
        const Divider(),
        const SizedBox(height: 40),

        // --- SECTION 2: ALERTS ---
        const Text(
          "Alert Contacts",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Configure who receives SMS and Email alerts.",
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 20),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _contactFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emails
                  TextFormField(
                    controller: _emailsCtrl,
                    decoration: const InputDecoration(
                      labelText: "Email Addresses",
                      hintText: "admin@corp.com, manager@corp.com",
                      helperText: "Separate multiple emails with a comma (,)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Enter at least one email" : null,
                  ),
                  const SizedBox(height: 20),

                  // Phone Numbers
                  TextFormField(
                    controller: _phonesCtrl,
                    decoration: const InputDecoration(
                      labelText: "Phone Numbers",
                      hintText: "+1234567890, +0987654321",
                      helperText: "Separate multiple numbers with a comma (,)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Enter at least one number" : null,
                  ),
                  const SizedBox(height: 24),

                  // Submit Contacts Button
                  SizedBox(
                    width: isDesktop ? 200 : double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.notifications_active),
                      label: const Text("Save Contacts"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (_contactFormKey.currentState!.validate()) {
                          context.read<ConfigBloc>().add(
                            SubmitContacts(
                              emailsString: _emailsCtrl.text,
                              phonesString: _phonesCtrl.text,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper builder for numeric inputs
  Widget _buildNumberField(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        // fillColor is handled by the main Theme now
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (double.tryParse(value) == null) return 'Invalid Number';
        return null;
      },
    );
  }
}
