import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:blue/models/evento.dart';
import 'package:blue/models/main_scope.dart';
import 'package:blue/pages/calendarioTools/calendario.dart';

class CalendarioWidget extends StatelessWidget {
  Widget _creaUnEvento(context, model) {
    return Center(
        child: Padding(
            padding: EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/EventoNuevo');
              },
              child: Card(
                  color: Colors.blue[100],
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.add),
                        Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            )));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      List<Evento> _eventos = [];
      model.getEventos.forEach((element) {
        if (element.timeStart.isAfter(DateTime.now())) {
          Evento _evento = Evento(
              titulo: element.titulo,
              descripcion: element.descripcion,
              start: element.start,
              end: element.end,
              users: element.users,
              timeStart: element.timeStart,
              timeEnd: element.timeEnd);
          _eventos.add(_evento);
        }
      });
      return Card(
        elevation: 20,
        child: _eventos.length < 1
            ? _creaUnEvento(context, model)
            : ListView.builder(
                itemCount: _eventos.length,
                itemBuilder: (BuildContext context, int index) {
                  var _time = _eventos[index]
                      .timeStart
                      .difference(DateTime.now())
                      .inHours;
                  return Padding(
                    padding: EdgeInsets.all(20),
                    child: Container(
                        color: _time < 2 ? Colors.red[300] : Colors.green[300],
                        child: ListTile(
                          title: Text(_eventos[index].titulo),
                          subtitle: Text(_eventos[index].descripcion),
                          trailing:
                              Icon(Icons.check_box_outline_blank, size: 39.3),
                          onLongPress: () {
                            popEvent(_eventos[index], context);
                          },
                        )),
                  );
                }),
      );
    });
  }
}
