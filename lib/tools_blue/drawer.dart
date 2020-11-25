import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
// import 'package:url_launcher/url_launcher.dart';

import 'package:blue/models/main_scope.dart';

Widget _usuarioTab(MainModel model, context) {
  return model.authUser.nombre != null
      ? GestureDetector(
          child: ListTile(
            trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(context, '/editPerfil');
                }),
            leading: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  model.authUser.imageUrl,
                )),
            title: Text(model.authUser.nombre, textScaleFactor: 1.7),
          ),
          onTap: () {
            model.perfilSubscribe(model.authUser.id);
            Navigator.pushNamed(context, '/user');
          },
        )
      : ListTile(title: Text("Sin Usuario"));
}

Widget blue_drawer(BuildContext context, int page) {
  return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
    return Drawer(
      child: Center(
          child: ListView(
        children: <Widget>[
          SizedBox(
            height: 70,
          ),
          _usuarioTab(model, context),
          SizedBox(
            height: 30,
          ),
          _topFriendsPage(model, page, context),
          // Divider(),
          // _viajeTab(model, page, context),
          _calendarioPage(model, page, context),
          _agregarAmigos(model, page, context),
          // Divider(),
          SizedBox(
            height: 40,
          ),
          // _editarPerfilTab(model, page, context),
          _connectTab(model, page, context),
          _settingsTab(model, page, context),
          _logoutTab(model, page, context),
        ],
      )),
    );
  });
}

Widget _viajeTab(model, page, context) {
  return GestureDetector(
    child: ListTile(
      leading: Icon(
        page == 2 ? Icons.home : Icons.child_friendly,
        size: 30,
      ),
      title: page == 2 ? Text("Casa") : Text("Comenzar Ruta"),
      onTap: () {
        page == 0
            ? Navigator.pushNamed(context, '/viaje')
            : Navigator.pushNamed(context, '/');
      },
    ),
  );
}

Widget _agregarAmigos(model, page, context) {
  return GestureDetector(
    child: ListTile(
      leading: Icon(
        Icons.group_add,
        color: Colors.grey,
        size: 30,
      ),
      title: Text("Social Meet"),
      onTap: () {
        Navigator.pushNamed(context, '/Social');
      },
    ),
  );
}

Widget _calendarioPage(model, page, context) {
  return GestureDetector(
    child: ListTile(
      leading: Icon(
        Icons.calendar_today,
        color: Colors.grey,
        size: 30,
      ),
      title: Text("Calendario"),
      onTap: () {
        model.fetchEvents();
        Navigator.pushNamed(context, '/Calendario');
      },
    ),
  );
}

Widget _topFriendsPage(model, page, context) {
  return GestureDetector(
    child: ListTile(
      leading: Icon(
        Icons.loyalty,
        color: Colors.grey,
        size: 30,
      ),
      title: Text("Contactos de Emergencia"),
      onTap: () {
        model.fetchEvents();
        Navigator.pushNamed(context, '/topFriends');
      },
    ),
  );
}

Widget _editarPerfilTab(model, page, context) {
  return GestureDetector(
    child: ListTile(
      leading: Icon(
        Icons.edit,
        color: Colors.grey,
        size: 30,
      ),
      title: Text("Editar Perfil"),
      onTap: () {
        Navigator.pushNamed(context, '/editPerfil');
      },
    ),
  );
}

Widget _connectTab(model, page, context) {
  return GestureDetector(
    child: ListTile(
      leading: Icon(
        page == 1 ? Icons.home : Icons.bluetooth_connected,
        color: Colors.purple,
        size: 30,
      ),
      title: page == 1 ? Text("Casa") : Text("Conectar Modulos"),
      onTap: () {
        page == 1
            ? Navigator.pushNamed(context, '/')
            : Navigator.pushNamed(context, '/modules');
      },
    ),
  );
}

Widget _settingsTab(MainModel model, page, context) {
  return GestureDetector(
    child: ListTile(
      leading: Icon(
        Icons.settings,
        color: Colors.purple,
        size: 30,
      ),
      title: Text("Ajustes"),
      onTap: () {
        Navigator.pushNamed(context, '/ajustes');
      },
    ),
  );
}

Widget _logoutTab(MainModel model, page, context) {
  return GestureDetector(
    child: ListTile(
      leading: Icon(
        Icons.exit_to_app,
        color: Colors.purple,
        size: 30,
      ),
      title: Text("Log Out"),
      onTap: () {
        model.logOut(context);
      },
    ),
  );
}
