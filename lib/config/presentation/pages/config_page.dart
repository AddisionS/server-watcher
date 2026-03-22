import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../data/datasources/config_data_source.dart';
import '../../data/repositories/config_repository_impl.dart';
import '../../domain/usecases/get_thresholds_usecase.dart';
import '../../domain/usecases/get_contacts_usecase.dart';
import '../../domain/usecases/update_config_usecase.dart';

import '../bloc/config_bloc.dart';
import '../bloc/config_event.dart';
import '../bloc/config_state.dart';
import '../../../home/presentation/widgets/main_layout.dart';

class ConfigPage extends StatefulWidget {
  final UserEntity user;
  const ConfigPage({super.key, required this.user});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  late final ConfigRepositoryImpl _configRepo;

  @override
  void initState() {
    super.initState();

    // Safe to context.read here — widget is fully mounted
    final httpClient = context.read<http.Client>();
    final sharedPrefs = context.read<SharedPreferences>();

    _configRepo = ConfigRepositoryImpl(
      remoteDataSource: ConfigRemoteDataSourceImpl(
        client: httpClient,
        sharedPreferences: sharedPrefs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConfigBloc(
        getThresholdsUseCase: GetThresholdsUseCase(_configRepo),
        updateThresholdsUseCase: UpdateThresholdsUseCase(_configRepo),
        getContactsUseCase: GetContactsUseCase(_configRepo),
        addEmailUseCase: AddEmailUseCase(_configRepo),
        removeEmailUseCase: RemoveEmailUseCase(_configRepo),
        addPhoneUseCase: AddPhoneUseCase(_configRepo),
        removePhoneUseCase: RemovePhoneUseCase(_configRepo),
      )..add(ConfigInitialLoad()),
      child: MainLayout(
        user: widget.user,
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

// _ConfigForm and _ConfigFormState are UNCHANGED — paste your existing code below this line
class _ConfigForm extends StatefulWidget {
  const _ConfigForm();

  @override
  State<_ConfigForm> createState() => _ConfigFormState();
}

class _ConfigFormState extends State<_ConfigForm> {
  final _subTempCtrl = TextEditingController();
  final _thresTempCtrl = TextEditingController();
  final _subHumCtrl = TextEditingController();
  final _thresHumCtrl = TextEditingController();
  final _emailInputCtrl = TextEditingController();
  final _phoneInputCtrl = TextEditingController();

  final _thresholdFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _subTempCtrl.dispose();
    _thresTempCtrl.dispose();
    _subHumCtrl.dispose();
    _thresHumCtrl.dispose();
    _emailInputCtrl.dispose();
    _phoneInputCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email (e.g. user@domain.com)';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digitsOnly = value.trim().replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length != 10) {
      return 'Enter exactly 10 digits (e.g. 9876543210)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final theme = Theme.of(context);

    return BlocListener<ConfigBloc, ConfigState>(
      listener: (context, state) {
        if (state is ConfigLoaded) {
          _subTempCtrl.text = state.thresholds.subTemp.toString();
          _thresTempCtrl.text = state.thresholds.thresTemp.toString();
          _subHumCtrl.text = state.thresholds.subHum.toString();
          _thresHumCtrl.text = state.thresholds.thresHum.toString();
        }
        if (state is ConfigSuccess) {
          _emailInputCtrl.clear();
          _phoneInputCtrl.clear();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    const Text(
                      "Temperature Range (°C)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberField(
                            _subTempCtrl,
                            "Sub-Threshold",
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildNumberField(_thresTempCtrl, "Threshold"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Humidity Range (%)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberField(
                            _subHumCtrl,
                            "Sub-Threshold",
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildNumberField(_thresHumCtrl, "Threshold"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
                            final subT = double.parse(_subTempCtrl.text);
                            final maxT = double.parse(_thresTempCtrl.text);
                            final subH = double.parse(_subHumCtrl.text);
                            final maxH = double.parse(_thresHumCtrl.text);

                            if (subT >= maxT) {
                              _showError(
                                context,
                                "Temperature Sub-Threshold must be less than Threshold",
                              );
                              return;
                            }
                            if (subH >= maxH) {
                              _showError(
                                context,
                                "Humidity Sub-Threshold must be less than Threshold",
                              );
                              return;
                            }
                            context.read<ConfigBloc>().add(
                              SubmitThresholds(
                                subTemp: subT,
                                thresTemp: maxT,
                                subHum: subH,
                                thresHum: maxH,
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

          const Text(
            "Alert Contacts",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Manage who receives SMS and Email alerts. Add or remove individually.",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),

          BlocBuilder<ConfigBloc, ConfigState>(
            builder: (context, state) {
              final isLoading = state is ConfigLoading;
              final contacts = (state is ConfigLoaded) ? state.contacts : null;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: LinearProgressIndicator(),
                        ),

                      // EMAIL SUB-SECTION
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Email Addresses",
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (contacts != null && contacts.emails.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: contacts.emails.map((email) {
                            return InputChip(
                              label: Text(email),
                              onDeleted: isLoading
                                  ? null
                                  : () => context.read<ConfigBloc>().add(
                                      RemoveEmailEvent(email),
                                    ),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              side: BorderSide(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            );
                          }).toList(),
                        )
                      else if (!isLoading)
                        Text(
                          "No email addresses configured yet.",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                      const SizedBox(height: 16),

                      Form(
                        key: _emailFormKey,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _emailInputCtrl,
                                enabled: !isLoading,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                decoration: const InputDecoration(
                                  labelText: "New Email Address",
                                  hintText: "emailaddress@domain.com",
                                  hintStyle: TextStyle(color: Colors.white38),
                                  prefixIcon: Icon(Icons.alternate_email),
                                ),
                                validator: _validateEmail,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: ElevatedButton.icon(
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.add),
                                label: const Text("Add"),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 24,
                                  ),
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_emailFormKey.currentState!
                                            .validate()) {
                                          context.read<ConfigBloc>().add(
                                            AddEmailEvent(
                                              _emailInputCtrl.text.trim(),
                                            ),
                                          );
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 24),

                      // PHONE SUB-SECTION
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 20,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Phone Numbers",
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (contacts != null && contacts.phoneNumbers.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: contacts.phoneNumbers.map((phone) {
                            return InputChip(
                              label: Text(phone),
                              onDeleted: isLoading
                                  ? null
                                  : () => context.read<ConfigBloc>().add(
                                      RemovePhoneEvent(phone),
                                    ),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              backgroundColor: theme.colorScheme.secondary
                                  .withValues(alpha: 0.1),
                              side: BorderSide(
                                color: theme.colorScheme.secondary.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            );
                          }).toList(),
                        )
                      else if (!isLoading)
                        Text(
                          "No phone numbers configured yet.",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                      const SizedBox(height: 16),

                      Form(
                        key: _phoneFormKey,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _phoneInputCtrl,
                                enabled: !isLoading,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                decoration: const InputDecoration(
                                  labelText: "New Phone Number",
                                  hintText:
                                      "1234567890 (10 digits without +91)",
                                  hintStyle: TextStyle(color: Colors.white38),
                                  prefixIcon: Icon(Icons.phone_iphone),
                                ),
                                validator: _validatePhone,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: ElevatedButton.icon(
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.add),
                                label: const Text("Add"),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 24,
                                  ),
                                  backgroundColor: theme.colorScheme.secondary,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_phoneFormKey.currentState!
                                            .validate()) {
                                          context.read<ConfigBloc>().add(
                                            AddPhoneEvent(
                                              _phoneInputCtrl.text.trim(),
                                            ),
                                          );
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildNumberField(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (double.tryParse(value) == null) return 'Invalid Number';
        return null;
      },
    );
  }
}
