import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:blue/tools_blue/butons_action.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:blue/models/main_scope.dart';
import 'package:blue/models/user.dart';

//Tarjeta de Perfil

class PerfilCard extends StatelessWidget {
  final User perfil;

  PerfilCard(this.perfil);

  Widget _buildUserData(context) {
    Widget container = Text("Soy Cicilist");
    if (perfil.bio != null) {
      container = Container(
          padding: EdgeInsets.only(top: 10.0),
          margin: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    perfil.imageUrl,
                  )),
              SizedBox(
                width: 15,
              ),
              Text(perfil.nombre,
                  textScaleFactor: 1.6,
                  style:
                      GoogleFonts.montserrat(fontSize: 22, color: Colors.white))
            ],
          ));
    }
    return container;
  }

  Widget _buildSocialData(context, MainModel model) {
    TextStyle _numberStyle = TextStyle(color: Colors.deepPurple, fontSize: 21);
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      perfil.id != model.authUser.id
          ? (ActionButton(model))
          : SizedBox(
              width: 30,
            ),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            child: Seguidores(perfil),
            onTap: () {
              if (model.authUser.id == perfil.id) {
                Navigator.pushNamed(context, '/Followers');
              }
            },
          ),
          Text("Seguidores",
              style: GoogleFonts.roboto(fontSize: 17, color: Colors.white)),
        ],
      ),
      SizedBox(
        width: 20,
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            child: Siguiendo(perfil),
            onTap: () {
              if (model.authUser.id == perfil.id) {
                Navigator.pushNamed(context, '/Following');
              }
            },
          ),
          Text("Siguiendo",
              style: GoogleFonts.roboto(fontSize: 17, color: Colors.white)),
        ],
      ),
      SizedBox(
        width: 20,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Container(
            color: Colors.lightBlue[900],
            child: Column(
              children: <Widget>[
                _buildUserData(context),
                Divider(color: Colors.black),
                _buildSocialData(context, model),
                SizedBox(
                  height: 20,
                )
              ],
            ));
      },
    );
  }
}

///--------------------------------------------------------------------------
///--------------------------------------------------------------------------
///--------------------------------------------------------------------------
///--------------------------------------------------------------------------

class Siguiendo extends StatefulWidget {
  final User user;
  Siguiendo(this.user);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SiguiendoState();
  }
}

class _SiguiendoState extends State<Siguiendo> {
  String siguiendo = "0";

  @override
  Widget build(BuildContext context) {
    Firestore.instance
        .collection('/Perfiles')
        .document(widget.user.id)
        .collection('Social')
        .document('Siguiendo')
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          value.data != null
              ? siguiendo = value.data.length.toString()
              : siguiendo = "0";
        });
      }
    });
    // TODO: implement build
    return Text(siguiendo,
        style: GoogleFonts.roboto(fontSize: 20, color: Colors.white));
  }
}

///--------------------------------------------------------------------------
///--------------------------------------------------------------------------
///--------------------------------------------------------------------------
///--------------------------------------------------------------------------
class Seguidores extends StatefulWidget {
  final User user;
  Seguidores(this.user);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SeguidoresState();
  }
}

class _SeguidoresState extends State<Seguidores> {
  String seguidores = "0";

  @override
  Widget build(BuildContext context) {
    Firestore.instance
        .collection('/Perfiles')
        .document(widget.user.id)
        .collection('Social')
        .document('Seguidores')
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          value.data != null
              ? seguidores = value.data.length.toString()
              : seguidores = "0";
        });
      }
    });
    return Text(
      seguidores,
      style: GoogleFonts.roboto(fontSize: 20, color: Colors.white),
    );
  }
}
