import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../home/presentation/widgets/main_layout.dart';
import '../../domain/entities/user_item_entity.dart';
import '../../data/datasources/users_datasource.dart';
import '../../data/repositories/users_repository_impl.dart';
import '../../domain/usecases/user_usecases.dart';
import '../bloc/users_bloc.dart';
import '../bloc/users_event.dart';
import '../bloc/users_state.dart';

class UserManagementPage extends StatelessWidget {
  final UserEntity currentUser;

  const UserManagementPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    // 1. Dependency Injection (Local to this page)
    final httpClient = context.read<http.Client>();
    final remoteDataSource = UsersRemoteDataSourceImpl(
      client: httpClient,
      sharedPreferences: context.read(),
    );
    final repository = UsersRepositoryImpl(remoteDataSource);

    return BlocProvider(
      create: (_) => UsersBloc(
        getUsersUseCase: GetUsersUseCase(repository),
        createUserUseCase: CreateUserUseCase(repository),
        deleteUserUseCase: DeleteUserUseCase(repository),
      )..add(LoadUsers()),
      child: MainLayout(
        user: currentUser,
        title: "User Management",
        body: _UserManagementContent(currentUser: currentUser),
      ),
    );
  }
}

class _UserManagementContent extends StatelessWidget {
  final UserEntity currentUser;

  const _UserManagementContent({required this.currentUser});

  void _showAddUserDialog(
    BuildContext context,
    List<UserItemEntity> existingUsers,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AddUserDialog(
        existingUsers: existingUsers,
        onSubmit: (username, password, role) {
          context.read<UsersBloc>().add(
            CreateUserRequested(
              username: username,
              password: password,
              role: role,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<UsersBloc, UsersState>(
      listener: (context, state) {
        if (state is UserOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is UsersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is UsersLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is UsersLoaded) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER & ADD BUTTON ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "System Users",
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddUserDialog(context, state.users),
                      icon: const Icon(Icons.person_add),
                      label: const Text("Add User"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.secondary, // Electric Blue
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- USER LIST ---
                Expanded(
                  child: Card(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.users.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final user = state.users[index];

                        // Protection Logic: Hide delete for current user and serverGOD
                        final bool canDelete =
                            user.username != currentUser.username &&
                            user.username != 'serverGOD';

                        // Role Badge Color
                        Color roleColor = Colors.grey;
                        if (user.role == 'admin')
                          roleColor = theme.colorScheme.error; // Red
                        else if (user.role == 'developer')
                          roleColor = theme.colorScheme.tertiary; // Purple
                        else if (user.role == 'user')
                          roleColor = theme.colorScheme.primary; // Green

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            child: Icon(Icons.person, color: Colors.grey),
                          ),
                          title: Text(
                            user.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              user.role.toUpperCase(),
                              style: TextStyle(
                                color: roleColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          trailing: canDelete
                              ? IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: theme.colorScheme.error,
                                  ),
                                  tooltip: "Delete User",
                                  onPressed: () {
                                    // Delete Confirmation
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Delete User?"),
                                        content: Text(
                                          "Are you sure you want to permanently delete '${user.username}'?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  theme.colorScheme.error,
                                            ),
                                            onPressed: () {
                                              context.read<UsersBloc>().add(
                                                DeleteUserRequested(
                                                  user.username,
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
                                )
                              : const SizedBox.shrink(), // Hidden if protected
                        );
                      },
                    ),
                  ),
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

// --- ADD USER DIALOG WIDGET (Handles Form State & Validation) ---
class _AddUserDialog extends StatefulWidget {
  final List<UserItemEntity> existingUsers;
  final Function(String username, String password, String role) onSubmit;

  const _AddUserDialog({required this.existingUsers, required this.onSubmit});

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _selectedRole = 'user'; // Default role
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create New User"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Username Field
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  labelText: "Username",
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return "Username is required";
                  if (value.length >= 50) return "Must be under 50 characters";

                  // Uniqueness Check
                  final exists = widget.existingUsers.any(
                    (u) =>
                        u.username.toLowerCase() == value.trim().toLowerCase(),
                  );
                  if (exists) return "Username already exists";

                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. Password Field
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Password is required";
                  if (value.length < 8)
                    return "Password must be at least 8 characters";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. Role Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: "Role",
                  prefixIcon: Icon(Icons.shield),
                ),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text("User")),
                  DropdownMenuItem(
                    value: 'developer',
                    child: Text("Developer"),
                  ),
                  DropdownMenuItem(value: 'admin', child: Text("Admin")),
                ],
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit(
                _usernameCtrl.text.trim(),
                _passwordCtrl.text,
                _selectedRole,
              );
              Navigator.pop(context);
            }
          },
          child: const Text(
            "Create User",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
