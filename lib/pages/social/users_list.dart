import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:blue/pages/social/social.dart';
import 'package:blue/models/main_scope.dart';

class AllUsersPage extends StatefulWidget {
  final MainModel model;
  AllUsersPage(this.model);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AllUsersPageState();
  }
}

class _AllUsersPageState extends State<AllUsersPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.model.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          appBar: AppBar(),
          body: Center(
              child: model.isLoading
                  ? Container(
                      margin: EdgeInsets.all(20),
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator())
                  : UserList()));
    });
  }
}
