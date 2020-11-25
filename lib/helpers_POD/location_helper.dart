import 'dart:core';

import 'package:blue/models/route.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const GOOGLE_API_KEY = 'AIzaSyCf7-4pP5DxnZ57eL_B81qVuf9snDDK6K8';

class LocationHelper {
  static String generateLocationImage(
      {double latitude, double longitude, double latEnd, double longEnd}) {
    var zoom = 15;
    print((latitude - latEnd).abs());
    print((longitude - longEnd).abs());
    if ((latitude - latEnd).abs() > .085 ||
        (longitude - longEnd).abs() > .085) {
      zoom = 6;
    } else if ((latitude - latEnd).abs() > .065 ||
        (longitude - longEnd).abs() > .065) {
      zoom = 11;
    } else if ((latitude - latEnd).abs() > .006 ||
        (longitude - longEnd).abs() > .006) {
      zoom = 15;
    } else if ((latitude - latEnd).abs() > .02 ||
        (longitude - longEnd).abs() > .06) {
      zoom = 15;
    }
    return 'https://maps.googleapis.com/maps/api/staticmap?center=&$latitude,$longitude,$latEnd,$longEnd&zoom=$zoom&size=600x300&maptype=roadmap&markers=color:green%7Clabel:A%7C$latitude,$longitude&markers=color:red%7Clabel:B%7C$latEnd,$longEnd&key=$GOOGLE_API_KEY';
  }
}

class LocationPathGenerator {
  static String generateLocationImage(
      {double latitude,
      double longitude,
      double latEnd,
      double longEnd,
      List<RoutePath> path}) {
    var zoom = 15;
    print((latitude - latEnd).abs());
    print((longitude - longEnd).abs());
    if ((latitude - latEnd).abs() > .085 ||
        (longitude - longEnd).abs() > .085) {
      zoom = 6;
      print(zoom);
    } else if ((latitude - latEnd).abs() > .065 ||
        (longitude - longEnd).abs() > .065) {
      zoom = 11;
      print(zoom);
    } else if ((latitude - latEnd).abs() > .006 ||
        (longitude - longEnd).abs() > .006) {
      zoom = 16;
      print(zoom);
    } else if ((latitude - latEnd).abs() > .02 ||
        (longitude - longEnd).abs() > .06) {
      zoom = 16;
      print(zoom);
    }
    String trama = "";
    for (int i = 0; i < path.length; i++) {
      LatLng latlngTemp = path[i].coordinate;
      trama = trama + "|";
      trama = trama + latlngTemp.latitude.toString();
      trama = trama + ",";
      trama = trama + latlngTemp.longitude.toString();
    }
    print(trama);
    return 'https://maps.googleapis.com/maps/api/staticmap?center=&$latitude,$longitude,$latEnd,$longEnd&zoom=$zoom&size=600x300&maptype=roadmap&markers=color:green%7Clabel:A%7C$latitude,$longitude&markers=color:red%7Clabel:B%7C$latEnd,$longEnd&key=$GOOGLE_API_KEY&path=color:0xff0000ff|weight:3$trama&sensor=false';
  }
}

class LocationRoute {
  static String generateLocationImage(
      {double latStart, double longStart, double latEnd, double longEnd}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=&$latStart,$longStart&zoom=5&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$latStart,$longStart&key=$GOOGLE_API_KEY';
  }
}

class AccidentGenerator {
  static String generateLocationImage({double latitude, double longitude}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=&$latitude,$longitude&zoom=10&size=600x600&maptype=roadmap&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=$GOOGLE_API_KEY';
  }
}
