import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final int? id_user;
  final String? username;
  final String? email;
  final String? password;
  final Session? session;
  UserModel({
    this.username,
    this.email,
    this.password,
    this.id_user,
    this.session,
  });
}
