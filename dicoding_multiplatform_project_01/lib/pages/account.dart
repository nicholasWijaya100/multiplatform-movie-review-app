import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import 'login.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  void _logout(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    final userEmail = userProvider.getCurrentUserEmail();
    final userName = userProvider.getCurrentUserName();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.deepOrange,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/placeholder_profile.jpg'),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        userEmail!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    // Coming Soon
                  },
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('My Movies'),
            leading: const Icon(Icons.movie),
            onTap: () {
              // Coming Soon
            },
          ),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            onTap: () {
              // Coming Soon
            },
          ),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
