import 'package:blue/models/main_scope.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:scoped_model/scoped_model.dart';

class FloatingAction extends StatefulWidget {
  FloatingAction();

  @override
  _FancyFabState createState() => _FancyFabState();
}

class _FancyFabState extends State<FloatingAction>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Animation<double> _translateButtonMiddle1;
  Animation<double> _translateButtonMiddle2;
  Animation<double> _translateButtonSide;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -20.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    _translateButtonSide = Tween<double>(
      begin: 0.0,
      end: 80.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    _translateButtonMiddle1 = Tween<double>(
      begin: 0.0,
      end: -60.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    _translateButtonMiddle2 = Tween<double>(
      begin: 56.0,
      end: 26.0,
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

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget emergencia() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        child: FloatingActionButton(
          backgroundColor: Colors.yellow[600],
          onPressed: () {
            model.sendAlert();
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Has enviado una alerta de accidente"),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            model.cancelAlert();
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
          },
          heroTag: "perfil",
          tooltip: 'perfil',
          child: Icon(Icons.warning, color: Colors.red),
        ),
      );
    });
  }

  Widget social() {
    return Container(
      child: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/Social');
        },
        heroTag: "Social",
        tooltip: 'Social',
        child: Icon(Icons.people),
      ),
    );
  }

  Widget eventoNuevo() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.pushNamed(context, '/EventoNuevo');
        },
        heroTag: "Evneto",
        tooltip: 'Agregar',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.add),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget startRoute() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Container(
          child: FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: () {
              setRoute(model);
            },
            heroTag: "Start Route",
            tooltip: 'Start Route',
            child: Icon(
              Icons.play_circle_filled,
              size: 40,
            ),
          ),
        );
      },
    );
  }

  Future<void> setRoute(MainModel model) async {
    Location().getLocation().then((value) {
      print("ROUTE START");
      final LatLng location = LatLng(value.latitude, value.longitude);
      model.begginRoute(location);
      model.findService();
      Navigator.pushNamed(context, '/RoutePanel');
    });
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        heroTag: "Close",
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 3,
            0.0,
          ),
          child: emergencia(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2,
            0.0,
          ),
          child: eventoNuevo(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: startRoute(),
        ),
        toggle(),
      ],
    );
  }
}
