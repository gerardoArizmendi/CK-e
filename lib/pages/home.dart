import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:blue/models/message.dart';
import 'package:blue/pages/calendarioTools/calendario_builder.dart';
import 'package:blue/pages/publicacionesTool/postList_builder.dart';
import 'package:blue/perfil_blue/user_Interface.dart';
import 'package:blue/tools_blue/butons_action.dart';
import 'package:blue/tools_blue/drawer.dart';
import 'package:blue/tools_blue/floating_action.dart';

import 'package:blue/models/main_scope.dart';
import 'package:blue/pages/dashboard.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  Home({Key key, this.model, this.title}) : super(key: key);

  final MainModel model;
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  bool user = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Message> messages = [];

  @override
  void initState() {
    // widget.model.perfilSubscribe(widget.model.authUser.id);
    user = widget.model.authUser.nombre != null;
    // devices = widget.model.blueDevices;
    // widget.model.fetchEvents(onlyForUser: true, onlyPosts: false);
    widget.model.fetchFollowing().then((value) {
      widget.model.fetchCloseFriends();
      widget.model.fetchRoutes(widget.model.authUser.id);
    });

    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      final notification = message['notification'];
      print("onMessage: " + notification['title']);
      setState(() {
        messages.add(
            Message(title: notification['title'], body: notification['body']));
      });
    }, onLaunch: (Map<String, dynamic> message) async {
      final notification = message['data'];
      print("onLaunch:" + '$message');
      setState(() {
        messages.add(
            Message(title: notification['title'], body: notification['body']));
      });
    }, onResume: (Map<String, dynamic> message) async {
      final notification = message['data'];
      print("onResume" + "$message");
      print("Title:" + notification['title']);
      print("Body:" + notification['body']);
      setState(() {
        messages.add(Message(title: '$message', body: notification['body']));
      });
    });

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.getToken().then((token) {
      widget.model.updateToken(token);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        initialIndex: 0,
        child: Scaffold(
            backgroundColor: Colors.lightBlue[900],
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.lightBlue[900],
              title: Text(
                "CKe",
                style: GoogleFonts.roboto(fontSize: 28, color: Colors.white),
              ),
              actions: <Widget>[
                Stack(children: [
                  Container(
                      width: 30,
                      height: 30,
                      decoration: new BoxDecoration(
                          color: Colors.lightBlue[900],
                          shape: BoxShape.circle)),
                  IconButton(
                      icon: Icon(Icons.message),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Buzon de Alertas"),
                                content: Column(
                                  children: <Widget>[
                                    Row(children: [
                                      Text("OKay"),
                                      IconButton(
                                          icon: Icon(Icons.check),
                                          onPressed: null)
                                    ]),
                                    Text("OKay"),
                                    Text("OKay"),
                                    Text("OKay"),
                                  ],
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('Okay'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            });
                      }),
                ])
              ],
            ),
            drawer: blue_drawer(context, 0),
            bottomNavigationBar: TabBar(
                unselectedLabelColor: Colors.blue[50],
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.blue[200], Colors.blue[200]]),
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.lightBlue[900]),
                tabs: <Widget>[
                  Tab(
                    icon: Icon(Icons.home),
                  ),
                  Tab(
                    icon: Icon(Icons.developer_board),
                  ),
                  Tab(
                    icon: Icon(Icons.calendar_today),
                  ),
                  Tab(
                    icon: Icon(Icons.account_box),
                  )
                ],
                indicatorColor: Colors.white,
                labelColor: Colors.white),
            body: TabBarView(
              children: <Widget>[
                DashBoard(),
                PostList(widget.model),
                CalendarioList(widget.model),
                UserPage(widget.model)
              ],
            ),
            floatingActionButton: FloatingAction()));
  }
}
