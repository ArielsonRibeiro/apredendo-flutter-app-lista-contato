import 'dart:io';

import 'package:contato_list/helpers/ContactHelper.dart';
import 'package:contato_list/pages/edit_contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderAz, orderZa }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelp _helper = ContactHelp();
  List<Contact> _contacts = List();
  Contact _contactRemoved;
  final GlobalKey<ScaffoldState> keyScaf = new GlobalKey();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: keyScaf,
      appBar: AppBar(
        title: Text(
          "Contatos",
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 90, 0, 112),
        actions: [
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem(
                child: Text("Ordenar A-Z"),
                value: OrderOptions.orderAz,
              ),
              const PopupMenuItem(
                child: Text("Ordenar Z-A"),
                value: OrderOptions.orderZa,
              ),
            ],
            onSelected: _ordenar,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _startEditContactPage(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 90, 0, 112),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: _contacts.length,
        itemBuilder: _getCard,
      ),
    );
  }

  void _getAllContacts() {
    _helper.getAllContact().then((value) {
      setState(() {
        _contacts = value;
      });
    });
  }

  Widget _getCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        _showSheetBottom(context, index);
        //_startEditContactPage(context, contact: _contacts[index]);
      },
      child: Card(
        child: Row(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    width: 3,
                    color: Color.fromARGB(255, 90, 0, 112),
                    style: BorderStyle.solid),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: _contacts[index].img != null
                      ? FileImage(
                          File(_contacts[index].img),
                        )
                      : AssetImage("img/do-utilizador.png"),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _contacts[index].name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _contacts[index].email,
                    style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                  ),
                  Text(
                    _contacts[index].phone,
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _showSheetBottom(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: FlatButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await launch("tel:${_contacts[index].phone}");
                    },
                    child: Text(
                      "Ligar",
                      style: TextStyle(
                          color: Color.fromARGB(255, 90, 0, 112), fontSize: 20),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _startEditContactPage(context, contact: _contacts[index]);
                    },
                    child: Text(
                      "Editar",
                      style: TextStyle(
                          color: Color.fromARGB(255, 90, 0, 112), fontSize: 20),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: FlatButton(
                    onPressed: () {
                      _contactRemoved = _contacts[index];
                      setState(() {
                        _helper.deleteContact(_contacts[index]);
                        _contacts.removeAt(index);
                      });
                      Navigator.pop(context);

                      final SnackBar snackbar = SnackBar(
                        duration: Duration(seconds: 3),
                        content: Text(
                            "O contato ${_contactRemoved.name} foi removido!!"),
                        action: SnackBarAction(
                            label: "Desfazer",
                            onPressed: () {
                              _helper.save(_contactRemoved);
                              _getAllContacts();
                            }),
                      );
                      keyScaf.currentState.showSnackBar(snackbar);
                    },
                    child: Text(
                      "Excluir",
                      style: TextStyle(
                        color: Color.fromARGB(255, 90, 0, 112),
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _startEditContactPage(BuildContext context, {Contact contact}) async {
    Contact con = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditContactPage(
          contact: contact,
        ),
      ),
    );
    if (con != null) {
      if (contact != null) {
        _helper.updateContact(con);
      } else {
        _helper.save(con);
      }
      _getAllContacts();
    }
  }

  _ordenar(OrderOptions op) {
    switch (op) {
      case OrderOptions.orderAz:
        _contacts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case OrderOptions.orderZa:
        _contacts.sort((a, b) => b.name.compareTo(a.name));
        break;
    }
    setState(() {});
  }
}
