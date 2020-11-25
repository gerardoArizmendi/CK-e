import 'dart:ffi';
import 'dart:typed_data';

import 'package:blue/models/main_scope.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoped_model/scoped_model.dart';

//Not sure
class LivePanel extends StatefulWidget {
  final String id;

  LivePanel(this.id);

  @override
  State<StatefulWidget> createState() {
    return _RoutePanelState();
  }
}

class _RoutePanelState extends State<LivePanel> {
  GoogleMapController _controller;

  StreamSubscription _locationSubscription;
  Location _location = Location();
  double speed = 0;
  Marker marker;
  Circle circle;
  LatLng ubicaionActual;
  var location;
  double heading;
  double velocidad;
  double distancia;
  double temperatura;
  double cadencia;
  double humedad;

  @override
  void initState() {
    if (mounted) {
      getLocation();
    }
    super.initState();
  }

  void getLocation() async {
    try {
      Uint8List avatar = await getMarker();
      Firestore.instance
          .collection('/Perfiles')
          .document(widget.id)
          .collection('Data')
          .document('Live')
          .snapshots()
          .listen((event) {
        Map<String, dynamic> liveInfo = event.data;
        print(liveInfo['latitude']);
        print(liveInfo['longitude']);
        print(liveInfo['speed']);
        if (mounted) {
          setState(() {
            heading = liveInfo['heading'];
            location = LatLng(liveInfo['latitude'], liveInfo['longitude']);
            velocidad = liveInfo['speed'] != null ? liveInfo['speed'] : 0;
            distancia =
                liveInfo['distancia'] != null ? liveInfo['distancia'] : 0;
            // temperatura =
            //     liveInfo['temperatura'] != null ? liveInfo['temperatura'] : 0;
            // humedad = liveInfo['humedad'] != null ? liveInfo['humedad'] : 0;
          });
        }
        _controller.animateCamera(CameraUpdate.newCameraPosition(
            new CameraPosition(
                target: LatLng(location.latitude, location.longitude),
                bearing: 192.8334901395799,
                tilt: 0,
                zoom: 16.5)));
        updateMarkerandCircle(location, heading, avatar);
      });

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      // _locationSubscription = _location.onLocationChanged.listen((location) {
      //   if (_controller != null) {
      //     _controller.animateCamera(CameraUpdate.newCameraPosition(
      //         new CameraPosition(
      //             target: LatLng(location.latitude, location.longitude),
      //             bearing: 192.8334901395799,
      //             tilt: 0,
      //             zoom: 16.5)));
      //     updateMarkerandCircle(location, avatar);
      //   }
      // });
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

  void updateMarkerandCircle(
      LatLng newLocation, double heading, Uint8List imageAvatar) {
    LatLng latlng = LatLng(newLocation.latitude, newLocation.longitude);
    if (mounted) {
      this.setState(() {
        marker = Marker(
          markerId: MarkerId("Me"),
          position: latlng,
          rotation: heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageAvatar),
        );
        circle = Circle(
            circleId: CircleId("Bicicle"),
            // radius: newLocation.accuracy,
            radius: 2,
            zIndex: 1,
            strokeColor: Colors.blue,
            center: latlng,
            fillColor: Colors.blue.withAlpha(70));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async {
      _locationSubscription.cancel();
      var location = await _location.getLocation();
      LatLng latlng = LatLng(location.latitude, location.longitude);
      // widget.model.endRoute(latlng);
      return Future.value(false);
    }, child: ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
          appBar: AppBar(title: Text("Mapa de Ruta")),
          body: Column(children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: Card(
                  margin: EdgeInsets.all(5),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Velocidad: ",
                            style: GoogleFonts.rubik(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[850])),
                        SizedBox(height: 10),
                        Text(speed.toString() + " Km/h",
                            style: GoogleFonts.rubik(
                                fontSize: 20, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                )),
                Expanded(
                  child: Card(
                      margin: EdgeInsets.all(5),
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Temperatura: ",
                                style: GoogleFonts.rubik(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[850])),
                            SizedBox(height: 10),
                            Text(temperatura.toString(),
                                style: GoogleFonts.rubik(
                                    fontSize: 20, fontWeight: FontWeight.w400))
                          ],
                        ),
                      )),
                ),
              ],
            ),
            Expanded(
              flex: 5,
              child: GoogleMap(
                initialCameraPosition: _posicionInicial,
                markers: Set.of((marker != null ? [marker] : [])),
                circles: Set.of((circle != null ? [circle] : [])),
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
              ),
            )
          ]),
        );
      },
    ));
  }
}
