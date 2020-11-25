import 'package:blue/models/user.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:blue/models/main_scope.dart';
import 'package:blue/models/evento.dart';

class PostList extends StatefulWidget {
  final MainModel model;

  PostList(this.model);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PostListState();
  }
}

class _PostListState extends State<PostList> {
  @override
  void initState() {
    widget.model.fetchEvents(onlyForUser: false);
    super.initState();
  }

  //Creates the page ListView item with all the posts.
  //Desicion maker due to the post by the user.
  Widget _pageFeed(List<Evento> _publicaciones) {
    _publicaciones.sort((a, b) {
      return b.timeStart.compareTo(a.timeStart);
    });
    print("Publicaciones Length: " + _publicaciones.length.toString());
    Widget content = Text("No hay publicaciones");
    if (_publicaciones.length > 0) {
      content = ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            String tiempoDesde = '1997';
            var date = _publicaciones[index].timeStart;
            final dateNow = new DateTime.now();
            final dateTimeSincePost = dateNow.difference(date).inMinutes;
            if (dateTimeSincePost < 60) {
              tiempoDesde = (dateTimeSincePost.toString()) + ' min';
            } else if (dateTimeSincePost <= 1440) {
              tiempoDesde =
                  ((dateTimeSincePost / 60).round().toString()) + ' hrs';
            } else if (dateTimeSincePost <= 10080) {
              tiempoDesde =
                  ((dateTimeSincePost / 1440).round().toString()) + ' dias';
            } else {
              tiempoDesde = DateFormat('kk:mm - dd-MM-yyyy').format(date);
            }
            List<User> _users = [];
            User _userData;
            User _authUser = widget.model.authUser;
            _users = widget.model.followingListGet;
            int idIndex = _users.indexWhere(
                (element) => element.id == _publicaciones[index].userId);
            if (idIndex == -1) {
              print("Publicacion de usuario");
              _userData = _authUser;
            } else {
              _userData = widget.model.followingListGet[idIndex];
            }
            return Card(
              child: Container(
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: CircleAvatar(
                          backgroundImage: NetworkImage(_userData.imageUrl),
                          radius: 25),
                    ),
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(_userData.nombre,
                              style: GoogleFonts.rubik(
                                  fontSize: 17, fontWeight: FontWeight.w500)),
                          Text(tiempoDesde,
                              style: GoogleFonts.rubik(fontSize: 12)),
                          SizedBox(
                            height: 10,
                          ),
                          Text(_publicaciones[index].descripcion,
                              style: GoogleFonts.rubik(fontSize: 18)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: _publicaciones.length);
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
            body: RefreshIndicator(
                child: Center(
                  child: model.isLoading
                      ? CircularProgressIndicator()
                      : Container(child: _pageFeed(model.getPublicaciones)),
                ),
                onRefresh: model.fetchEvents));
      },
    );
  }
}
