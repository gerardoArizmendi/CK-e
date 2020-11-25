import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:blue/models/main_scope.dart';
import 'package:blue/pages/calendarioTools/calendario.dart';
import 'package:blue/pages/calendarioTools/calendario_list.dart';

//Complete Page dedicated to the Calendar,
//Acces through the Drawer
class CalendarioBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          appBar: AppBar(
            title: Text("Calendario"),
          ),
          body: model.isLoading
              ? Center(child: CircularProgressIndicator())
              : Calendario(model));
    });
  }
}

//The page at the homescreen
class CalendarioList extends StatefulWidget {
  final MainModel model;

  CalendarioList(this.model);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CalendarioListState();
  }
}

class _CalendarioListState extends State<CalendarioList> {
  @override
  void initState() {
    widget.model.fetchEvents(onlyForUser: true, onlyPosts: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          backgroundColor: Colors.blueGrey[50],
          body: model.isLoading
              ? Center(child: CircularProgressIndicator())
              : CalendarioListBuilder(model));
    });
  }
}
