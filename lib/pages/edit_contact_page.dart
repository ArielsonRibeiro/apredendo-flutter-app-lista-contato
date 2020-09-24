import 'dart:io';

import 'package:contato_list/helpers/ContactHelper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditContactPage extends StatefulWidget {
  Contact contact;
  @override
  _EditContactPageState createState() => _EditContactPageState();
  EditContactPage({this.contact});
}

class _EditContactPageState extends State<EditContactPage> {
  Contact _editingContact;
  TextEditingController _editingControllerName = TextEditingController();
  TextEditingController _editingControllerEmail = TextEditingController();
  TextEditingController _editingControllerPhone = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _editingContact = Contact.fromMap(widget.contact.toMap());
      _editingControllerName.text = _editingContact.name;
      _editingControllerEmail.text = _editingContact.email;
      _editingControllerPhone.text = _editingContact.phone;
    } else
      _editingContact = Contact();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _editingContact.name == null || _editingContact.name.isEmpty
                ? "Novo Contato"
                : _editingContact.name,
          ),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 90, 0, 112),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pop(context, _editingContact);
            },
            child: Icon(Icons.save),
            backgroundColor: Color.fromARGB(255, 90, 0, 112)),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    ImagePicker()
                        .getImage(source: ImageSource.camera)
                        .then((value) {
                      if (value.path != null) {
                        setState(() {
                          _editing = true;
                          _editingContact.img = value.path;
                        });
                      }
                    });
                  },
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 3,
                          color: Color.fromARGB(255, 90, 0, 112),
                          style: BorderStyle.solid),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: _editingContact.img != null
                            ? FileImage(
                                File(_editingContact.img),
                              )
                            : AssetImage("img/do-utilizador.png"),
                      ),
                    ),
                  ),
                ),
                _getTextField(
                  controller: _editingControllerName,
                  onChanged: (value) {
                    _editingContact.name = value;
                    _editing = true;
                  },
                  hintText: "Nome",
                ),
                _getTextField(
                    controller: _editingControllerEmail,
                    onChanged: (value) {
                      _editingContact.email = value;
                      _editing = true;
                    },
                    hintText: "E-mail",
                    keyboardType: TextInputType.emailAddress),
                _getTextField(
                    controller: _editingControllerPhone,
                    onChanged: (value) {
                      _editingContact.phone = value;
                      _editing = true;
                    },
                    hintText: "Phone",
                    keyboardType: TextInputType.phone),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getTextField(
      {TextEditingController controller,
      void Function(String value) onChanged,
      String hintText,
      TextInputType keyboardType}) {
    return Padding(
      padding: EdgeInsets.only(top: 15),
      child: TextField(
        keyboardType: keyboardType,
        onChanged: onChanged,
        controller: controller,
        style: TextStyle(
            fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Color.fromARGB(10, 90, 0, 112),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Color.fromARGB(255, 102, 0, 102),
            ),
          ),
        ),
        cursorColor: Color.fromARGB(255, 102, 0, 102),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_editing) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Deseja Sair? "),
            content:
                Text("Foram realizada alterações, deseja sair sem salvar? "),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancelar"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("Sim"),
              ),
            ],
          );
        },
      );
      return Future.value(false);
    }
    return Future.value(true);
  }
}
