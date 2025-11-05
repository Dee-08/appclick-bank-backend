import 'package:flint_dart/model.dart';
import 'package:flint_dart/schema.dart';

class User extends Model<User> {
  @override
  String? id; // 🚀 Framework automatically manages: id, created_at, updated_at

  // Define your custom fields here
  String? name;
  String? email;
  String? password;
  int? phoneNumber;
  String? profilePicUrl;
  DateTime? createdAt;

  @override
  Table get table => Table(
        name: 'users',
        columns: [
          // 💡 Only define custom fields - id/created_at/updated_at are auto-added
          Column(
            name: 'name',
            type: ColumnType.string,
          ),
          Column(name: 'email', type: ColumnType.string, isUnique: true),
          Column(name: 'password', type: ColumnType.string),
        ],
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'profilePicUrl': profilePicUrl,
        "created_at": createdAt
      };

  @override
  User fromMap(Map<String, dynamic> map) {
    return User()
      ..id = map['id']
      ..name = map['name']
      ..email = map['email']
      ..password = map['password']
      ..createdAt = map["created_at"];
  }
}
