import 'package:flutter/material.dart';

import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:location/location.dart';

import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserMapa extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _MapaState();
  }
}

class _MapaState extends State<UserMapa> {
  GoogleMapController _controller;

  StreamSubscription _locationSubscription;
  Location _location = Location();
  Marker marker;
  Circle circle;

  void getLocation() async {
    try {
      Uint8List avatar = await getMarker();
      var location = await _location.getLocation();
      updateMarkerandCircle(location, avatar);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription = _location.onLocationChanged.listen((location) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  target: LatLng(location.latitude, location.longitude),
                  bearing: 192.8334901395799,
                  tilt: 0,
                  zoom: 16.5)));
          updateMarkerandCircle(location, avatar);
        }
      });
    } on PlatformException catch (e) {
      print(e.code);
    }
  }

  static final CameraPosition _posicionInicial = CameraPosition(
      target: LatLng(23.63296265331129, -99.55832357078792), tilt: 0, zoom: 16);

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load('assets/bicicleMono.png');
    return byteData.buffer.asUint8List();
  }

  void updateMarkerandCircle(LocationData newLocation, Uint8List imageAvatar) {
    LatLng latlng = LatLng(newLocation.latitude, newLocation.longitude);
    this.setState(() {
      marker = Marker(
        markerId: MarkerId("Me"),
        position: latlng,
        rotation: newLocation.heading,
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        icon: BitmapDescriptor.fromBytes(imageAvatar),
      );
      circle = Circle(
          circleId: CircleId("Bicicle"),
          radius: newLocation.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _posicionInicial,
        markers: Set.of((marker != null ? [marker] : [])),
        circles: Set.of((circle != null ? [circle] : [])),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.location_on),
          onPressed: () {
            setState(() {
              getLocation();
            });
          }),
    );
  }
}
