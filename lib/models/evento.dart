import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Evento {
  String titulo;
  final String descripcion;
  final LatLng start;
  final LatLng end;
  String users;
  DateTime timeStart;
  DateTime timeEnd;
  String imageUrl;
  final String userId;

  Evento(
      {this.titulo,
      this.descripcion,
      this.start,
      this.end,
      this.users,
      this.timeStart,
      this.timeEnd,
      this.imageUrl,
      this.userId});
}
