import 'package:basic_widget/data/shared_prefs.dart';
import 'package:flutter/material.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final SharedPrefs sharedPrefs = SharedPrefs();
  bool? isLoggedIn;

  final nameController = TextEditingController();

  String? savedName;

  @override
  void initState() {
    super.initState();
    _loadName();
    _loadLoginState();
  }

  Future<void> _loadName() async {
    final name = await sharedPrefs.getName();

    if (!mounted) return;

    setState(() {
      savedName = name;
    });
  }

  Future<void> _saveName() async {
    final name = nameController.text.trim();

    if (name.isEmpty) return;

    await sharedPrefs.saveName(name);

    if (!mounted) return;

    setState(() {
      savedName = name;
    });

    nameController.clear();
  }

  Future<void> _login() async {
    await sharedPrefs.saveLoggedIn(true);

    if (!mounted) return;

    setState(() {
      isLoggedIn = true;
    });
  }

  Future<void> _logout() async {
    await sharedPrefs.saveLoggedIn(false);

    if (!mounted) return;

    setState(() {
      isLoggedIn = false;
    });
  }

  Future<void> _loadLoginState() async {
    final value = await sharedPrefs.getLoggedIn();
    if (!mounted) return;

    setState(() {
      isLoggedIn = value;
    });
  }

  Future<void> _removeName() async {
    await sharedPrefs.removeName();

    if (!mounted) return;

    setState(() {
      savedName = null;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Storage')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _saveName,
              child: const Text('Save Name'),
            ),

            const SizedBox(height: 20),

            Text(
              savedName ?? 'No name saved',
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _removeName,
              child: const Text('Remove Name'),
            ),

            ElevatedButton(onPressed: _login, child: const Text('Login')),

            ElevatedButton(onPressed: _logout, child: const Text('Logout')),

            Text(
              isLoggedIn == true ? 'Logged In' : 'Logged Out',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
