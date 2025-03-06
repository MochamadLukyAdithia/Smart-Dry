import 'dart:ffi';

class UserModel {
  final Int? id;
  final String? username;
  final String? email;
  final String? password;
  UserModel({
    this.username,
    this.email,
    this.password,
    this.id,
  });
}
