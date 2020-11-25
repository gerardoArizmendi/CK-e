import 'package:blue/tools_blue/ajustes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:blue/models/user.dart';
import 'package:blue/models/evento.dart';
import 'package:blue/pages/calendarioTools/evento_info.dart';
import 'package:blue/pages/calendarioTools/evento_nuevo.dart';
import 'package:blue/pages/calendarioTools/calendario_builder.dart';
import 'package:blue/pages/routeTools/route_panel.dart';
import 'package:blue/models/main_scope.dart';
import 'package:blue/other/find_devices.dart';
import 'package:blue/pages/find_modules.dart';
import 'package:blue/pages/social/social.dart';
import 'package:blue/pages/social/users_page.dart';
import 'package:blue/perfil_blue/auth_page.dart';
import 'package:blue/perfil_blue/perfil_editPage.dart';
import 'package:blue/perfil_blue/user_Interface.dart';
import 'package:blue/perfil_blue/perfil_dashboard/main_dash.dart';

// import 'package:blue/pages/routeTools/viaje.dart';

import 'package:blue/pages/home.dart';

void main() {
  runApp(BicklaApp());
}

class BicklaApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BicklaAppState();
  }
}

class _BicklaAppState extends State<BicklaApp> {
  final MainModel _model = MainModel();
  User actualUser;
  bool _isAuthenticated = false;

  @override
  void initState() {
    // _model.logOut(context);
    // _model.connectedBlue();
    _model.autoLogin().then((value) {
      _model.fireUserSubject.listen((bool isAuthenticated) {
        setState(() {
          _isAuthenticated = isAuthenticated;
        });
      }).onError((error) {
        print("[FIREUSER SUBJECT]: " + error.toString());
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("Is Authenticated: " + _isAuthenticated.toString());
    return ScopedModel<MainModel>(
        model: _model,
        child: MaterialApp(
            theme: ThemeData(
                primaryColor: Colors.lightBlue[900],
                primaryIconTheme: IconThemeData(
                  color: Colors.blueGrey[300],
                ),
                accentColor: Colors.purple),
            routes: {
              '/': (BuildContext context) => _isAuthenticated == false
                  ? AuthPage()
                  : Home(model: _model, title: 'Home'),
              '/editPerfil': (BuildContext context) =>
                  _isAuthenticated == false ? AuthPage() : PerfilEditPage(),
              '/user': (BuildContext context) =>
                  _isAuthenticated == false ? AuthPage() : UserPage(_model),
              '/ajustes': (BuildContext context) =>
                  _isAuthenticated == false ? AuthPage() : Ajustes(),
              '/Following': (BuildContext context) =>
                  _isAuthenticated == false ? AuthPage() : MySocial(_model),
              '/Followers': (BuildContext context) => _isAuthenticated == false
                  ? AuthPage()
                  : MySocialFollowers(_model),
              '/Social': (BuildContext context) =>
                  _isAuthenticated == false ? AuthPage() : AllUsersPage(_model),
              '/topFriends': (BuildContext context) => _isAuthenticated == false
                  ? AuthPage()
                  : EmergencyUsersPage(_model),
              '/RoutePanel': (BuildContext context) =>
                  _isAuthenticated == false ? AuthPage() : RoutePanel(_model),
              '/Calendario': (BuildContext context) =>
                  _isAuthenticated == false ? AuthPage() : CalendarioBuilder(),
              '/EventoNuevo': (BuildContext context) =>
                  _isAuthenticated == false ? AuthPage() : EventoEdit(),
              '/blue': (BuildContext context) => _isAuthenticated == false
                  ? AuthPage()
                  : StreamBuilder<BluetoothState>(
                      stream: FlutterBlue.instance.state,
                      initialData: BluetoothState.unknown,
                      builder: (c, snapshot) {
                        final state = snapshot.data;
                        if (state == BluetoothState.on) {
                          return FindDevicesScreen();
                        }
                        return BluetoothOffScreen(state: state);
                      }),
              '/modules': (BuildContext context) =>
                  _isAuthenticated == false ? AuthPage() : FindModules()
            },
            onGenerateRoute: (RouteSettings settings) {
              if (!_isAuthenticated) {
                return MaterialPageRoute<bool>(
                  builder: (BuildContext context) => AuthPage(),
                );
              }
              final List<String> pathElements = settings.name.split('/');
              if (pathElements[0] != '') {
                return null;
              }
              if (pathElements[1] == 'perfil') {
                final String perfilId = pathElements[2];
                _model.perfilSubscribe(perfilId);
                return MaterialPageRoute<bool>(
                  builder: (BuildContext context) =>
                      !_isAuthenticated ? AuthPage() : PerfilPage(_model),
                );
              }
              if (pathElements[1] == 'evento') {
                print("Getting Eventos");
                final String _fechaEvento = pathElements[2];
                Evento _evento = _model.getEventos.firstWhere(
                    (element) => element.timeStart.toString() == _fechaEvento);
                return MaterialPageRoute<bool>(
                  builder: (BuildContext context) =>
                      !_isAuthenticated ? AuthPage() : EventoInfo(_evento),
                );
              }
              return null;
            },
            onUnknownRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                  builder: (BuildContext context) => Home(
                        model: _model,
                        title: "Bickla",
                      ));
            }));
  }

//Blue Screen
}
