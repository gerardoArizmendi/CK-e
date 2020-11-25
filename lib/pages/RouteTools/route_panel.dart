import 'dart:ffi';
import 'dart:typed_data';
import 'dart:math' show cos, sqrt, asin;
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:blue/models/main_scope.dart';
import 'package:blue/widgets_blue/blue_panels.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

import 'dart:async';

import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_blue/flutter_blue.dart';

//PANEL When in ROUTE
//Map with live location

class RoutePanel extends StatefulWidget {
  final MainModel model;

  RoutePanel(this.model);

  @override
  State<StatefulWidget> createState() {
    return _RoutePanelState();
  }
}

class _RoutePanelState extends State<RoutePanel> {
  GoogleMapController _controller;

  StreamSubscription _locationSubscription;
  Location _location = Location();
  Marker marker;
  Circle circle;
  LatLng ubicacionPasada;

  double avgSpeed = 0; //Average Speed
  double topSpeed = 0; //Top Speed
  double speed = 0; //Actual Speed
  double lastSpeed = 0; //Last speed to capture averga
  int count = 0;

  bool alerta = false;

  double acceleration = 0; //(Vf - V) / Dt
  double distance = 0;
  double meters = 0;

  DateTime time = DateTime.now();
  DateTime startTime = DateTime.now();
  double timeDif = 0;

  //Widgets flags
  bool speedGraph = false;
  List<SpeedValue> _data = [];

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
      var location = await _location.getLocation();
      setState(() {
        print("Setting Last Location");
        ubicacionPasada = LatLng(location.latitude, location.longitude);
      });
      updateMarkerandCircle(location, avatar);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription = _location.onLocationChanged.listen((location) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  target: LatLng(location.latitude, location.longitude),
                  bearing: location.heading,
                  tilt: 0,
                  zoom: 16)));
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

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void updateMarkerandCircle(LocationData newLocation, Uint8List imageAvatar) {
    LatLng latlng = LatLng(newLocation.latitude, newLocation.longitude);
    lastSpeed = speed;
    speed = newLocation.speed;
    acceleration =
        (speed - lastSpeed) / (DateTime.now().difference(time).inSeconds);
    print(
        "TIME DIF: " + (DateTime.now().difference(time).inSeconds.toString()));
    time = DateTime.now();
    count++;
    avgSpeed = (avgSpeed + speed);
    topSpeed = newLocation.speed > topSpeed ? newLocation.speed : topSpeed;

    double distanceTemp = calculateDistance(ubicacionPasada.latitude,
        ubicacionPasada.longitude, latlng.latitude, latlng.longitude);
    distance = distanceTemp + distance;
    ubicacionPasada = latlng;
    if (mounted) {
      this.setState(() {
        if (distance - meters > 16.0 || distance < 16) {
          meters = distance;
        }
        widget.model.updateRouteData(
            latlng,
            newLocation.speed,
            newLocation.heading,
            distance,
            acceleration,
            DateTime.now(),
            meters);
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
  }

  Widget _modulesTiles(MainModel model) {
    return Expanded(
      flex: 2,
      child: ListView.builder(
          itemCount: model.blueDevices.length,
          itemBuilder: (BuildContext contest, int index) {
            print("BLUE DEVICES: " + model.blueDevices.length.toString());
            return StreamBuilder<List<BluetoothService>>(
                stream: model.blueDevices[index].services,
                initialData: [],
                builder: (c, snapshot) => Column(
                        children: snapshot.data
                            .where((element) =>
                                element.uuid.toString() ==
                                    "0000ffe0-0000-1000-8000-00805f9b34fb" ||
                                element.uuid.toString() ==
                                    "0000fee3-0000-1000-8000-00805f9b34fb")
                            .toList()
                            .map((s) {
                      return ModuleTile(
                        device: model.blueDevices[index],
                        service: s,
                        characteristicTiles: s.characteristics
                            .map(
                              (c) => CharacteristicTile(
                                characteristic: c,
                                onReadPressed: () => c.read(),
                                onWritePressed: () => c.write([13, 24]),
                                onNotificationPressed: () =>
                                    c.setNotifyValue(!c.isNotifying),
                                name: model.blueDevices[index].name,
                              ),
                            )
                            .toList(),
                      );
                    }).toList()));
          }),
    );
  }

  Widget _graph(double speed) {
    SpeedValue temp = SpeedValue(DateTime.now(), speed);
    _data.add(temp);
    if (_data.length > 10) {
      _data.removeRange(0, 9);
    }
    return new charts.TimeSeriesChart([
      charts.Series<SpeedValue, DateTime>(
        id: 'Values',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (SpeedValue values, _) => values.time,
        measureFn: (SpeedValue values, _) => values.value,
        data: _data,
      )
    ],
        animate: false,
        primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec:
              charts.BasicNumericTickProviderSpec(zeroBound: false),
          renderSpec: charts.NoneRenderSpec(),
        ),
        domainAxis: new charts.DateTimeAxisSpec(
            renderSpec: new charts.NoneRenderSpec()));
  }

  Widget _floatingAction(BuildContext context) {
    return Container(
        height: 100,
        width: 100,
        child: FittedBox(
            child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          child: GestureDetector(
            child: Icon(Icons.stop, color: Colors.white),
            onLongPress: () {
              widget.model.sendAlert();
              setState(() {
                alerta = true;
              });
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Has enviado una alerta de accidente"),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () {
                              widget.model.cancelAlert();
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancelar")),
                        FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Okay"))
                      ],
                    );
                  });
            },
            onTap: () async {
              print("On TAP");
              var location = await _location.getLocation();
              LatLng latlng = LatLng(location.latitude, location.longitude);
              avgSpeed = avgSpeed / count;
              DateTime endTime = DateTime.now();
              String totalTime =
                  endTime.difference(startTime).inMinutes.toString();
              widget.model.endRoute(latlng, avgSpeed, topSpeed, distance);
              _locationSubscription.cancel();
              print("On dialog");
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Se ha finalizado la Ruta"),
                      content: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Colors.blueGrey[300]),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 30),
                            Text("Velocidad Promedio: " +
                                avgSpeed.toStringAsFixed(2) +
                                " km/h"),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Distancia Recorrida: " +
                                distance.toStringAsFixed(2) +
                                " km"),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Tiempo Total: " + totalTime + " minutos"),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        alerta
                            ? FlatButton(
                                onPressed: () {
                                  widget.model.cancelAlert();
                                },
                                child: Text("Cancelar"))
                            : Text("Buen trabajo"),
                        FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pop(context);
                            },
                            child: Text("Okay"))
                      ],
                    );
                  });
              print("On Pop");
            },
          ),
        )));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async {
      _locationSubscription.cancel();
      var location = await _location.getLocation();
      LatLng latlng = LatLng(location.latitude, location.longitude);
      avgSpeed = avgSpeed / count;
      widget.model.endRoute(latlng, avgSpeed, topSpeed, distance);
      return Future.value(false);
    }, child: ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
            floatingActionButton: _floatingAction(context),
            // appBar: AppBar(title: Text("Mapa de Ruta")),
            body: Container(
              color: Colors.grey[200],
              child: Column(children: [
                SizedBox(height: 20),
                Center(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              child: GestureDetector(
                                  onTap: (() {
                                    setState(() {
                                      speedGraph = !speedGraph;
                                    });
                                  }),
                                  child: Container(
                                    height: 130,
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey,
                                              blurRadius: 3.0,
                                              spreadRadius: 2.0,
                                              offset: Offset(2.0, 2.0))
                                        ],
                                        color: Colors.blueGrey[100],
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0))),
                                    margin: EdgeInsets.all(5),
                                    child: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: speedGraph
                                          ? _graph(speed * 3.6)
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                // Text("Velocidad: ",
                                                //     style: GoogleFonts.rubik(
                                                //         fontSize: 18,
                                                //         fontWeight:
                                                //             FontWeight.w500,
                                                //         color:
                                                //             Colors.grey[750])),
                                                SizedBox(height: 7),
                                                Row(children: [
                                                  Text(
                                                      (speed * 3.6)
                                                          .toStringAsFixed(2),
                                                      style: GoogleFonts.rubik(
                                                          color: Colors
                                                              .lightBlue[900],
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  Text(" Km/h",
                                                      style: GoogleFonts.rubik(
                                                          color: Colors
                                                              .lightBlue[900],
                                                          fontSize: 19,
                                                          fontWeight:
                                                              FontWeight.w600))
                                                ]),
                                                SizedBox(height: 3),
                                                Divider(
                                                  thickness: 5,
                                                ),
                                                Text(
                                                    acceleration
                                                            .toStringAsFixed(
                                                                2) +
                                                        " m/s^2",
                                                    style: GoogleFonts.rubik(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              ],
                                            ),
                                    ),
                                  ))),
                          Expanded(
                            child: Container(
                                height: 130,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[200],
                                  shape: BoxShape.rectangle,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 3.0,
                                        spreadRadius: 2.0,
                                        offset: Offset(2.0, 2.0))
                                  ],
                                ),
                                margin: EdgeInsets.all(5),
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(height: 13),
                                      Text(distance.toStringAsFixed(2) + " Km",
                                          style: GoogleFonts.rubik(
                                              color: Colors.lightBlue[900],
                                              fontSize: 25,
                                              fontWeight: FontWeight.w600))
                                    ],
                                  ),
                                )),
                          ),
                        ],
                      )),
                ),
                model.blueDevices.length == 0
                    ? Center(
                        child: Column(children: [
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.deepOrange[200],
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: 30, right: 30, top: 5, bottom: 5),
                                child: Text("Sin modulos conectados",
                                    style: GoogleFonts.rubik(fontSize: 20)))),
                      ]))
                    : _modulesTiles(model),
                Expanded(
                  flex: 5,
                  child: GoogleMap(
                    zoomControlsEnabled: false,
                    initialCameraPosition: _posicionInicial,
                    markers: Set.of((marker != null ? [marker] : [])),
                    circles: Set.of((circle != null ? [circle] : [])),
                    onMapCreated: (GoogleMapController controller) {
                      _controller = controller;
                    },
                  ),
                )
              ]),
            ));
      },
    ));
  }
}

class SpeedValue {
  final DateTime time;
  final double value;

  SpeedValue(this.time, this.value);
}
