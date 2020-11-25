import 'package:flutter/material.dart';

import 'package:blue/models/evento.dart';

class EventoInfo extends StatelessWidget {
  final Evento _evento;

  EventoInfo(this._evento);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
        child: SafeArea(
            child: Padding(
      padding: EdgeInsets.all(20),
      child: Card(
        child: Text(_evento.titulo),
      ),
    )));
  }
}
