import 'package:basic_widget/bloc/auth_bloc.dart';
import 'package:basic_widget/bloc/auth_event.dart';
import 'package:basic_widget/bloc/status.dart';
import 'package:basic_widget/bloc/user_bloc.dart';
import 'package:basic_widget/bloc/user_state.dart';
import 'package:basic_widget/model/user.dart';
import 'package:basic_widget/screen/selection_screen.dart';
import 'package:basic_widget/validators/user_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  // Create user form
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  String? selectedRole;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ---------------- CREATE USER ----------------

  void _createUser() {
    // Run all validators
    if (_formKey.currentState!.validate()) {
      context.read<UserBloc>().add(
        UserCreateRequest(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
        ),
      );

      // Clear form after validation passes
      nameController.clear();
      emailController.clear();
    }
  }

  Future<void> _selectRole() async {
    final role = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const SelectRoleScreen()),
    );

    if (role != null && mounted) {
      setState(() {
        selectedRole = role;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      context.read<UserBloc>().add(UserLoadMoreRequest());
    }
  }
  // ---------------- EDIT USER ----------------

  void _showEditUserDialog(User user) {
    final userBloc = context.read<UserBloc>();
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(user: user, userBloc: userBloc),
    );
  }

  // ---------------- BUILD ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: BlocConsumer<UserBloc, UserState>(
        // ---------------- LISTENER ----------------
        listener: (context, state) {
          if (state.status == Status.createFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to create user'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },

        // ---------------- BUILDER ----------------
        builder: (context, state) {
          final isCreating = state.status == Status.creating;

          return Padding(
            padding: const EdgeInsets.all(16.0),

            child: Column(
              children: [
                // ---------------- CREATE FORM ----------------
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name
                      TextFormField(
                        controller: nameController,
                        validator: validateName,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Email
                      TextFormField(
                        controller: emailController,
                        validator: validateEmail,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ---------------- CREATE BUTTON ----------------
                ElevatedButton(
                  onPressed: isCreating ? null : _createUser,
                  child: isCreating
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create User'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/about');
                  },
                  child: const Text("About"),
                ),
                ElevatedButton(
                  onPressed: _selectRole,
                  child: Text(selectedRole ?? 'Select Role'),
                ),
                const Divider(height: 32),

                // ---------------- USER LIST ----------------
                // Expanded(child: _buildUserList(state)),
                SizedBox(height: 300, child: _buildUserList(state)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------- USER LIST ----------------

  Widget _buildUserList(UserState state) {
    // Loading users
    if (state.status == Status.loading || state.status == Status.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    // GET failure
    if (state.status == Status.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage ?? 'Failed to load users'),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () {
                context.read<UserBloc>().add(UserLoadRequest());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // No users
    if (state.users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    // Users
    return ListView.builder(
      itemCount: state.users.length + (state.isLoadingMore ? 1 : 0),
      controller: scrollController,

      itemBuilder: (context, index) {
        if (index >= state.users.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final user = state.users[index];

        return ListTile(
          title: Text(user.name),

          subtitle: Text(user.email),
          onTap: () {
            Navigator.pushNamed(context, '/user-details', arguments: user);
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // EDIT
              IconButton(
                onPressed: () {
                  _showEditUserDialog(user);
                },
                icon: const Icon(Icons.edit),
              ),

              // DELETE
              IconButton(
                onPressed: () {
                  context.read<UserBloc>().add(UserDeleteRequest(id: user.id));
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EditUserDialog extends StatefulWidget {
  final User user;
  final UserBloc userBloc;

  const EditUserDialog({super.key, required this.user, required this.userBloc});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late TextEditingController editNameController;
  late TextEditingController editEmailController;
  final editFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    editNameController = TextEditingController(text: widget.user.name);
    editEmailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    editNameController.dispose();
    editEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit User'),
      content: Form(
        key: editFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: editNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: editEmailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Enter a valid email';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (editFormKey.currentState?.validate() ?? false) {
              widget.userBloc.add(
                UserUpdateRequest(
                  id: widget.user.id,
                  name: editNameController.text.trim(),
                  email: editEmailController.text.trim(),
                ),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
