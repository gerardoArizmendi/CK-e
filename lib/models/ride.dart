import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:blue/models/route.dart';

class Ride {
  double speed;
  double topSpeed;
  double distance;
  double temperature;
  double humedad;
  List<RoutePath> route;
  final LatLng start;
  final LatLng end;
  final Timestamp timeStart;
  final Timestamp timeEnd;

  Ride(
      {this.speed,
      this.topSpeed,
      this.distance,
      this.temperature,
      this.humedad,
      this.route,
      this.start,
      this.end,
      this.timeStart,
      this.timeEnd});
}
