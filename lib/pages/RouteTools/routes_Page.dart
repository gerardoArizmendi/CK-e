import 'package:blue/pages/RouteTools/route_info_fetch.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:blue/models/main_scope.dart';
import 'package:blue/models/user.dart';
import 'package:blue/models/ride.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:blue/helpers_POD/location_helper.dart';

// Route Cards
class RoutesPage extends StatelessWidget {
  final User perfil;

  RoutesPage(this.perfil);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return BuildRoutes(model, perfil);
      },
    );
  }
}

class BuildRoutes extends StatefulWidget {
  final MainModel model;
  final User perfil;

  BuildRoutes(this.model, this.perfil);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BuildRoutesState();
  }
}

class _BuildRoutesState extends State<BuildRoutes> {
  List<Ride> routesComplete = [];
  @override
  void initState() {
    // TODO: implement initState
    if (widget.perfil.id != widget.model.authUser.id) {
      routesComplete = widget.model.getRoutes;
    } else {
      routesComplete = widget.model.getUserRoutes;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget routes = Container();
    if (widget.model.isLoading) {
      routes = CircularProgressIndicator();
    } else {
      routes = ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          String tiempoDesde = '1997';
          var date = routesComplete[index].timeStart.toDate();
          final dateNow = new DateTime.now();
          final dateTimeSincePost = dateNow.difference(date).inMinutes;
          if (dateTimeSincePost < 60) {
            tiempoDesde = (dateTimeSincePost.toString()) + ' min';
          } else if (dateTimeSincePost <= 1440) {
            tiempoDesde =
                ((dateTimeSincePost / 60).round().toString()) + ' hrs';
          } else if (dateTimeSincePost <= 10080) {
            tiempoDesde =
                ((dateTimeSincePost / 1440).round().toString()) + ' dias';
          } else {
            tiempoDesde = DateFormat('kk:mm - dd-MM-yyyy').format(date);
          }

          String tiempoRuta = 'mucho';
          var dateEnd = routesComplete[index].timeEnd.toDate();
          var timeRoute = dateEnd.difference(date).inMinutes;
          tiempoRuta = timeRoute.toString() + " minutos";

          final locDataStart = routesComplete[index].start;
          final locDataEnd = routesComplete[index].end;
          String _previewImageUrl = LocationHelper.generateLocationImage(
            latitude: locDataStart.latitude,
            longitude: locDataStart.longitude,
            latEnd: locDataEnd.latitude,
            longEnd: locDataEnd.longitude,
          );

          return Padding(
              padding: EdgeInsets.all(10),
              child: Card(
                elevation: 30,
                child: Column(children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(widget.perfil.imageUrl),
                              radius: 25),
                        ),
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(widget.perfil.nombre,
                                  style: GoogleFonts.rubik(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500)),
                              Text(tiempoDesde,
                                  style: GoogleFonts.rubik(fontSize: 15)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                            child: Card(
                          color: Colors.blueGrey[50],
                          margin: EdgeInsets.all(5),
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Velocidad media: ",
                                    style: GoogleFonts.rubik(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey[850])),
                                SizedBox(height: 10),
                                Text(
                                    routesComplete[index].speed.toString() +
                                        " Km/h",
                                    style: GoogleFonts.rubik(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400)),
                              ],
                            ),
                          ),
                        )),
                        Expanded(
                          child: Card(
                              color: Colors.blueGrey[50],
                              margin: EdgeInsets.all(5),
                              child: Padding(
                                padding: EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("Distancia: ",
                                        style: GoogleFonts.rubik(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey[850])),
                                    SizedBox(height: 10),
                                    Text(
                                        routesComplete[index]
                                                .distance
                                                .toString() +
                                            "Km",
                                        style: GoogleFonts.rubik(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400))
                                  ],
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.model.fetchRoutePath(
                          routesComplete[index].timeStart.toDate().toString(),
                          widget.perfil.id);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return RouteInfoFetch(locDataStart, locDataEnd);
                      }));
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Image.network(
                        _previewImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(2),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              child: Card(
                            color: Colors.blueGrey[50],
                            margin: EdgeInsets.all(5),
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("Tiempo: ",
                                      style: GoogleFonts.rubik(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey[850])),
                                  SizedBox(height: 10),
                                  Text(tiempoRuta,
                                      style: GoogleFonts.rubik(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400)),
                                ],
                              ),
                            ),
                          )),
                          Expanded(
                            flex: 2,
                            child: Card(
                                color: Colors.blueGrey[50],
                                margin: EdgeInsets.all(5),
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Temperatura & Humedad: ",
                                          style: GoogleFonts.rubik(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey[850])),
                                      SizedBox(height: 10),
                                      Text(
                                          routesComplete[index]
                                                  .temperature
                                                  .toString() +
                                              "ªC               " +
                                              routesComplete[index]
                                                  .humedad
                                                  .toString(),
                                          style: GoogleFonts.rubik(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400))
                                    ],
                                  ),
                                )),
                          ),
                        ],
                      )),
                ]),
              ));
        },
        itemCount: routesComplete.length,
      );
    }
    return routes;
  }
}
