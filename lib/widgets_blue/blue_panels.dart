import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'package:blue/models/main_scope.dart';
import 'package:blue/models/data.dart';

class ModuleTile extends StatelessWidget {
  final BluetoothDevice device;
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ModuleTile(
      {Key key, this.device, this.service, this.characteristicTiles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      trailing: IgnorePointer(),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
              service.uuid.toString() == "0000ffe0-0000-1000-8000-00805f9b34fb"
                  ? device.name
                  : service.uuid.toString() ==
                          "0000fee3-0000-1000-8000-00805f9b34fb"
                      ? "Motion Engine"
                      : "Desconocido",
              style: GoogleFonts.roboto(fontSize: 20))
        ],
      ),
      children: characteristicTiles,
    );
  }
}

BlueData processData(String data, MainModel model, BuildContext context) {
  // print("TRAMA: " + data);
  List<String> trama = data.split("\$");
  for (int i = 1; i < trama.length; i++) {
    bool isNumber = double.parse(trama[i], (e) => null) != null;
    if (!isNumber) {
      trama[i] = "0";
    }
  }
  BlueData blue = new BlueData(
      accidente: int.parse(trama[1]),
      temperatura: int.parse(trama[2]),
      humedad: int.parse(trama[3]));
  print("temperatura: " + blue.temperatura.toString());
  print("humedad: " + blue.humedad.toString());

  if (blue.accidente == 1) {
    model.sendAlert();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Se ha enviado una alerta de accidente."),
            content: Text("Tus contactos de emergencia recibirán una alerta."),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    model.cancelAlert();
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
  }

  model.updateBlueData(blue);
  return blue;
}

void processDataCentral(String data, MainModel model, BuildContext context) {
  print("TRAMA Central: " + data);
  List<String> trama = data.split("\$");
  for (int i = 1; i < trama.length; i++) {
    bool isNumber = double.parse(trama[i], (e) => null) != null;
    if (!isNumber) {
      trama[i] = "0";
    }
  }
  int accidente = int.parse(trama[1]);

  if (accidente == 1) {
    model.sendAlert();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Se ha enviado una alerta de accidente."),
            content: Text("Tus contactos de emergencia recibirán una alerta."),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    model.cancelAlert();
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
  }
}

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final VoidCallback onReadPressed;
  final VoidCallback onWritePressed;
  final VoidCallback onNotificationPressed;
  final String name;

  const CharacteristicTile(
      {Key key,
      this.characteristic,
      this.onReadPressed,
      this.onWritePressed,
      this.onNotificationPressed,
      this.name})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CharacteristicTileState();
  }
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  BlueData blue = BlueData(
    accidente: 0,
    temperatura: 0,
    humedad: 0,
  );

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return StreamBuilder<List<int>>(
          stream: widget.characteristic.value,
          initialData: widget.characteristic.lastValue,
          builder: (c, snapshot) {
            if (widget.characteristic.isNotifying) {
              final value = snapshot.data;
              final String data = String.fromCharCodes(value).toString();
              if (value.length > 0 && widget.name == "CASCO") {
                blue = processData(data, model, context);
              } else if (value.length > 0 && widget.name != "CASCO") {
                print("BLUETOOTH");
                processDataCentral(data, model, context);
              }
            } else {
              print("ON Notification");
              widget.onNotificationPressed();
            }
            //model.setData(blue);
            return widget.name == "CASCO"
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        // Text("TRAMA: " +
                        //     String.fromCharCodes(snapshot.data).toString()),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Card(
                                  child: Container(
                                padding: EdgeInsets.all(35),
                                child: Text(
                                  blue.temperatura.toString() + "ºC",
                                  textScaleFactor: 2,
                                ),
                              )),
                              Card(
                                child: Container(
                                    padding: EdgeInsets.all(32),
                                    child: Column(children: [
                                      Text("Humidity: "),
                                      Text(
                                        blue.humedad.toString(),
                                        textScaleFactor: 1.5,
                                      ),
                                    ])),
                              )
                            ]),
                      ])
                : Center(
                    child: Card(
                        child: Container(
                      padding: EdgeInsets.all(35),
                      child: Text(
                        "Modulo de Luces",
                        textScaleFactor: 2,
                      ),
                    )),
                  );
          },
        );
      },
    );
  }
}

// Widget _buildVelocidadGraph(BlueData blue) {
//   var datas = [
//     new BlueData(
//         name: 'TOP SPEED',
//         velocidad: 32,
//         cadencia: 12,
//         temperatura: 26,
//         humedad: 41,
//         tiempo: "55"),
//     new BlueData(
//         name: 'Avg. SPEED',
//         velocidad: 12,
//         cadencia: 8,
//         temperatura: 26,
//         humedad: 41,
//         tiempo: "55"),
//     new BlueData(
//         name: blue.name,
//         velocidad: blue.velocidad,
//         cadencia: blue.cadencia,
//         temperatura: blue.temperatura,
//         humedad: blue.humedad,
//         tiempo: blue.tiempo)
//   ];
//   var series = [
//     new charts.Series(
//       id: 'BLUE',
//       data: datas,
//       domainFn: (BlueData bluedata, _) => bluedata.name,
//       measureFn: (BlueData bluedata, _) => bluedata.cadencia,
//     )
//   ];
//   var chart = new charts.BarChart(
//     series,
//     animate: true,
//   );
//   return new Padding(
//       padding: EdgeInsets.all(20),
//       child: SizedBox(
//         child: chart,
//         height: 200,
//       ));
// }

// //ORIGNAL BUILD
//   @override
//   Widget build(BuildContext context) {
//     return ScopedModelDescendant<MainModel>(
//       builder: (BuildContext context, Widget child, MainModel model) {
//         return StreamBuilder<List<int>>(
//           stream: characteristic.value,
//           initialData: characteristic.lastValue,
//           builder: (c, snapshot) {
//             BlueData blue = BlueData(
//               accidente: 0,
//               temperatura: 0,
//               humedad: 0,
//             );
//             if (characteristic.isNotifying) {
//               final value = snapshot.data;
//               final String data = String.fromCharCodes(value).toString();
//               // blue = processData(data, model);
//             } else {}
//             //model.setData(blue);
//             return ExpansionTile(
//                 title: ListTile(
//                   title: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text(
//                         'State: ',
//                         style: TextStyle(fontSize: 20),
//                       ),
//                       Text(characteristic.isNotifying ? 'Online' : 'Offline',
//                           style: Theme.of(context).textTheme.body1.copyWith(
//                               color:
//                                   Theme.of(context).textTheme.caption.color)),
//                     ],
//                   ),
//                   contentPadding: EdgeInsets.all(0.0),
//                 ),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: <Widget>[
//                     IconButton(
//                       icon: Icon(
//                           characteristic.isNotifying
//                               ? Icons.sync_disabled
//                               : Icons.sync,
//                           color: Theme.of(context)
//                               .iconTheme
//                               .color
//                               .withOpacity(0.5)),
//                       onPressed: onNotificationPressed,
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.surround_sound,
//                           color: Theme.of(context)
//                               .iconTheme
//                               .color
//                               .withOpacity(0.5)),
//                       onPressed: () {
//                         // FlutterRingtonePlayer.playAlarm();
//                       },
//                     )
//                   ],
//                 ),
//                 children: <Widget>[
//                   Text("TRAMA: " +
//                       String.fromCharCodes(snapshot.data).toString()),
//                   Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                     Card(
//                         child: Container(
//                       padding: EdgeInsets.all(35),
//                       child: Text(
//                         blue.temperatura.toString() + "ºC",
//                         textScaleFactor: 2,
//                       ),
//                     )),
//                     Card(
//                       child: Container(
//                           padding: EdgeInsets.all(32),
//                           child: Column(children: [
//                             Text("Humidity: "),
//                             Text(
//                               blue.humedad.toString(),
//                               textScaleFactor: 1.5,
//                             ),
//                           ])),
//                     )
//                   ]),
//                 ]);
//           },
//         );
//       },
//     );
//   }
// }
