import 'package:blue/pages/RouteTools/routes_Page.dart';
import 'package:blue/perfil_blue/perfil_dashboard/perfil_card.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
// import 'package:sigma_tec/pages/Pestanas/FirePost/Walls/faved_gene.dart';

import 'package:blue/models/user.dart';
import 'package:blue/models/main_scope.dart';

class UserPage extends StatefulWidget {
  final MainModel model;
  UserPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _UserPageState();
  }
}

class _UserPageState extends State<UserPage>
    with SingleTickerProviderStateMixin {
  User perfil;
  TabController controller;

  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    setState(() {
      perfil = widget.model.authUser;
    });
    widget.model.fetchRoutes(perfil.id);
    super.initState();
  }

  Widget _buildUser(BuildContext context, User perfil, MainModel model) {
    Widget content = Center(
        child: RaisedButton(
            child: Text('Crea tu perfil'),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/editPerfil');
            }));
    if (model.authUser.nombre != null && !model.isLoading) {
      content = PerfilCard(perfil);
    } else if (model.isLoading) {
      content = Center(child: Container(child: Text('Im Loading')));
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return widget.model.isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: Colors.lightBlue[900],
            body: ((perfil.nombre == null) && (perfil.imageUrl == null))
                ? _buildUser(context, perfil, widget.model)
                : DefaultTabController(
                    length: 2,
                    child: NestedScrollView(
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          return <Widget>[
                            SliverList(
                                delegate: SliverChildListDelegate([
                              Container(
                                  color: Colors.lightBlue[900],
                                  child:
                                      _buildUser(context, perfil, widget.model))
                            ])),
                            SliverPersistentHeader(
                              pinned: false,
                              delegate: _SliverAppBarDelegate(
                                TabBar(
                                  unselectedLabelColor: Colors.black54,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator:
                                      BoxDecoration(color: Colors.blueGrey),
                                  controller: controller,
                                  labelColor: Colors.white,
                                  indicatorColor: Colors.black,
                                  tabs: [
                                    Tab(icon: Icon(Icons.info), text: "Posts"),
                                    Tab(
                                        icon: Icon(Icons.favorite),
                                        text: "Favs"),
                                  ],
                                ),
                              ),
                            ),
                          ];
                        },
                        body: new TabBarView(children: <Widget>[
                          RoutesPage(perfil),
                          // Scaffold(body: Center(child: Text("Hey there 1"))),
                          Scaffold(body: Center(child: Text("Hey there 2")))
                        ]))));
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
