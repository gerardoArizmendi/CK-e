import 'package:blue/models/user.dart';
import 'package:blue/pages/social/user_card.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:blue/models/main_scope.dart';
import 'package:blue/models/auth.dart';
import 'package:blue/helpers_POD/ensure_visible.dart';
import 'package:blue/models/evento.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoped_model/scoped_model.dart';

class EventoEdit extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EventoEditState();
  }
}

class _EventoEditState extends State<EventoEdit> with TickerProviderStateMixin {
  bool newUser = false;

  PostType _type = PostType.Post;
  AnimationController _controller;
  Animation<Offset> _slideAnimation;

  Animation<double> _translateButton;
  AnimationController _animationController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'titulo': null,
    'descripcion': null,
  };
  DateTime _startDate = DateTime.now();
  DateTime _endDate;

  bool _startDay = false;
  bool _endDay = false;

  bool _inviteUsers = false;
  bool _image = false;

  bool isOpened = false;

  double _postHeight = -100;
  Curve _curve = Curves.easeOut;

  final _tituloFocusNode = FocusNode();
  final _tituloTextController = TextEditingController();
  final _bioTextController = TextEditingController();
  final _bioFocuNode = FocusNode();

  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0.0, -1.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _translateButton = Tween<double>(
      begin: _postHeight,
      end: -20.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));

    super.initState();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

//----------SCROLL

  Decoration _decoration = new BoxDecoration(
    border: new Border(
      top: new BorderSide(
        style: BorderStyle.solid,
        color: Colors.black26,
      ),
      right: new BorderSide(
        style: BorderStyle.solid,
        color: Colors.black26,
      ),
      left: new BorderSide(
        style: BorderStyle.solid,
        color: Colors.black26,
      ),
      bottom: new BorderSide(
        style: BorderStyle.solid,
        color: Colors.black26,
      ),
    ),
  );

  String _monthPicker(int month) {
    String _monthString;
    switch (month) {
      case 1:
        _monthString = "Enero";
        break;
      case 2:
        _monthString = "Febrero";
        break;
      case 3:
        _monthString = "Marzo";
        break;
      case 4:
        _monthString = "Abril";
        break;
      case 5:
        _monthString = "Mayo";
        break;
      case 6:
        _monthString = "Junio";
        break;
      case 7:
        _monthString = "Julio";
        break;
      case 8:
        _monthString = "Agosto";
        break;
      case 9:
        _monthString = "Septiembre";
        break;
      case 10:
        _monthString = "Octubre";
        break;
      case 11:
        _monthString = "Noviembre";
        break;
      case 12:
        _monthString = "Diciembre";
        break;
      default:
    }
    return _monthString;
  }

  Widget _datePicker(Evento evento) {
    return FadeTransition(
        opacity: CurvedAnimation(parent: _controller, curve: Curves.easeIn),
        child: SlideTransition(
            position: _slideAnimation,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Divider(
                thickness: 1,
              ),
              Text("Fecha", style: GoogleFonts.roboto(fontSize: 15)),
              Row(children: [
                Switch(
                    value: _startDay,
                    onChanged: (bool value) {
                      setState(() {
                        _startDay = value;
                      });
                    }),
                Text("Inicio"),
                _startDay
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          FlatButton(
                              onPressed: () {
                                DatePicker.showDatePicker(context,
                                    showTitleActions: true,
                                    minTime: DateTime(2020, 01, 01),
                                    maxTime: DateTime(2025, 12, 31),
                                    onChanged: (date) {
                                  print("DATE CHange: " + date.toString());
                                }, onConfirm: (time) {
                                  setState(() {
                                    _startDate = time;
                                  });
                                  FocusScopeNode currentFocus =
                                      FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.dispose();
                                  }
                                },
                                    currentTime: DateTime.now(),
                                    locale: LocaleType.es);
                              },
                              child: Container(
                                child: Container(
                                    child: Padding(
                                        padding: EdgeInsets.all(3),
                                        child: Row(children: [
                                          Container(
                                              child: Text(_startDate != null
                                                  ? _monthPicker(
                                                      _startDate.month)
                                                  : "-")),
                                        ]))),
                              )),
                          Container(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Container(
                                  child: Text(_startDate != null
                                      ? _startDate.day.toString()
                                      : "")),
                            ),
                          ),
                          FlatButton(
                              onPressed: () {
                                FocusScopeNode currentFocus =
                                    FocusScope.of(context);
                                DatePicker.showTimePicker(context,
                                    showSecondsColumn: false,
                                    showTitleActions: true, onChanged: (date) {
                                  print("DATE CHange: " + date.toString());
                                }, onConfirm: (time) {
                                  int _year = _startDate != null
                                      ? _startDate.year
                                      : DateTime.now().year;
                                  int _month = _startDate == null
                                      ? DateTime.now().month
                                      : _startDate.month;
                                  int _day = _startDate == null
                                      ? DateTime.now().day
                                      : _startDate.day;
                                  setState(() {
                                    _startDate = DateTime(
                                      _year,
                                      _month,
                                      _day,
                                      time.hour,
                                      time.minute,
                                    );
                                    // if (!currentFocus.hasPrimaryFocus) {
                                    //   currentFocus.dispose();
                                    // }
                                  });
                                },
                                    currentTime: DateTime.now(),
                                    locale: LocaleType.es);
                              },
                              child: Container(
                                child: Container(
                                    child: Padding(
                                        padding: EdgeInsets.all(3),
                                        child: Row(children: [
                                          Container(
                                              child: Text(_startDate != null
                                                  ? (_startDate.hour
                                                          .toString() +
                                                      ":" +
                                                      _startDate.minute
                                                          .toString())
                                                  : "-")),
                                        ]))),
                              )),
                        ],
                      )
                    : SizedBox(),
              ]),
              Row(children: [
                Switch(
                    value: _endDay,
                    onChanged: (bool value) {
                      setState(() {
                        _endDay = value;
                      });
                    }),
                Text("Final"),
                _endDay
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          FlatButton(
                              onPressed: () {
                                DatePicker.showDatePicker(context,
                                    showTitleActions: true,
                                    minTime: DateTime(2020, 01, 01),
                                    maxTime: DateTime(2025, 12, 31),
                                    onChanged: (date) {
                                  print("DATE CHange: " + date.toString());
                                }, onConfirm: (time) {
                                  setState(() {
                                    _endDate = time;
                                  });
                                },
                                    currentTime: DateTime.now(),
                                    locale: LocaleType.es);
                              },
                              child: Container(
                                child: Container(
                                    child: Padding(
                                        padding: EdgeInsets.all(3),
                                        child: Row(children: [
                                          Container(
                                              child: Text(_endDate != null
                                                  ? _monthPicker(_endDate.month)
                                                  : "-")),
                                        ]))),
                              )),
                          Container(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Container(
                                  child: Text(
                                _endDate != null ? _endDate.day.toString() : "",
                              )),
                            ),
                          ),
                          FlatButton(
                              focusNode: FocusNode(skipTraversal: true),
                              onPressed: () {
                                DatePicker.showTimePicker(context,
                                    showSecondsColumn: false,
                                    showTitleActions: true, onChanged: (date) {
                                  print("DATE CHange: " + date.toString());
                                }, onConfirm: (time) {
                                  setState(() {
                                    int _year = _endDate.year == null
                                        ? DateTime.now().year
                                        : _endDate.year;
                                    int _month = _endDate.month == null
                                        ? DateTime.now().month
                                        : _endDate.month;
                                    int _day = _endDate.day == null
                                        ? DateTime.now().day
                                        : _endDate.day;
                                    setState(() {
                                      _endDate = DateTime(
                                        _year,
                                        _month,
                                        _day,
                                        time.hour,
                                        time.minute,
                                      );
                                    });
                                  });
                                },
                                    currentTime: DateTime.now(),
                                    locale: LocaleType.es);
                              },
                              child: Container(
                                child: Container(
                                    child: Padding(
                                        padding: EdgeInsets.all(3),
                                        child: Row(children: [
                                          Container(
                                              child: Text(_endDate != null
                                                  ? (_endDate.hour.toString() +
                                                      ":" +
                                                      _endDate.minute
                                                          .toString())
                                                  : "-")),
                                        ]))),
                              )),
                        ],
                      )
                    : SizedBox(),
              ]),
            ])));
  }

  Widget _userPicker(List<User> following, BuildContext context) {
    return Container(
        height: 100,
        width: double.maxFinite,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text("Invita Amigos", style: GoogleFonts.roboto(fontSize: 15)),
            SizedBox(
              width: 10,
            ),
            Switch(
                value: _inviteUsers,
                onChanged: ((bool value) {
                  setState(() {
                    _inviteUsers = value;
                  });
                }))
          ]),
          _inviteUsers
              ? Expanded(
                  child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    List<bool> _addedFreinds = [];
                    for (var i = 0; i < index; i++) {
                      print("Adding: " + i.toString());
                      _addedFreinds.add(false);
                    }
                    print("Length: " + _addedFreinds.length.toString());
                    return Row(children: [
                      GestureDetector(
                          child: Icon(
                              /*_addedFreinds[index]
                              ? Icons.check_box
                              : */
                              Icons.check_box_outline_blank),
                          onTap: () {
                            bool value = _addedFreinds[index];
                            setState(() {
                              _addedFreinds[index] = !value;
                            });
                          }),
                      Container(
                        child: Row(children: [
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage(following[index].imageUrl),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(following[index].nombre)
                        ]),
                      )
                    ]);
                  },
                  itemCount: following.length,
                ))
              : SizedBox()
        ]));
  }

  Widget _buildPageContent(MainModel _model, Evento evento) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          margin: EdgeInsets.all(5.0),
          child: Form(
            key: _formKey,
            child: ListView(
                // padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      _buildTituloTextField(evento),
                      SizedBox(height: 30.0),
                      Transform(
                        transform: Matrix4.translationValues(
                          0.0,
                          _translateButton.value,
                          0.0,
                        ),
                        child: _buildBioTextField(evento),
                      ),
                      _datePicker(evento),
                      SizedBox(height: 10.0),
                      _userPicker(_model.followingListGet, context),
                      // LocationInput(_setLocation, evento),
                      //SizedBox(height: 10.0),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ]),
          ),
        ));
  }

  //  Future _showIntDialog() async {
  //   await showDialog<int>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return new NumberPickerDialog.integer(
  //         minValue: 0,
  //         maxValue: 100,
  //         step: 10,
  //         initialIntegerValue: _currentIntValue,
  //       );
  //     },
  //   ).then((num value) {
  //     if (value != null) {
  //       setState(() => _currentIntValue = value);
  //       integerNumberPicker.animateInt(value);
  //     }
  //   });
  // }

  Widget _buildTituloTextField(Evento evento) {
    print("Nombre Text Field: ");
    if (evento == null && _tituloTextController.text.trim() == '') {
      _tituloTextController.text = '';
      newUser = true;
    } else if (evento != null && _tituloTextController.text.trim() == '') {
      _tituloTextController.text = evento.titulo;
    } else if (evento != null && _tituloTextController.text.trim() != '') {
      _tituloTextController.text = _tituloTextController.text;
    } else if (evento == null && _tituloTextController.text.trim() != '') {
      _tituloTextController.text = _tituloTextController.text;
    } else {
      _tituloTextController.text = '';
    }
    return FadeTransition(
        opacity: CurvedAnimation(parent: _controller, curve: Curves.easeIn),
        child: SlideTransition(
            position: _slideAnimation,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  EnsureVisibleWhenFocused(
                      focusNode: _tituloFocusNode,
                      child: TextFormField(
                        focusNode: _tituloFocusNode,
                        decoration: InputDecoration(
                            labelText: 'Titulo de Evento',
                            border: new OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0))),
                        controller: _tituloTextController,
                        // initialValue: evento == null ? '' : evento.title,
                        validator: (String value) {
                          // if (value.trim().length <= 0) {
                          if (_type == PostType.Event
                              ? (value.isEmpty || value.length < 5)
                              : false) {
                            print("EMPTY");
                            return 'El titulo requiere ser +5 caracteres.';
                          } else {
                            print("Returning Nothing");
                            return null;
                          }
                        },
                        onSaved: (String value) {
                          _formData['titulo'] = value;
                        },
                      ))
                ])));
  }

  Widget _buildBioTextField(Evento evento) {
    if (evento == null && _bioTextController.text.trim() == '') {
      _bioTextController.text = '';
    } else if (evento != null && _bioTextController.text.trim() == '') {
      _bioTextController.text = evento.descripcion;
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          EnsureVisibleWhenFocused(
            focusNode: _tituloFocusNode,
            child: TextFormField(
              focusNode: _bioFocuNode,
              maxLines: 4,
              decoration: InputDecoration(
                  labelText: _type == PostType.Event
                      ? 'Descripcion del Evento'
                      : 'Contenido',
                  border: new OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0))),
              // initialValue: evento == null ? '' : evento.description,
              controller: _bioTextController,
              validator: (String value) {
                // if (value.trim().length <= 0) {
                if (value.isEmpty || value.length < 10) {
                  return 'Requiere ser +5 caracteres.';
                } else {
                  return null;
                }
              },
              onSaved: (String value) {
                _formData['descripcion'] = value;
              },
            ),
          )
        ]);
  }

  Widget _buildSubmitButton(Evento evento) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Center(child: CircularProgressIndicator())
            : RaisedButton(
                child: Text('Publicar'),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () {
                  _formKey.currentState.save();
                  if (_formKey.currentState.validate()) {
                    if (_type == PostType.Event
                        ? (_tituloTextController.text.length < 1 ||
                            _bioTextController.text.length < 1)
                        : _bioTextController.text.length < 1) {
                      print("NO TEXT");
                    } else {
                      print("TEXT AVAILABLE");
                      _submitEvent(
                          model.setEvents, _type == PostType.Event ? 0 : 1);
                    }
                  }
                  // model.userAuthFetch();
                });
      },
    );
  }

  void _submitEvent(Function setEvent, int type) {
    Evento _evento = _type == PostType.Event
        ? Evento(
            titulo: _tituloTextController.text,
            descripcion: _bioTextController.text,
            timeStart: _startDate,
            timeEnd: _endDate)
        : Evento(
            descripcion: _bioTextController.text,
          );
    setEvent(_evento, type);
    Navigator.pop(context);
    Navigator.pushNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      final Evento evento = model.selectedEvento;
      return Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              _buildSubmitButton(evento),
            ],
            title: Center(
                child: FlatButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              color: Colors.lightBlue[500],
              child: Text(
                  '${_type == PostType.Post ? 'Publicacion' : 'Evento'}',
                  style: GoogleFonts.roboto(fontSize: 14, color: Colors.white)),
              onPressed: () {
                animate();
                if (_type == PostType.Post) {
                  setState(() {
                    _type = PostType.Event;
                  });
                  _controller.forward();
                } else {
                  setState(() {
                    _type = PostType.Post;
                  });
                  _controller.reverse();
                }
              },
            )),
          ),
          body: Center(
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    child: _buildPageContent(model, evento),
                    padding: EdgeInsets.all(10),
                  ))));
    });
  }
}
