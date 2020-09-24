import 'package:sqflite/sqflite.dart';

const String contactTableName = "ContactTable";
const String idColumn = "idColumn";
const String nameColumn = "nameColumn";
const String emailColumn = "emailColumn";
const String phoneColumn = "phoneColumn";
const String imgColumn = "imgColumn";

class ContactHelp {
  static final ContactHelp _instance = ContactHelp._internal();

  factory ContactHelp() => _instance;

  ContactHelp._internal();

  Database _db;

  Future<Database> get db async {
    if (_db == null) _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    final String dbPath = await getDatabasesPath();
    final path = dbPath + "dbContact.db";

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE $contactTableName($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT,"
          "$emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT);");
    });
  }

  Future<Contact> save(Contact contact) async {
    Database database = await db;
    contact.id = await database.insert(contactTableName, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database database = await db;
    List<Map> map = await database.query(contactTableName,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    return map.length > 0 ? Contact.fromMap(map.first) : null;
  }

  Future<int> deleteContact(Contact contact) async {
    Database database = await db;
    return await database.delete(contactTableName,
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database database = await db;
    return await database.update(contactTableName, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }
  Future<List<Contact>> getAllContact() async{
    Database database = await db;
    List<Map> lista = await database.rawQuery("SELECT * FROM $contactTableName;");
    List<Contact> contacts = List();
    for(Map c in lista){
      contacts.add(Contact.fromMap(c));
    }
    return contacts;
  }

  Future<int> getNumber() async{
    Database database = await db;
    return Sqflite.firstIntValue(await database.rawQuery("SELECT COUNT(*) FROM $contactTableName"));
  }
  Future close() async {
    Database database = await db;
    database.close();
  }

}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();
  Contact.create(this.name, this.email, this.phone, this.img);

  Contact.fromMap(Map map) {
    this.id = map[idColumn];
    this.name = map[nameColumn];
    this.email = map[emailColumn];
    this.phone = map[phoneColumn];
    this.img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: this.name,
      emailColumn: this.email,
      phoneColumn: this.phone,
      imgColumn: this.img
    };
    if (this.id != null) map[idColumn] = this.id;
    return map;
  }

  @override
  String toString() {
    return "Contact(id : $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
