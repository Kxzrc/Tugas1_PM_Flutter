import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/password.dart';

void main() {
  runApp(PasswordManagerApp());
}

class PasswordManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      home: PasswordListScreen(),
    ); // MaterialApp
  }
}

class PasswordListScreen extends StatefulWidget {
  @override
  _PasswordListScreenState createState() => _PasswordListScreenState();
}

class _PasswordListScreenState extends State<PasswordListScreen> {
  final dbHelper = DatabaseHelper();
  List<Password> passwords = [];
  
  @override
  void initState() {
    super.initState();
    _refreshPasswordList();
  }

  void _refreshPasswordList() async {
    final data = await dbHelper.getPasswords();
    setState(() {
      passwords = data;
    });
  }

  void _addOrUpdatePassword({Password? password}) {
    final titleController = TextEditingController(text: password?.title);
    final usernameController = TextEditingController(text: password?.username);
    final passwordController = TextEditingController(text: password?.password);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(password == null ? 'Tambah Password' : 'Edit Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController, 
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: usernameController, 
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController, 
              decoration: InputDecoration(labelText: 'Password'),
            ),
          ],
        ), // Column
        actions: [
          ElevatedButton(
            onPressed: () {
              final newPassword = Password(
                id: password?.id,
                title: titleController.text,
                username: usernameController.text,
                password: passwordController.text,
              ); // Password
              if (password == null) {
                dbHelper.insertPassword(newPassword);
              } else {
                dbHelper.updatePassword(newPassword);
              }
              _refreshPasswordList();
              Navigator.of(context).pop();
            },
            child: Text(password == null ? 'Tambah' : 'Simpan'),
          ), // ElevatedButton
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal'),
          ), // TextButton
        ],
      ), // AlertDialog
    );
  }

  void _deletePassword(int id) {
    dbHelper.deletePassword(id);
    _refreshPasswordList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Password Manager"),
      ), // AppBar
      body: ListView.builder(
        itemCount: passwords.length,
        itemBuilder: (context, index) {
          final password = passwords[index];
          return ListTile(
            title: Text(password.title),
            subtitle: Text(password.username),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _addOrUpdatePassword(password: password),
                ), // IconButton
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deletePassword(password.id!),
                ), // IconButton
              ],
            ), // Row
          ); // ListTile
        },
      ), // ListView.builder
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdatePassword(),
        child: Icon(Icons.add),
      ), // FloatingActionButton
    ); // Scaffold
  }
}