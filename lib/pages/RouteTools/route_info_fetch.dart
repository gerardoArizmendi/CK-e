import 'package:blue/pages/RouteTools/route_info.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:blue/models/main_scope.dart';

class RouteInfoFetch extends StatelessWidget {
  final LatLng locDataStart;
  final LatLng locDataEnd;

  RouteInfoFetch(this.locDataStart, this.locDataEnd);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Informacion de la Ruta",
            style: GoogleFonts.roboto(color: Colors.white),
          ),
          backgroundColor: Colors.lightBlue[900],
        ),
        body: ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
          Widget content = Center(
              child: Container(child: Text("No hay informacion de la Ruta")));
          if (model.getRoutePath.length > 0 && !model.isLoading) {
            content =
                new RouteInfo(model.getRoutePath, locDataStart, locDataEnd);
          } else if (model.isLoading) {
            content = Center(child: CircularProgressIndicator());
          }

          return content;
        }));
  }
}
