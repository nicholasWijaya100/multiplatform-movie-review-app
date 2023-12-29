import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import 'login.dart';
import 'my_movies.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  void _logout(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _showEditDialog(BuildContext context, UserProvider userProvider) {
    String newName = "", newEmail = "", oldPassword = "", newPassword = "", confirmPassword = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Account"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  initialValue: userProvider.getCurrentUserEmail(),
                  decoration: const InputDecoration(hintText: "Email"),
                  readOnly: true, // Makes the field read-only
                ),
                TextFormField(
                  initialValue: userProvider.getCurrentUserName(),
                  decoration: const InputDecoration(hintText: "Name"),
                  onChanged: (value) => newName = value,
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(hintText: "Old Password"),
                  onChanged: (value) => oldPassword = value,
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(hintText: "New Password"),
                  onChanged: (value) => newPassword = value,
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(hintText: "Confirm Password"),
                  onChanged: (value) => confirmPassword = value,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                final emailRegex = RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b');
                if(newName == ""){
                  newName = userProvider.getCurrentUserName()!;
                }
                if(newEmail == ""){
                  newEmail = userProvider.getCurrentUserEmail()!;
                }
                if(oldPassword == "" || newPassword == "" || confirmPassword == ""){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fill all field!')),
                  );
                }else if (!emailRegex.hasMatch(newEmail)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid email address.')),
                  );
                }else if(newPassword.length < 6){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('NewPassword must be at least 6 characters long.')),
                  );
                }else if(oldPassword == userProvider.getCurrentPassword()){
                  if(newPassword == confirmPassword){
                    userProvider.updateUser(newName, newPassword);
                    Navigator.of(context).pop();
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password and Confirm Password do not match.')),
                    );
                  }
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Wrong password!')),
                  );
                }
              },
            ),
          ],
        );
      },
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
                    _showEditDialog(context, userProvider);
                  },
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('My Movies'),
            leading: const Icon(Icons.movie),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyMovie()),
              );
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
