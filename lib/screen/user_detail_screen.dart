import 'package:basic_widget/bloc/status.dart';
import 'package:basic_widget/bloc/user_bloc.dart';
import 'package:basic_widget/bloc/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state.status == Status.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == Status.failure) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Failed to load user',
              ),
            );
          }

          final user = state.selectedUser;

          if (user == null) {
            return const Center(
              child: Text('User not found'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(user.email),
                const SizedBox(height: 8),
                Text('User ID: ${user.id}'),
              ],
            ),
          );
        },
      ),
    );
  }
}