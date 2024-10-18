import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(ContactFetcherApp());
}

class ContactFetcherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Fetcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ContactFetcherHomePage(),
    );
  }
}

class ContactFetcherHomePage extends StatefulWidget {
  @override
  _ContactFetcherHomePageState createState() => _ContactFetcherHomePageState();
}

class _ContactFetcherHomePageState extends State<ContactFetcherHomePage> {
  List<Contact> _contacts = [];
  bool _isLoading = false;

  Future<void> _fetchContacts() async {
    setState(() {
      _isLoading = true;
    });

    var status = await Permission.contacts.request();

    if (status.isGranted) {
      List<Contact> contacts = (await ContactsService.getContacts()).toList();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle permission denied
      print('Permission denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _fetchContacts,
              child: Text('Load Contacts'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : _contacts.isEmpty
                ? Text('No contacts loaded')
                : Expanded(
              child: ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return ListTile(
                    title: Text(contact.displayName ?? ''),
                    subtitle: Text(contact.phones?.isNotEmpty == true
                        ? contact.phones!.first.value ?? ''
                        : 'No phone number'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
