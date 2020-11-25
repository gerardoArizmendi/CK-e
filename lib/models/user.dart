import 'package:flutter/material.dart';

class User {
  final String id; //ID    [Auth]
  final bool auth; //Status [Main]
  final String email; //Email [Auth]
  final String token; //Token [Main]
  final String nombre;
  final String bio;
  final String username;
  final String direccion;
  final String imageUrl;
  final String imagePath;
  bool imFollowing;
  bool emergTag;

  User(
      {@required this.id,
      this.auth,
      @required this.email,
      this.token,
      this.nombre,
      this.bio,
      this.username,
      @required this.direccion,
      this.imageUrl,
      this.imagePath,
      this.imFollowing,
      this.emergTag});
}
