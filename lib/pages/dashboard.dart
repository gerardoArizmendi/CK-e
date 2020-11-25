import 'dart:async';

import 'package:blue/pages/RouteTools/tools/panels.dart';
import 'package:blue/pages/calendarioTools/calendario_widget.dart';
import 'package:blue/perfil_blue/Formato_perfil/close_friend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:blue/models/main_scope.dart';
import 'package:blue/models/user.dart';

class DashBoard extends StatefulWidget {
  final MainModel model;
  final String title;

  DashBoard({this.model, this.title});

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<DashBoard> {
  List<BluetoothDevice> devices = [];
  List<User> contacts = [];

  double speed = 22.0;
  double acceleration = 12.2;
  double distance = 222.0;

  @override
  initState() {
    // contacts = widget.model.getContacts;
    super.initState();
  }

  Widget _followingWidget(MainModel model) {
    Widget list = Padding(
        padding: EdgeInsets.only(left: 20),
        child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/Social');
            },
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 2.0),
                    color: Colors.blueGrey[400],
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                child: Padding(
                    padding: EdgeInsets.all(9),
                    child: Container(
                        child: Text('Sigue a Alguien',
                            style: GoogleFonts.openSans(
                                fontSize: 19,
                                fontWeight: FontWeight.bold)))))));
    if (model.followingListGet.length > 0) {
      list = ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          Widget content =
              FollowingList(model.followingListGet[index], index, context);
          return content;
        },
        itemCount: model.followingListGet.length,
      );
    }
    return model.isLoading
        ? CircularProgressIndicator()
        : Container(
            width: double.maxFinite,
            height: 130,
            child: list,
          );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      return NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverList(
                  delegate: SliverChildListDelegate([
                Container(
                  child: _followingWidget(model),
                ),
                Container(
                    height: model.blueDevices.length == 0 ? 0 : 40,
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        Widget devices = Text("Sin Modulos Conectados");
                        if (model.blueDevices.length > 0) {
                          devices = Center(
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(model.blueDevices[index].name),
                                            SizedBox(width: 10),
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 20,
                                            )
                                          ]))));
                        }
                        return devices;
                      },
                      itemCount: model.blueDevices.length,
                    ))
              ])),
            ];
          },
          body: RefreshIndicator(
              displacement: 2.2,
              child: Column(children: [
                Expanded(
                    child: (model.isLoadingRoutes || model.getEventos == null)
                        ? CircularProgressIndicator()
                        : TraveledPanels(model)),
                Expanded(flex: 3, child: CalendarioWidget()),
              ]),
              onRefresh: model.refreshDashboard));
    });
  }
}
