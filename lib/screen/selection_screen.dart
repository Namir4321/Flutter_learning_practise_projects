import 'package:flutter/material.dart';

class SelectRoleScreen extends StatelessWidget {
  const SelectRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Role'),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Admin'),
            onTap: () {
              Navigator.pop(context, 'Admin');
            },
          ),
          ListTile(
            title: const Text('User'),
            onTap: () {
              Navigator.pop(context, 'User');
            },
          ),
        ],
      ),
    );
  }
}