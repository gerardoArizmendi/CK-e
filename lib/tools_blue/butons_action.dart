import 'package:blue/models/user.dart';
import 'package:blue/models/main_scope.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoped_model/scoped_model.dart';

class ActionButton extends StatefulWidget {
  final MainModel model;
  ActionButton(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ActionButtonState();
  }
}

class _ActionButtonState extends State<ActionButton> {
  User perfil;

  @override
  void initState() {
    print("Fetching User");
    setState(() {
      perfil = widget.model.perfilUsuario;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.isLoading
          ? CircularProgressIndicator()
          : perfil.id == model.authUser.id
              ? IconButton(icon: Icon(Icons.edit), onPressed: null)
              : Padding(
                  padding: EdgeInsets.only(right: perfil.imFollowing ? 20 : 60),
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FlatButton(
                                child: Text(
                                  perfil.imFollowing
                                      ? "Dejar de Seguir"
                                      : "Seguir",
                                  style: GoogleFonts.roboto(fontSize: 14),
                                ),
                                onPressed: () {
                                  setState(() {
                                    perfil.imFollowing = !perfil.imFollowing;
                                  });
                                  !perfil.imFollowing
                                      ? model.removeFollow(perfil.id, perfil)
                                      : model.addFollow(perfil.id, perfil);
                                }),
                            IconButton(
                                icon: Icon(perfil.emergTag
                                    ? Icons.cancel
                                    : Icons.contacts),
                                onPressed: () {
                                  !perfil.emergTag
                                      ? model.addCloseFriend(perfil.id, perfil)
                                      : model.removeCloseFriend(
                                          perfil.id, perfil);
                                  setState(() {
                                    perfil.emergTag = !perfil.emergTag;
                                  });
                                }),
                          ])));
    });
  }
}
