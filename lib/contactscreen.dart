import 'package:flutter/material.dart';
import 'package:flutter_contact/contact.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contact/contacts.dart';
import 'dart:async';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key key}) : super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<Contact> listContacts = [];

  @override
  void initState() {
    super.initState();
    //listContacts = [];
    readContacts();
  }

  readContacts() async {
    final PermissionStatus permissionStatus =
        await _getPermission().then((value) {
      print('permission asked');
      return value;
    });
    if (permissionStatus == PermissionStatus.granted) {
      await Contacts.streamContacts(bufferSize: 50).forEach((contact) {
        print("${contact.displayName}");
        setState(() {
          listContacts.add(contact);
        });
      });
    }

    // You can manually adjust the buffer size
    //return  Contacts.streamContacts(bufferSize: 10);
  }

  //Check contacts permission
  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ?? PermissionStatus.granted;
    } else {
      return permission;
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('CONTACTS'),
      ),
      body: Container(
        width: width,
        height: height,
        child: listContacts.length > 0
            ? ListView.builder(
                itemCount: listContacts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title:
                        Text(listContacts[index].displayName ?? 'not fetched'),
                    subtitle: Text((listContacts[index].phones.length > 0)
                        ? "${listContacts[index].phones.get(0)}"
                        : "No contact"),
                  );
                })
            : Center(
                child: Text('no contacts'),
              ),
      ),
    );
  }
}
