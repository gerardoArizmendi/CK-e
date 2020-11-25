import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:rxdart/subjects.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:collection/collection.dart';

import 'package:blue/models/evento.dart';
import 'package:blue/models/mensaje.dart';
import 'package:blue/models/ride.dart';
import 'package:blue/models/route.dart';

import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'dart:io';
import 'dart:convert';

import 'package:blue/models/user.dart';
import 'package:blue/models/data.dart';

class MainModel extends Model {
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//----------------Utility--------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
  User _authenticatedUser;
  PublishSubject<bool> _fireUserSubject = PublishSubject();

  bool _isLoading = false;

  bool get isLoading {
    return _isLoading;
  }

  bool _isLoadingRoutes = false;

  bool get isLoadingRoutes {
    return _isLoadingRoutes;
  }

  //Reload mainDash

  Future<void> refreshDashboard() async {
    print("Refreshing Dashboard");
    fetchCloseFriends();
    fetchEvents(onlyForUser: true, onlyPosts: false);
  }

  //------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
  Future<void> updateToken(String token) {
    print("GETTING TOKEN");
    return Firestore.instance
        .collection('/Perfiles')
        .document(_authenticatedUser.id)
        .setData({"messageToken": token}, merge: true);
  }

//--------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------
//--------------CHAT-------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------

// List de CHATS
/*
Cada quien tiene en su espacio guardado todos sus chats. 

Se accede con el numero de chat. El NUMCHAT es la fecha en el 
que se mando el mensaje.

Los chat tendran tokenDestino y tokenAutor para identificar
a a quien corresponde el mensaje. 


*/

  List<Mensaje> _mensajes = [];

  List<Mensaje> get mensajesGet {
    return _mensajes;
  }

  List<String> _chats = [];

  List<Mensaje> get chatsGet {
    List<Mensaje> _tempChats = [];

    // for (var x = 0; x < _chats.length; x++) {
    //   Firestore.instance
    //       .collection('/Perfiles')
    //       .document(_authenticatedUser.id)
    //       .collection('Mensajeria')
    //       .document(document)
    //       .get();
    // }
    return _tempChats;
  }

  Future<void> sendChat(Mensaje mensaje) {
    Firestore.instance
        .collection('/Mensajes')
        .document()
        .setData({'CHAT': "CHAT"});

    return null;

    // return null;
  }

//--------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------
//--------------CALENDARIO---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------

  // final _selectedDay = DateTime.now();

  Evento _evento;

  List<Evento> _eventos = [];
  List<Evento> _publicaciones = [];
  Map<DateTime, List<Evento>> _events = {};

  void eventsToMap() {
    List<Evento> _eventosTemp = [];
    _eventosTemp = _eventos;
    Map<DateTime, List<Evento>> map = {};
    _eventosTemp.sort((a, b) => b.timeStart.compareTo(a.timeStart));
    while (true) {
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

  Map<DateTime, List> get getEvents {
    return _events;
  }

  List<Evento> get getEventos {
    return _eventos;
  }

  List<Evento> get getPublicaciones {
    return _publicaciones;
  }

  Evento get selectedEvento {
    return _evento;
  }

  List<String> get getFollowingListId {
    List<String> _followingListId = [];
    for (var i = 0; i < _followingList.length; i++) {
      _followingListId.add(_followingList[i].id);
    }
    return _followingListId;
  }

  Future<void> setEvents(Evento tempEvento, int type) async {
    print("Inside setEvents");
    String _path = type == 0 ? 'Calendario' : 'Publicaciones';
    DateTime _timeTemp =
        tempEvento.timeStart != null ? tempEvento.timeStart : DateTime.now();
    Firestore.instance
        .collection('/Perfiles')
        .document(_authenticatedUser.id)
        .collection('Data')
        .document(_path)
        .setData({
      "${_timeTemp.toString()}":
          "${tempEvento.titulo}& ${tempEvento.descripcion}& ${tempEvento.start.toString()}& ${tempEvento.end.toString()}& ${tempEvento.users}& ${tempEvento.timeEnd.toString()}",
    }, merge: true).catchError((onError) {
      print(onError);
    });
  }

  Future<void> fetchEvents({onlyForUser = false, onlyPosts = true}) async {
    print("Inside fetchEvents");
    _isLoading = true;
    if (onlyForUser) {
      _eventos.clear();
    } else {
      _publicaciones.clear();
    }
    notifyListeners();
    String _path = onlyPosts ? 'Publicaciones' : 'Calendario';
    List<String> _tempList = [];
    onlyForUser
        ? _tempList.add(_authenticatedUser.id)
        : _tempList = getFollowingListId;
    if (!onlyForUser) {
      _tempList.add(_authenticatedUser.id);
    }
    for (var i = 0; i < _tempList.length; i++) {
      Firestore.instance
          .collection('/Perfiles')
          .document(_tempList[i])
          .collection('Data')
          .document(_path)
          .get()
          .then((value) {
        Map<String, dynamic> _data = value.data;
        if (_data != null) {
          _data.forEach((key, value) {
            List<String> _temp = value.toString().split('&');
            String _titulo = _temp[0];
            String _descripcion = _temp[1];
            List<String> _lugarInicio = _temp[2].split(',');
            List<String> _lugarFinal = _temp[3].split(',');
            String _acompanantes = _temp[4];
            String _fechaFinal = _temp[5];
            Evento _event = Evento(
                userId: _tempList[i],
                timeStart: DateTime.parse(key),
                titulo: _titulo,
                descripcion: _descripcion,
                start: _temp[2] != " null"
                    ? LatLng(double.parse(_lugarInicio[0]),
                        double.parse(_lugarInicio[1]))
                    : null,
                end: _temp[3] != " null"
                    ? LatLng(double.parse(_lugarFinal[0]),
                        double.parse(_lugarFinal[1]))
                    : null,
                users: _acompanantes,
                timeEnd: _fechaFinal != " null"
                    ? DateTime.parse(_fechaFinal)
                    : null);
            if (onlyForUser) {
              _eventos.add(_event);
            } else {
              _publicaciones.add(_event);
            }
          });

          _isLoading = false;
          notifyListeners();
        } else {
          _isLoading = false;
          notifyListeners();
        }
      });
    }
  }

//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//---------------------------ALERTS---------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------

  void sendAlert() {
    CollectionReference path = Firestore.instance
        .collection('/Perfiles')
        .document(_authenticatedUser.id)
        .collection('Data');
    path.document('Live').updateData({'onAlert': true});
    path.document('Accidents').setData({'AlerTime': DateTime.now()});
  }

  void cancelAlert() {
    CollectionReference path = Firestore.instance
        .collection('/Perfiles')
        .document(_authenticatedUser.id)
        .collection('Data');
    path.document('Live').updateData({'onAlert': false});
    path.document('Accidents').setData({'AlerTime': DateTime.now()});
  }

//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//---------------------------BLUETOOTH------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------

  List<BluetoothDevice> _blueDevices = [];
  List<BluetoothDevice> _localDevices = [];

  BluetoothDevice bicicleta;

  bool _isConnected = false;

  bool get isConnected {
    return _isConnected;
  }

  //List of all Bluetooth devices in _localDevices.
  //Query when showing BLE devices at Find Modules
  //when getting particular BLE devices at index.
  List<BluetoothDevice> get bluetoothDevices {
    Iterable<BluetoothDevice> _tempDevices = [];
    // _tempDevices = _localDevices.where((element) =>
    //     element.id.toString() == "DEB78445-E3C8-49C8-6D25-C94D46C61750");
    List<BluetoothDevice> _tempyDevices = _tempDevices.toList();
    if (_tempyDevices.length > 0) {
      print("Uuid: " + _tempyDevices[0].id.toString());
    }
    return _localDevices;
  }

  List<BluetoothDevice> get blueDevices {
    if (_blueDevices.length == 0 && _isConnected) {
      connectedBlue();
    }
    return _blueDevices;
  }

  Future<void> findService() async {
    for (BluetoothDevice device in _blueDevices) {
      device.discoverServices();
    }
  }

//Start Bluetooth Scan.
//Need to save new BLE device in List variable in order to not show repeated
  Future<void> scanBlue() async {
    _isLoading = true;
    // _blueDevices.clear();
    _localDevices.clear();
    notifyListeners();
    FlutterBlue.instance
        .startScan(timeout: Duration(seconds: 4))
        .catchError((onError) {
      //Usually antoher scan is in progress.
      print("Error: " + onError.toString());
    }).then((value) {
      FlutterBlue.instance.scanResults.listen((blue) {
        for (ScanResult device in blue) {
          if (_localDevices.any((element) => element.id == device.device.id)) {
            //Device is already saved.
          } else {
            //New Device, it will be added to our blueDevices.
            _localDevices.add(device.device);
          }
        }
      });
      print("Out of Scanning");
      _isLoading = false;
      notifyListeners();
    });
  }

  //Triggered when click on the device name
  Future<void> connectBlue(int index) async {
    bluetoothDevices[index].connect().whenComplete(() {
      print("When Completed Connect");
      bluetoothDevices[index].discoverServices();
      print("Connecting....");
      //Discore
      connectedBlue(index: index);
    }).catchError((onError) {
      print(onError);
    });
  }

  //Verifies that the connection is correct
  Future<void> connectedBlue({int index}) async {
    _isLoading = true;
    notifyListeners();

    FlutterBlue.instance.connectedDevices.then((tempDevices) {
      _blueDevices.clear();
      if (tempDevices.length > 0) {
        print("Then FlutterBlue Connected Devices");
        print("Is Connected");
        _isConnected = true;
        tempDevices.forEach((element) {
          print("ELEMENT ID:" + element.id.toString());
          print("Element Name: " + element.name);
          print("Element UIDD: " + element.services.length.toString());
          _blueDevices.add(element);

          index != null ? _localDevices.removeAt(index) : null;
          notifyListeners();
        });
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> disconnectDevice() async {
    _isLoading = true;
    notifyListeners();
    FlutterBlue.instance.connectedDevices.then((device) {
      device.forEach((element) {
        element.disconnect();
      });
    });
    _blueDevices = [];
    _isConnected = false;
    _isLoading = false;
    notifyListeners();
  }

//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//-----------------BIKE-LOAD-FIRESTORE------------------------------------------------------------------------------
//-----------------DATA---------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------

  String idRuta;
  double avgSpeed = 0;
  double avgTemp = 0;
  double samples = 0;

//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//----------------------FETCH ROUTE---------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------

  List<Ride> _routes = [];

  List<RoutePath> _routePath = [];

  List<Ride> get getRoutes {
    return _routes;
  }

  List<RoutePath> get getRoutePath {
    return _routePath;
  }

  List<Ride> _routesUser = [];

  List<Ride> get getUserRoutes {
    return _routesUser;
  }

  Future<void> fetchRoutePath(String id, String userId) {
    _routePath = [];
    _isLoading = true;
    notifyListeners();
    print("Fetching Route History");
    Firestore.instance
        .collection('/Perfiles')
        .document(userId)
        .collection('Rutas')
        .document(id)
        .collection('History')
        .orderBy('timeStamp')
        .getDocuments()
        .then((value) {
      int size = value.documents.length;
      if (size != 0) {
        var path = value.documents;
        for (var i = 0; i < size; i++) {
          double lat = path[i]['latitude'];
          double lon = path[i]['longitude'];
          double spe = path[i]['speed'] == 0
              ? 0.0
              : path[i]['speed'] == -1 ? 0.0 : path[i]['speed'];
          Timestamp timeStamp = path[i]['timeStamp'];
          DateTime date = new DateTime.fromMicrosecondsSinceEpoch(
              timeStamp.microsecondsSinceEpoch);
          final RoutePath _path =
              RoutePath(coordinate: LatLng(lat, lon), speed: spe, time: date);
          _routePath.add(_path);
          notifyListeners();
        }
      }
    }).catchError((onError) {
      print(onError);
    });

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<void> fetchRoutes(String _userId) {
    _routes = [];
    _isLoadingRoutes = true;
    notifyListeners();
    CollectionReference routes = Firestore.instance
        .collection('/Perfiles')
        .document(_userId)
        .collection('Rutas');
    routes.getDocuments().then((data) {
      int size = data.documents.length;
      if (size != 0) {
        var rides = data.documents;
        for (var i = 0; i < size; i++) {
          double speed =
              rides[i]['AvgSpeed'] != null ? rides[i]['AvgSpeed'] : 0;
          double topSpeed =
              rides[i]['TopSpeed'] != null ? rides[i]['AvgSpeed'] : 0;
          int temp =
              rides[i]['temperatura'] != null ? rides[i]['temperatura'] : 0;
          double distance =
              rides[i]['distance'] != null ? rides[i]['distance'] : 0;
          final Ride _route = Ride(
              start: LatLng(rides[i]['LatStart'], rides[i]['LongStart']),
              end: LatLng(rides[i]['LatEnd'], rides[i]['LongEnd']),
              timeStart: rides[i]['TimeStart'],
              timeEnd: rides[i]['TimeEnd'],
              speed: double.parse(speed.toStringAsFixed(2)),
              topSpeed: double.parse(topSpeed.toStringAsFixed(2)),
              temperature: temp.toDouble(),
              distance: double.parse(distance.toStringAsFixed(2)));
          _userId == _authenticatedUser.id
              ? _routesUser.add(_route)
              : _routes.add(_route);
          notifyListeners();
        }
      }
      print("Done fetching Routes");
      _isLoadingRoutes = false;
      notifyListeners();
    }).catchError((onError) {
      _isLoading = false;
      notifyListeners();
      print(onError);
    });
    _isLoading = false;
    notifyListeners();
    return null;
  }

//----------------------------------------------------------------------------------------------
//----------Route info ------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
  void begginRoute(LatLng ubicacion) {
    print("Nueva Ruta");
    DateTime time = DateTime.now();
    idRuta = time.toString();
    idRuta = idRuta.substring(0, idRuta.length - 3);
    print(idRuta.substring(0, idRuta.length - 3));
    samples = 0;
    avgSpeed = 0;
    avgTemp = 0;
    print(time);
    Firestore.instance
        .collection('/Perfiles')
        .document(_authenticatedUser.id)
        .collection('Rutas')
        .document(idRuta)
        .setData({
      'LatStart': ubicacion.latitude,
      'LongStart': ubicacion.longitude,
      'TimeStart': DateTime.parse(idRuta)
    });
    Firestore.instance
        .collection('/Perfiles')
        .document(_authenticatedUser.id)
        .collection('Data')
        .document('Live')
        .setData({'id': DateTime.parse(idRuta).toString()});
  }

  void endRoute(
      LatLng ubicacion, double avgSpeed, double topSpeed, double distance) {
    DateTime time = DateTime.now();
    Firestore.instance
        .collection('/Perfiles')
        .document(_authenticatedUser.id)
        .collection('Rutas')
        .document(idRuta)
        .updateData({
      'LatEnd': ubicacion.latitude,
      'LongEnd': ubicacion.longitude,
      'TimeEnd': time,
      'AvgSpeed': avgSpeed,
      'TopSpeed': topSpeed,
      'distance': distance
    });
    Firestore.instance
        .collection('/Perfiles')
        .document(_authenticatedUser.id)
        .collection('Data')
        .document('Live')
        .updateData({
      'onRoute': false,
    });
  }

//----------------------------------------------------------------------------------------------
//----------Update Bike Data--------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------

  int topSpeed = 0;
  int highTemp = 0;
  int lowTemp = 0;

  int temperature = 0;
  int humidity = 0;

// Update Module Data in DataBase
  //Temperature
  //Humidity
  Future<void> updateBlueData(BlueData blue) async {
    temperature = blue.temperatura;
    humidity = blue.humedad;
    if (highTemp < blue.temperatura) {
      highTemp = blue.temperatura;
      Firestore.instance
          .collection('/Perfiles')
          .document(_authenticatedUser.id)
          .collection('Rutas')
          .document(idRuta)
          .setData({'temperatura': highTemp}, merge: true);
    }

    Firestore.instance
        .collection('/Perfiles')
        .document(_authenticatedUser.id)
        .collection('Data')
        .document('Live')
        .setData({
      'temperatura': blue.temperatura,
      'humedad': blue.humedad,
      'state': "Okay"
    }, merge: true);
  }

//----------------------------------------------------------------------------------------------
//---------------Update Route Data------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------

  Future<void> updateRouteData(
      LatLng ubicacion,
      double speed,
      double heading,
      double distancia,
      double acceleration,
      DateTime timeStamp,
      double meters) async {
    DocumentReference routeLive = Firestore.instance
        .collection('/Perfiles')
        .document(_authenticatedUser.id);

    print("Velocidad: " + speed.toString());
    speed = speed == 0 ? 0.001 : speed;
    routeLive.collection('Data').document('Live').setData({
      'longitude': ubicacion.longitude,
      'latitude': ubicacion.latitude,
      'speed': speed,
      'acceleration': acceleration,
      'timeStamp': timeStamp,
      'distancia': distancia,
      'heading': heading,
      'onAlert': _onAlert,
      'onRoute': true,
    }, merge: true);
    if (meters == distancia) {
      routeLive
          .collection('Rutas')
          .document(idRuta)
          .collection('History')
          .document()
          .setData({
        'latitude': ubicacion.latitude,
        'longitude': ubicacion.longitude,
        'speed': speed,
        'timeStamp': timeStamp,
        'temperature': temperature,
        'humidity': humidity
      });
    }
    // routeLive.collection('Rutas').document(idRuta).setData({'data'})
  }

//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//----------------------Social Meet---------------------------------------------------------------------------------
//----------------------USERS FETCH---------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
//----------------Random PERFIL----------------------------------------------------
//---------------------------------------------------------------------------------

  User get perfilUsuario {
    return _perfil;
  }

  User _perfil;

  //Get a random User.
  Future<void> perfilSubscribe(String id) async {
    _isLoading = true;
    notifyListeners();
    User _perfilTemp;
    if (id == _authenticatedUser.id) {
      _perfil = _authenticatedUser;
    } else {
      if (_followingList.length > 0 &&
          _followingList.any((element) => element.id == id)) {
        _perfilTemp = _followingList.firstWhere((element) => element.id == id);
      } else if (_users.any((element) => element.id == id)) {
        _perfilTemp = _users.firstWhere((element) => element.id == id);
      }
      if (_perfilTemp != null) {
        _perfil = _perfilTemp;
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  List<User> _users = [];

  List<User> get usersGet {
    _users.removeWhere((element) => element.id == _authenticatedUser.id);
    return _users;
  }

  List<User> _topFriends = [];

  List<User> get topFriendsGet {
    return _topFriends;
  }

  List<User> _followingList = [];

  List<User> get followingListGet {
    //List of users im following. Full data.
    return _followingList;
  }

  List<User> _followersList = [];

  List<User> get followersListGet {
    //List of users im following. Full data.
    return _followersList;
  }

//.............................................................................
//.............................................................................
//.............................................................................
//.............................................................................
  bool _onRoute = false;

  bool get getOnRoute {
    return _onRoute;
  }

  bool _onAlert = false;

  bool get getOnAlert {
    return _onAlert;
  }
//.............................................................................
//.............................................................................

  Future<void> getStatus(index) {
    _isLoading = true;
    notifyListeners();
    Firestore.instance
        .collection('/Perfiles')
        .document(_topFriends[index].id)
        .collection('Data')
        .document('Live')
        .snapshots()
        .listen((event) {
      Map<String, dynamic> liveInfo = event.data;
      _onRoute = liveInfo['onRoute']; // ITS coming back null
      _onAlert = liveInfo['onAlert'];
      notifyListeners();
    });
    _isLoading = false;
    notifyListeners();
    return null;
  }

//----------------------------------------------------------------------------------------------
//-------------------------ADD CLOSEFRIEND------------------------------------------------------
//----------------------------------------------------------------------------------------------
  Future<void> addCloseFriend(String id, User perfil) async {
    print("ADD CLOSE FRIEND");

    DocumentReference emergencyRoute = Firestore.instance
        .collection('/Perfiles')
        .document(_authenticatedUser.id)
        .collection('Social')
        .document('Emergencie');
    int number = 1;

    emergencyRoute.get().then((value) {
      if (value.data.length < 3 && value.data.length > 0) {
        List<int> userList = [];
        value.data.forEach((key, value) {
          int _temp = int.parse(key.replaceAll("emergency", ""));
          userList.add(_temp);
        });
        userList.sort();
        number = userList[0] == 1
            ? 2
            : userList[0] == 2 ? 1 : userList[0] == 3 ? 1 : 2;
      }
      emergencyRoute.setData({
        "emergency" + number.toString(): perfil.id,
      }, merge: true);
      _perfil = User(
          id: perfil.id,
          nombre: perfil.nombre,
          auth: perfil.auth,
          email: perfil.email,
          bio: perfil.bio,
          username: perfil.username,
          direccion: perfil.direccion,
          imageUrl: perfil.imageUrl,
          imFollowing: perfil.imFollowing,
          emergTag: true);
      _topFriends.add(_perfil);
      notifyListeners();
    });
  }

  //--------------------------------------------------------------
  //----------REMOVE CLOSEFRIEND---------------------------------------
  //--------------------------------------------------------------
  void removeCloseFriend(String id, User perfil) {
    print("REMOVE CLOSE FRIEND");
    _isLoading = true;
    notifyListeners();

    DocumentReference emergencyRoute = Firestore.instance
        .collection('/Perfiles')
        .document(_authenticatedUser.id)
        .collection('Social')
        .document('Emergencie');

    emergencyRoute.get().then((value) {
      Map<String, dynamic> list = value.data;
      print("Remove Before: " + list.length.toString());
      list.removeWhere((key, value) => value == id);
      print("Remove After: " + list.length.toString());
      emergencyRoute.setData(list);
    });

    _perfil = User(
        id: perfil.id,
        nombre: perfil.nombre,
        auth: perfil.auth,
        email: perfil.email,
        bio: perfil.bio,
        username: perfil.username,
        direccion: perfil.direccion,
        imageUrl: perfil.imageUrl,
        imFollowing: perfil.imFollowing,
        emergTag: false);
    _isLoading = false;
    _topFriends.remove(perfil);
    notifyListeners();
  }

//---------------------------------------------------------------
//---------Fetch Emergency Contact-------------------------------
//---------------------------------------------------------------
  Future<void> fetchCloseFriends() async {
    print("Fetching CloseFriends");
    _isLoading = true;
    _topFriends.clear();
    notifyListeners();
    Firestore.instance
        .collection('/Perfiles')
        .document(_authenticatedUser.id)
        .collection('Social')
        .document('Emergencie')
        .get()
        .then((data) {
      Map<String, dynamic> fdata = data.data;
      if (fdata != null) {
        List<dynamic> keys = fdata.values.toList();
        for (var i = 0; i < fdata.values.length; i++) {
          if (keys[i].toString().length > 20) {
            Firestore.instance
                .collection('/Perfiles')
                .document(keys[i].toString())
                .get()
                .then((user) {
              final User _user = User(
                  id: user['id'],
                  auth: user['auth'],
                  email: user['email'],
                  token: user['token'],
                  nombre: user['nombre'],
                  bio: user['bio'],
                  username: user['username'],
                  direccion: user['direccion'],
                  imageUrl: user['imageUrl'],
                  imagePath: user['imagePath'],
                  imFollowing: true,
                  emergTag: true
                  // perfilId: data.documentID,
                  );
              _followingList[_followingList
                      .indexWhere((element) => element.id == _user.id)]
                  .emergTag = true;
              _topFriends.add(_user);
              notifyListeners();
            });
          }
        }
      }
      _isLoading = false;
      notifyListeners();
    });
    _isLoading = false;
    notifyListeners();
  }

//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
  Future<void> addFollow(String id, User perfil) async {
    print("Adding friend");
    _isLoading = true;
    notifyListeners();
    Firestore.instance
        .collection('/Perfiles')
        .document(_authenticatedUser.id)
        .collection('Social')
        .document('Siguiendo')
        .setData({
      perfil.id: perfil.id,
    }, merge: true).then((value) {
      Firestore.instance
          .collection('/Perfiles')
          .document(perfil.id)
          .collection('Social')
          .document('Seguidores')
          .setData({
        _authenticatedUser.id: _authenticatedUser.id,
      }, merge: true);
    });
    perfil.imFollowing = true;
    _followingList.add(perfil);
    _isLoading = false;
    notifyListeners();
  }

  //--------------------------------------------------------------
  //----------REMOVE FRIEND---------------------------------------
  //--------------------------------------------------------------
  void removeFollow(String id, User perfil) {
    print("Remove Follow");
    _isLoading = true;
    notifyListeners();
    Firestore.instance
        .collection('/Perfiles')
        .document(_authenticatedUser.id)
        .collection('Social')
        .document('Siguiendo')
        .updateData({id: FieldValue.delete()});
    Firestore.instance
        .collection('/Perfiles')
        .document(id)
        .collection('Social')
        .document('Seguidores')
        .updateData({_authenticatedUser.id: FieldValue.delete()});
    _followingList.removeWhere((value) => value.id == perfil.id);
    _isLoading = false;
    notifyListeners();
  }

//---------------------------------------------------------------
//---------------------------------------------------------------
//------Get from data base list of users in [_followingList------
//---------------------------------------------------------------
  Future<void> fetchFollowing() async {
    print("Fetching Following");
    _followingList.clear();
    _isLoading = true;
    notifyListeners();
    DocumentReference _followingDocRef = Firestore.instance
        .collection('/Perfiles')
        .document(_authenticatedUser.id)
        .collection('Social')
        .document('Siguiendo');
    _followingDocRef.get() //Lista de los usuario para el ID
        .then((data) {
      Map<String, dynamic> fdata = data.data;
      if (fdata != null) {
        List<dynamic> token = fdata.values.toList();
        for (var i = 0; i < fdata.values.length; i++) {
          if (token[i].toString().length > 20) // Verificar que el ID sea valido
          {
            Firestore.instance
                .collection('/Perfiles')
                .document(token[i].toString()) //Captura perfil con token
                .get()
                .then((user) async {
              final User _user = User(
                  id: user['id'],
                  auth: user['auth'],
                  email: user['email'],
                  token: user['token'],
                  nombre: user['nombre'],
                  bio: user['bio'],
                  username: user['username'],
                  direccion: user['direccion'],
                  imageUrl: user['imageUrl'],
                  imagePath: user['imagePath'],
                  imFollowing: true,
                  emergTag: false);
              _followingList.add(_user);
              notifyListeners();
            });
          }
        }
      }
      _isLoading = false;
      notifyListeners();
    });
    _isLoading = false;
    notifyListeners();
  }

//---------------------------------------------------------------
//---------------------------------------------------------------
//------Get from data base list of users in [_followersList------
//---------------------------------------------------------------
  Future<void> fetchFollowers() async {
    print("Fetching Followers");
    _followersList.clear();
    _isLoading = true;
    notifyListeners();
    DocumentReference _followersDocRef = Firestore.instance
        .collection('/Perfiles')
        .document(_authenticatedUser.id)
        .collection('Social')
        .document('Seguidores');
    _followersDocRef.get() //Lista de los usuario para el ID
        .then((data) {
      Map<String, dynamic> fdata = data.data;
      if (fdata != null) {
        List<dynamic> token = fdata.values.toList();
        for (var i = 0; i < fdata.values.length; i++) {
          if (token[i].toString().length > 20) // Verificar que el ID sea valido
          {
            Firestore.instance
                .collection('/Perfiles')
                .document(token[i].toString()) //Captura perfil con token
                .get()
                .then((user) async {
              final User _user = User(
                  id: user['id'],
                  auth: user['auth'],
                  email: user['email'],
                  token: user['token'],
                  nombre: user['nombre'],
                  bio: user['bio'],
                  username: user['username'],
                  direccion: user['direccion'],
                  imageUrl: user['imageUrl'],
                  imagePath: user['imagePath'],
                  imFollowing: _followingList.any((element) {
                    if (element.id == user['id']) {
                      return true;
                    } else {
                      return false;
                    }
                  }),
                  emergTag: false);
              _followersList.add(_user);
              notifyListeners();
            });
          }
        }
      }
      _isLoading = false;
      notifyListeners();
    });
    _isLoading = false;
    notifyListeners();
  }

  //--------------------------------------------------------------
  //----------Fetch Users-----------------------------------------
  //--------------------------------------------------------------
  //Querys the data of each followed user
  Future<void> fetchUsers() async {
    print("Fetching Users");
    _isLoading = true;
    _users.clear();
    notifyListeners();
    Firestore.instance.collection('/Perfiles').getDocuments().then((data) {
      if (data.documents.length != 0) {
        var users = data.documents;
        for (var i = 0; i < data.documents.length; i++) {
          final User _user = User(
            id: users[i]['id'],
            auth: users[i]['auth'],
            email: users[i]['email'],
            token: users[i]['token'],
            nombre: users[i]['nombre'],
            bio: users[i]['bio'],
            username: users[i]['username'],
            direccion: users[i]['direccion'],
            imageUrl: users[i]['imageUrl'],
            imagePath: users[i]['imagePath'],
            imFollowing: followingListGet
                .firstWhere((element) => element.id == users[i]['id'],
                    orElse: () => User(
                        email: users[i]['email'],
                        direccion: users[i]['direccion'],
                        id: users[i]['id'],
                        imFollowing: false))
                .imFollowing,
            emergTag: false,
            // perfilId: data.documentID,
          );
          _users.add(_user);
        }
      }
      _isLoading = false;
      notifyListeners();
    });
  }

//------------------------------------------------------------------------------------------------------------------
//----------------------USER FETCH----------------------------------------------------------------------------------
//----------------------AUTO LOGIN----------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------

  //----------------------------------------------------------
  //------------------------Get-User--------------------------
  //----------------------------------------------------------

  Future<void> userAuthFetch(String id) async {
    print('User Auth Fetch');
    _isLoading = true;
    notifyListeners();
    Firestore.instance.collection('/Perfiles').document(id).get().then((data) {
      if (data.data != null) {
        final User _userAuth = User(
          id: _authenticatedUser.id,
          auth: _authenticatedUser.auth,
          email: _authenticatedUser.email,
          token: _authenticatedUser.token,
          nombre: data.data['nombre'],
          bio: data.data['bio'],
          username: data.data['username'],
          direccion: data.data['direccion'],
          imageUrl: data.data['imageUrl'],
          imagePath: data.data['imagePath'],
          imFollowing: false,
          // perfilId: data.documentID,
        );
        _authenticatedUser = _userAuth;
        _perfil = _authenticatedUser;
        _isLoading = false;
        notifyListeners();
      }
    }).catchError((onError) {
      print(onError);
    });
  }

  PublishSubject<bool> get fireUserSubject {
    return _fireUserSubject;
  }

  Future<Map<String, dynamic>> uploadImageUser(File image,
      {String imagePath}) async {
    final mimeTypeData = lookupMimeType(image.path).split('/');

    final imageUploadRequest = http.MultipartRequest('POST',
        Uri.parse('https://us-central1_t3c_inc.cloudfunctions.net/storeImage'));
    final file = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType(
        mimeTypeData[0],
        mimeTypeData[1],
      ),
    );
    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }
    imageUploadRequest.headers['Authorization'] =
        'Bearer ${_authenticatedUser.token}';

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Something went wrong');
        return null;
      }
      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<String> uploadImageStore(File image, {String imagePath}) async {
    print("Inside FIrebase Store");
    final String _userId = _authenticatedUser.id;
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child("userImages/$_userId");
    final StorageUploadTask uploadTask = storageReference.putFile(image);
    final StorageTaskSnapshot downloadUrl = await uploadTask.onComplete;
    final String url = await downloadUrl.ref.getDownloadURL();

    return url;
  }

  Future<bool> updateUser(
    String nombre,
    String bio,
    String username,
    String direccion,
    File image,
  ) async {
    print("email::::");
    print(_authenticatedUser.email);
    final String email = _authenticatedUser.email;
    final String id = _authenticatedUser.id;
    final bool auth = true;
    String imageUrl;
    String imagePath;
    if (_authenticatedUser.imageUrl == null) {
      imageUrl =
          'https://firebasestorage.googleapis.com/v0/b/t3c-inc.appspot.com/o/images%2Fno-image.jpg?alt=media&token=f2c97f47-4137-4484-bb56-4114747df84b';
      imagePath = 'images/no-image.jpg';
    } else {
      imageUrl = _authenticatedUser.imageUrl;
      imagePath = _authenticatedUser.imagePath;
    }

    if (image != null) {
      print("Hay Imagen (URL): ");
      final uploadData = await uploadImageStore(image);
      imageUrl = uploadData;
    }

    bool status = await Firestore.instance
        .collection('/Perfiles')
        .document(id)
        .updateData({
      'auth': auth,
      'nombre': nombre,
      'bio': bio,
      'username': username,
      'direccion': direccion,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
    }).then((value) {
      _isLoading = false;
      print('Updated Perfil');
      notifyListeners();
      return true;
    }).catchError((e) {
      print('error StoreUser');
      print(e);
    });
    final User _userInfo = User(
      id: _authenticatedUser.id,
      auth: _authenticatedUser.auth,
      email: email,
      token: _authenticatedUser.token,
      nombre: nombre,
      bio: bio,
      username: username,
      direccion: _authenticatedUser.direccion,
      imageUrl: imageUrl,
      imagePath: imagePath,
    );
    _authenticatedUser = _userInfo;
    notifyListeners();
    return status;
  }

//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
//-----------------USER-LOGIN---------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------
//--------------------REGISTRATION----------------------------------------------------------------------------------
//--------------------AUTHENTICATION--------------------------------------------------------------------------------
//--------------------LOG-OUT---------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------

  bool newUser = true;

  bool get newUserStat {
    return newUser;
  }

  Future logOut(BuildContext context) async {
    fireUserSubject.add(false);
    _authenticatedUser = null;
    _users = [];
    _followingList = [];
    _perfil = null;
    notifyListeners();
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> autoLogin() async {
    _isLoading = true;
    notifyListeners();
    FirebaseUser user =
        await FirebaseAuth.instance.currentUser().catchError((error) {
      print("AutoLogin Error Log:");
      print(error);
    });
    if (user != null) {
      String uid = user.uid;
      var tokenRAW = await user.getIdToken();
      final String token = tokenRAW.token.toString();
      // print("Provider token: " + token);
      // print("Provider id: " + uid);
      fireUserSubject.add(true);
      notifyListeners();
      Firestore.instance
          .collection('/Perfiles')
          .document(uid)
          .get()
          .catchError((onError) {
        print("ERROR AUTOLOGIN");
      }).then((data) {
        if (data.data != null) {
          _authenticatedUser = User(
            id: uid,
            auth: true,
            email: data.data['email'],
            token: token,
            nombre: data.data['nombre'],
            bio: data.data['bio'],
            username: data.data['username'],
            direccion: data.data['direccion'],
            imageUrl: data.data['imageUrl'],
            imagePath: data.data['imagePath'],
          );
          _perfil = _authenticatedUser;
          _isLoading = false;
          fireUserSubject.add(true);
          notifyListeners();
        } else {
          _authenticatedUser = User(
              id: uid,
              auth: false,
              email: data.data['email'],
              token: token,
              direccion: "MEXICO");
        }
      });
      return null;
    }
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future registration(
      String _email, String _password, BuildContext context) async {
    print("Dentro");
    _isLoading = true;
    notifyListeners();
    print(_email);
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: _email, password: _password)
        .then((actualUser) async {
      FirebaseUser user = actualUser.user;
      var tokenRAW = user.getIdToken();
      IdTokenResult token = await tokenRAW;
      _authenticatedUser = User(
        id: user.uid,
        email: user.email,
        auth: true,
        token: token.toString(),
        direccion: 'NUEVO',
      );
      notifyListeners();
      _fireUserSubject.add(true);
      _isLoading = false;
      notifyListeners();
      print('------New-User-------');
      print(_authenticatedUser.email);
      print(_authenticatedUser.token.toString());
      print('Under:');
      Firestore.instance
          .collection('/Perfiles')
          .document(_authenticatedUser.id)
          .setData({
        'email': _email,
        'id': _authenticatedUser.id,
      }).catchError((onError) {
        print(onError);
      });
      print("Launching::");
      Navigator.pushReplacementNamed(context, '/editPerfil');
    }).catchError((e) {
      print("Errrorr");
      print(e);
      String errorType = 'Error';
      switch (e.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          errorType = 'El Email no existe';
          break;
        case 'The password is invalid or the user does not have a password.':
          errorType = 'La contraseña no es la correcta';
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          errorType = 'Algun error';
          break;
        case 'The email address is already in use by another account.':
          errorType = 'El email ya esta siendo usado';
          break;
      }
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Un Error ocurrio"),
              content: Text(errorType),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    _isLoading = false;
                    notifyListeners();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
      _isLoading = false;
      notifyListeners();
    });
  }

  Future authentication(
      String _email, String _password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: _email, password: _password)
        .then((actualUser) async {
      FirebaseUser user = actualUser.user;
      var tokenRAW = user.getIdToken();
      IdTokenResult token = await tokenRAW;
      _fireUserSubject.add(true);
      newUser = false;
      _isLoading = false;
      // print("User EMAIL:");
      // print(user.email);
      _authenticatedUser = User(
          id: user.uid,
          auth: true,
          email: user.email,
          direccion: 'LOADING',
          token: token.toString());
      // notifyListeners();
      // print('---------User--------');
      // print(_authenticatedUser.email);
      // print(_authenticatedUser.token);
      // print('Over:');
      userAuthFetch(_authenticatedUser.id);
    }).catchError((e) {
      print(e);
      String errorType = 'Error';
      switch (e.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          errorType = 'El Email no existe';
          break;
        case 'The password is invalid or the user does not have a password.':
          errorType = 'La contraseña no es la correcta';
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          errorType = 'Algun error';
          break;
      }
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Un Error ocurrio"),
              content: Text(errorType),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    _isLoading = false;
                    notifyListeners();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
      _isLoading = false;
      notifyListeners();
    });
  }

  void initiateFacebookLogin(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    print("Inside Facebook");
    var facebookLogin = FacebookLogin();
    var facebookLoginResult = await facebookLogin.logIn(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.width(800).height(800)&access_token=${facebookLoginResult.accessToken.token}');

        var profile = json.decode(graphResponse.body);
        final AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: facebookLoginResult.accessToken.token);
        FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((actualUser) async {
          FirebaseUser user = actualUser.user;
          print("Actual User:");
          print(user.displayName);
          final User _userAuth = User(
              id: user.uid,
              email: profile['email'],
              token: facebookLoginResult.accessToken.token,
              nombre: profile['name'],
              imageUrl: profile['picture']['data']['url'],
              auth: true,
              direccion: "empty");
          print(_userAuth.id);
          Query fetch = Firestore.instance
              .collection('/Perfiles')
              .where('id', isEqualTo: _userAuth.id);
          QuerySnapshot fetchedSnaps = await fetch.getDocuments();
          if (fetchedSnaps.documents.length == 0) {
            print("Empty");
            Firestore.instance
                .collection('/Perfiles')
                .document(_userAuth.id)
                .setData({
              'email': _userAuth.email,
              'id': _userAuth.id,
              'imageUrl': _userAuth.imageUrl,
            }).catchError((onError) {
              print("ON FACEBOOK LOGIN ERROR:");
              print(onError);
            });
          }
          _authenticatedUser = _userAuth;
          _fireUserSubject.add(true);
        });
        _isLoading = false;
        notifyListeners();
        break;
      default:
        print("default");
    }
  }

  User get authUser {
    return _authenticatedUser;
  }

  //Top friends
  int topFriends = 5;

  int get getTopFriends {
    return topFriends;
  }
}
