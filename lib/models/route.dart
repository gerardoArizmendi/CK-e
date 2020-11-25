import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RoutePath {
  final double speed;
  final LatLng coordinate;
  final DateTime time;

  RoutePath({this.speed, this.coordinate, this.time});
}
