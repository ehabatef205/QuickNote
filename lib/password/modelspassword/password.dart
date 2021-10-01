import 'dart:typed_data';

class Password {
  int _id;
  String _password;

  Password(this._password);

  Password.withId(this._id, this._password);

  String get password => _password;

  int get id => _id;

  set password(String value) {
    if (value.length <= 255) {
      _password = value;
    }
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map["password"] = this._password;
    return map;
  }

  Password.getMap(Map<String, dynamic> map) {
    this._id = map["id"];
    this._password = map["password"];
  }
}
