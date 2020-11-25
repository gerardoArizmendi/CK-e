import 'package:flutter/material.dart';

import 'package:photo_view/photo_view.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:blue/models/main_scope.dart';

import 'package:blue/models/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final int index;

  UserCard(this.user, this.index);

  //--------------------------------------------------------
  //--------------------------------------------------------
  //--------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Divider(
                indent: 10,
              ),
              GestureDetector(
                child: ListTile(
                    trailing: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.deepPurple[300], width: 2),
                          borderRadius: BorderRadius.circular(5),
                          shape: BoxShape.rectangle),
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: FlatButton(
                              onPressed: () {
                                _settingModelBottomSheet(context, user, model);
                              },
                              child: user.imFollowing
                                  ? Text(
                                      "Siguiendo",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : Text(
                                      "Seguir",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ))),
                    ),
                    leading: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          user.imageUrl,
                        )),
                    title: user.nombre != null
                        ? Text(
                            user.nombre,
                            textScaleFactor: 1.2,
                          )
                        : Text(
                            user.id,
                            maxLines: 5,
                          )),
                onTap: () {
                  print("INSIDE CARD");
                  print(user.id);
                  Navigator.pushNamed(context, '/perfil/' + user.id);
                },
                onLongPress: () {
                  print("Long Press");
                  model.addFollow(user.id, user);
                },
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        );
      },
    );
  }
}

void _settingModelBottomSheet(
    BuildContext context, User user, MainModel model) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
            child: new Wrap(
          children: <Widget>[
            new ListTile(
                title: user.imFollowing
                    ? Text("Dejar de seguir",
                        style: TextStyle(color: Colors.red))
                    : Text("Seguir"),
                onTap: () {
                  Navigator.pop(context);
                  user = user.imFollowing
                      ? remove(user, model)
                      : follow(user, model);
                }),
            new ListTile(
              title: Text("Mandar Mensaje"),
              onTap: () {},
            ),
            new Container(
                color: Colors.red[400],
                child: ListTile(
                  title: Text("Bloquear"),
                  onTap: () {},
                )),
          ],
        ));
      });
}

User remove(User user, MainModel model) {
  model.removeFollow(user.id, user);
  user.imFollowing = false;
  return user;
}

User follow(User user, MainModel model) {
  model.addFollow(user.id, user);
  user.imFollowing = true;
  return user;
}
