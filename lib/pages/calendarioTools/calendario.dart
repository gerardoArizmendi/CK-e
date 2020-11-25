import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:blue/models/main_scope.dart';
import 'package:blue/models/evento.dart';

class Calendario extends StatefulWidget {
  final MainModel _model;
  Calendario(this._model);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CalendarioState(_model);
  }
}

final Map<DateTime, List> _holidays = {
  // DateTime(2020, 7, 1): ['New Year\'s Day'],
  // DateTime(2020, 7, 6): ['Epiphany'],
  // DateTime(2020, 7, 14): ['Valentine\'s Day'],
  // DateTime(2020, 7, 21): ['Easter Sunday'],
  // DateTime(2020, 7, 22): ['Easter Monday'],
};

class _CalendarioState extends State<Calendario> with TickerProviderStateMixin {
  final MainModel _model;
  _CalendarioState(this._model);

  // Map<DateTime, List> _events;

  CalendarController _calendarController;
  List _selectedEvents;
  AnimationController _animationController;
  Map<DateTime, List<dynamic>> _events = {};
  List<Evento> _eventos;
  DateTime _selectedDay;

  @override
  void initState() {
    print("InitState Calendario");
    // TODO: implement initState
    super.initState();

    _events = {};
    _eventos = _model.getEventos;
    for (var i = 0; i < _eventos.length; i++) {
      setState(() {
        print("Dentro de Eventos: "+_eventos.length.toString());
        int _year = _eventos[i].timeStart.year;
        int _month = _eventos[i].timeStart.month;
        int _day = _eventos[i].timeStart.day;
        if (_events[DateTime(_year, _month, _day)] != null) {
          _events[DateTime(_year, _month, _day)].add(_eventos[i].titulo);
        } else {
          _events[DateTime(_year, _month, _day)] = [_eventos[i].titulo];
        }
      });
    }

    _selectedEvents = _model.getEvents[DateTime.now()] ?? [];
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
      _selectedDay = day;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  // More advanced TableCalendar configuration (using Builders & Styles)
  Widget _buildTableCalendarWithBuilders() {
    print("Building Calendar Builder");
    return new TableCalendar(
      locale: 'es_ES',
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.horizontalSwipe,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(color: Colors.red[800]),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle().copyWith(color: Colors.red[600]),
      ),
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        formatButtonVisible: false,
      ),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: Colors.deepOrange[300],
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.amber[400],
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }

          if (holidays.isNotEmpty) {
            print("Holiday Not Empty");
            children.add(
              Positioned(
                right: -2,
                top: -2,
                child: _buildHolidaysMarker(),
              ),
            );
          }

          return children;
        },
      ),
      onDaySelected: (date, holidays) {
        _onDaySelected(date, holidays);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date)
                ? Colors.brown[300]
                : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Widget _buildEventList() {
    List<Evento> _eventosTemp;
    if (_selectedEvents.isNotEmpty) {
      _eventosTemp = _eventos
          .where((element) =>
              0 == element.timeStart.difference(_selectedDay).inDays)
          .toList();
    }
    return ListView(
      children: _selectedEvents.map((event) {
        Evento _eventoTemp = _eventosTemp
            .firstWhere((element) => element.titulo == event.toString());
        return Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.8),
            borderRadius: BorderRadius.circular(12.0),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text(event.toString()),
            subtitle: Text(_eventoTemp.timeStart.toString()),
            onTap: () {
              print('$event tapped!');
              popEvent(_eventoTemp, context);
            },
            trailing: Icon(Icons.access_alarm),
          ),
        );
      }).toList(),
    );
  }


  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    var fechaFormato = DateFormat('dd-MM-yyyy').format(now);
    final String configFecha = 'lastConfig.$fechaFormato.json';
    initializeDateFormatting(configFecha);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _buildTableCalendarWithBuilders(),
        const SizedBox(height: 8.0),
        // _buildButtons(),
        const SizedBox(height: 8.0),
        Expanded(child: _buildEventList()),
      ],
    );
  }
}

void popEvent(Evento evento, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(evento.titulo),
          content: Card(
              child: Column(children: [
            new Text(
              "Descripcion: ",
              textScaleFactor: .8,
            ),
            new Text(evento.descripcion, textScaleFactor: 1.2),
            Divider(),
            new Text(
              "Fecha: ",
              textScaleFactor: .8,
            ),
            new Text(
                evento.timeStart.year.toString() +
                    "-" +
                    evento.timeStart.month.toString() +
                    "-" +
                    evento.timeStart.day.toString(),
                textScaleFactor: 1.2),
            Divider(),
            new Text(
              "Hora: ",
              textScaleFactor: .8,
            ),
            new Text(
                evento.timeStart.hour.toString() +
                    ":" +
                    evento.timeStart.minute.toString(),
                textScaleFactor: 1.2),
          ])),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Editar"),
              onPressed: () {
                print("EDITAR");
              },
            ),
            Row(
              children: <Widget>[Icon(Icons.ac_unit)],
            ),
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
