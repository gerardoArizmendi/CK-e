import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:google_fonts/google_fonts.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:blue/helpers_POD/location_helper.dart';

import 'package:blue/models/main_scope.dart';
import 'package:blue/models/route.dart';

class RouteInfo extends StatelessWidget {
  final List<RoutePath> path;
  final LatLng locDataStart;
  final LatLng locDataEnd;

  RouteInfo(this.path, this.locDataStart, this.locDataEnd);

  @override
  Widget build(BuildContext context) {
    String _previewImageUrl = LocationPathGenerator.generateLocationImage(
        latitude: locDataStart.latitude,
        longitude: locDataStart.longitude,
        latEnd: locDataEnd.latitude,
        longEnd: locDataEnd.longitude,
        path: path);

    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      final List<RoutePath> path = model.getRoutePath;
      return Center(
        child: Container(
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                    child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Image.network(
                    _previewImageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(18),
                        ),
                        color: Colors.black),
                    child: new charts.TimeSeriesChart([
                      charts.Series<RoutePath, DateTime>(
                          id: 'Values',
                          colorFn: (_, __) =>
                              charts.MaterialPalette.green.shadeDefault,
                          domainFn: (RoutePath values, _) => values.time,
                          measureFn: (RoutePath values, _) => values.speed,
                          data: path,
                          displayName: "Velocidad")
                    ],
                        animate: false,
                        primaryMeasureAxis: charts.NumericAxisSpec(
                          tickProviderSpec: charts.BasicNumericTickProviderSpec(
                              zeroBound: false),
                          renderSpec: charts.NoneRenderSpec(),
                        ),
                        domainAxis: new charts.DateTimeAxisSpec(
                            renderSpec: new charts.NoneRenderSpec())),
                  ),
                )
              ]),
        ),
      );
    });
  }
}

/*

Build Graph for ECART

//Widget

 Echarts(
                      option: graph,
                    ),


//for Graph

    String speed = "";
    String index = "";
    for (int i = 0; i < path.length; i++) {
      String temp = path[i].speed.toStringAsFixed(2);
      speed = speed + temp + ", ";
      index = index + "'" + i.toString() + "', ";
    }
    speed = speed.substring(0, speed.length - 2);
    speed = "[" + speed + "]";
    index = index.substring(0, index.length - 2);
    index = "[" + index + "]";
    print(speed);
    print(index);
    String category = "['Mon', 'Tue', 'Wed', 'Thu', 'XXX', 'Sat', 'Sun']";
    String value = "[820, 932, 901, 934, 1290, 1330, 1320]";
    print(value);
    print(category);
    String graph = '''
    {
      xAxis: {
        type: 'category',
        data: $index
      },
      yAxis: {
        type: 'value'
      },
      series: [{
        data: $speed,
        type: 'line'      
      }]
    }
  ''';
  
  */
