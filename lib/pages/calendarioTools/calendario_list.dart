import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:blue/models/main_scope.dart';
import 'package:blue/models/evento.dart';

class CalendarioListBuilder extends StatefulWidget {
  final MainModel model;
  CalendarioListBuilder(this.model);
  @override
  State<StatefulWidget> createState() {
    print("CALENDARIO LIST");
    return _CalendarioListState(model);
  }
}

class _CalendarioListState extends State<CalendarioListBuilder> {
  final MainModel model;
  _CalendarioListState(this.model);

  CalendarController _calendarController;
  DateTime _selectedDay = DateTime.now();

  Map<DateTime, List<Evento>> _events = {};
  List<Evento> _eventosList;

  @override
  void initState() {
    _eventosList = model.getEventos;
    eventsToMap(model.getEventos);
    _calendarController = CalendarController();
    super.initState();
  }

  void eventsToMap(List<Evento> _eventsTemp) {
    List<Evento> _eventosTemp = [];
    _eventosTemp = new List<Evento>.from(_eventsTemp);
    Map<DateTime, List<Evento>> map = {};
    _eventosTemp.sort((a, b) => b.timeStart.compareTo(a.timeStart));
    bool loop = true;
    while (loop) {
      if (_eventosTemp.length == 0) {
        break;
      }
      Evento _tempEvento = _eventosTemp.first;
      _eventosTemp.removeAt(0);
      List<Evento> _listEvents = _eventosTemp
          .where((element) =>
              element.timeStart.day.compareTo(_tempEvento.timeStart.day) < 1)
          .toList();
      _listEvents.add(_tempEvento);
      map[_tempEvento.timeStart] = _listEvents;
    }
    _events = map;
  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedDay = day;
    });
  }

  Widget _buildEventList(List<Evento> _eventos) {
    List<Evento> _eventosTemp;
    Widget content = Text("Sin eventos");
    print("CalendarioList");
    print("Eventos Length:" + _eventos.length.toString());
    if (_eventos.length > 0) {
      _eventosTemp = _eventos
          .where((element) =>
              element.timeStart.isAfter(_selectedDay) &&
              element.timeStart
                  .isBefore(_selectedDay.add(new Duration(days: 1))))
          .toList();
      _eventosTemp.sort((a, b) => b.timeStart.compareTo(a.timeStart));
      content = ListView.builder(
          itemCount: _eventosTemp.length,
          itemBuilder: (BuildContext context, int index) {
            return ExpansionTile(
              trailing: IgnorePointer(),
              title: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(_eventosTemp[index].titulo),
                  subtitle: Text(_eventosTemp[index].timeStart.year.toString() +
                      "-" +
                      _eventosTemp[index].timeStart.month.toString() +
                      "-" +
                      _eventosTemp[index].timeStart.day.toString()),
                ),
              ),
              children: <Widget>[
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.8),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: EdgeInsets.all(30),
                  child: Column(children: [
                    Text(
                      "Hora de Inicio: ",
                      textScaleFactor: .9,
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      _eventosTemp[index].timeStart.toString(),
                      textScaleFactor: 1.2,
                    ),
                    Divider(),
                    Text(
                      "Descripcion: ",
                      textScaleFactor: .9,
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      _eventosTemp[index].descripcion,
                      textScaleFactor: 1.2,
                    ),
                    Divider(),
                    Text("Usuarios: ",
                        textScaleFactor: .9, textAlign: TextAlign.left),
                    _eventosTemp[index].users == "null"
                        ? Text(_eventosTemp[index].users.toString(),
                            textScaleFactor: 1.2)
                        : FlatButton(
                            onPressed: () {},
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.supervised_user_circle,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                  Icon(
                                    Icons.add,
                                    color: Colors.blue,
                                    size: 30,
                                  )
                                ])),
                    Divider(),
                    Text("Ubicación: ",
                        textScaleFactor: .9, textAlign: TextAlign.left),
                    _eventosTemp[index].start != null
                        ? Text(_eventosTemp[index].users.toString(),
                            textScaleFactor: 1.2)
                        : FlatButton(
                            onPressed: () {},
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.pin_drop,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                  Icon(
                                    Icons.add,
                                    color: Colors.blue,
                                    size: 30,
                                  )
                                ])),
                    Divider(),
                    Text("Imagenes: ",
                        textScaleFactor: .9, textAlign: TextAlign.left),
                    _eventosTemp[index].users == "null"
                        ? Text(_eventosTemp[index].users.toString(),
                            textScaleFactor: 1.2)
                        : FlatButton(
                            onPressed: () {},
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                  Icon(
                                    Icons.add,
                                    color: Colors.blue,
                                    size: 30,
                                  )
                                ])),
                    Divider(),
                  ]),
                ),
              ],
            );
          });
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    DateTime now = DateTime.now();
    var fechaFormato = DateFormat('dd-MM-yyyy').format(now);
    final String configFecha = 'lastConfig.$fechaFormato.json';
    initializeDateFormatting(configFecha);
    return Center(
        child: Column(
      children: <Widget>[
        TableCalendar(
          locale: 'es_ES',
          calendarController: _calendarController,
          initialCalendarFormat: CalendarFormat.week,
          availableCalendarFormats: const {
            CalendarFormat.twoWeeks: 'Dos Semanas',
            CalendarFormat.week: 'Semana',
          },
          events: _events,
          onDaySelected: (date, holidays) {
            _onDaySelected(date, holidays);
            // _animationController.forward(from: 0.0);
          },
        ),
        Expanded(child: _buildEventList(_eventosList)),
      ],
    ));
  }
}
