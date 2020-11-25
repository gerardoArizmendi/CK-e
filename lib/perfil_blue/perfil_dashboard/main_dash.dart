// import 'package:blue/pages/routeTools/geoLocation.dart';
import 'package:blue/pages/RouteTools/routes_Page.dart';
import 'package:blue/perfil_blue/perfil_dashboard/perfil_card.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:blue/models/user.dart';
import 'package:blue/models/main_scope.dart';

class PerfilPage extends StatefulWidget {
  final MainModel model;
  PerfilPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _PerfilPageState();
  }
}

class _PerfilPageState extends State<PerfilPage> {
  User perfil;
  String _previewImageUrl;
  LatLng locData;

  @override
  void initState() {
    print("Fetching User-");
    setState(() {
      perfil = widget.model.perfilUsuario;
    });
    widget.model.fetchRoutes(perfil.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: ((perfil.nombre == null) && (perfil.imageUrl == null))
            ? PerfilCard(perfil)
            : DefaultTabController(
                length: 2,
                child: NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverList(
                            delegate: SliverChildListDelegate([
                          Container(
                            height: 234,
                            child: PerfilCard(perfil),
                          ),
                        ])),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverAppBarDelegate(
                            TabBar(
                              labelColor: Colors.blueGrey,
                              indicatorColor: Colors.blueGrey,
                              unselectedLabelColor: Colors.black,
                              tabs: [
                                Tab(icon: Icon(Icons.info), text: "Rutas"),
                                Tab(
                                    icon: Icon(Icons.favorite),
                                    text: "Publicaciones"),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                    body: new TabBarView(children: <Widget>[
                      RoutesPage(perfil),
                      Scaffold(body: Center(child: Text("Publicaciones")))
                      // Scaffold(body: Center(child: Text("Las Rides")))
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
