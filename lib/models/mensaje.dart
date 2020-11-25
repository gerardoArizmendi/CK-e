import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mensaje {
  final String idDest;
  final String idAutr;
  final String msj;

  Mensaje({
    this.idDest,
    this.idAutr,
    this.msj,
  });
}
