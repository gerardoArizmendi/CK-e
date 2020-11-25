import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:blue/models/main_scope.dart';
import 'package:blue/models/ride.dart';

class TraveledPanels extends StatefulWidget {
  final MainModel model;
  TraveledPanels(this.model);
  @override
  State<StatefulWidget> createState() {
    return _TraveledPanelState();
  }
}

class _TraveledPanelState extends State<TraveledPanels> {
  double speed = 0;
  double distance = 0;
  List<MonthData> monthSpeed = [];
  List<MonthData> monthDistance = [];

  @override
  void initState() {
    if (widget.model.getRoutes != null) {
      calculateTraveled(widget.model.getUserRoutes);
    }
    super.initState();
  }

  void calculateTraveled(List<Ride> routes) {
    if (routes != null) {
      double _totalAvSpeed = 0;
      double _totalDistance = 0;
      int count = 0;

      print("Routes length: " + routes.length.toString());

      for (var i = 0; i < routes.length; i++) {
        int month = routes[i].timeStart.toDate().month;
        int monthTemp =
            routes[i + 1 >= routes.length ? i : i + 1].timeStart.toDate().month;
        _totalAvSpeed += routes[i].speed;
        _totalDistance += routes[i].distance;
        count++;

        if (month != monthTemp || i == routes.length - 1) {
          setState(() {
            print("Inside Set State");
            monthSpeed.add(MonthData(month, _totalAvSpeed / count));
            monthDistance.add(MonthData(month, _totalDistance));
          });
          _totalAvSpeed = 0;
          _totalDistance = 0;
        }
      }
      // print("Monthly Speed: " + monthSpeed[0].value.toString());
      // print("Monthly Distance: " + monthDistance[0].value.toString());
    }
  }

  Widget content() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: 90,
            width: 160,
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
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            margin: EdgeInsets.all(5),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Velocidad promedio: ",
                      style: GoogleFonts.rubik(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[750])),
                  SizedBox(height: 7),
                  Text(
                      monthSpeed.length > 0
                          ? (monthSpeed[monthSpeed.length - 1].value)
                                  .toStringAsFixed(2) +
                              " Km/h"
                          : "0" + " Km/h",
                      style: GoogleFonts.rubik(
                          color: Colors.lightBlue[900],
                          fontSize: 25,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 3),
                ],
              ),
            ),
          ),
          Container(
            height: 90,
            width: 180,
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
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            margin: EdgeInsets.all(5),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Distancia recorrida: ",
                      style: GoogleFonts.rubik(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[750])),
                  SizedBox(height: 7),
                  Text(
                      monthDistance.length > 0
                          ? (monthDistance[monthDistance.length - 1].value)
                                  .toStringAsFixed(2) +
                              " Km"
                          : "0" + " Km",
                      style: GoogleFonts.rubik(
                          color: Colors.lightBlue[900],
                          fontSize: 25,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 3),
                ],
              ),
            ),
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return content();
  }
}

class MonthData {
  final int month;
  final double value;

  MonthData(this.month, this.value);
}
