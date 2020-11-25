import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:blue/models/main_scope.dart';
import 'package:blue/pages/social/user_card.dart';
import 'package:blue/pages/social/users_page.dart';

class MySocial extends StatefulWidget {
  final MainModel model;

  MySocial(this.model);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SocialState();
  }
}

class _SocialState extends State<MySocial> {
  @override
  void initState() {
    super.initState();
    widget.model.fetchFollowing().then((value) {
      widget.model.fetchCloseFriends();
    });
  }

  Future<bool> _willPopCallBack() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Social Meet"),
              actions: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.people,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return AllUsersPage(model);
                      }));
                    })
              ],
            ),
            body: SafeArea(
                child: Center(
              child: Column(children: [
                Expanded(child: FollowingListPage()),
              ]),
            )));
      },
    );
  }
}

//FOLOWERS LIST
//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
class MySocialFollowers extends StatefulWidget {
  final MainModel model;

  MySocialFollowers(this.model);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SocialStateFollowers();
  }
}

class _SocialStateFollowers extends State<MySocialFollowers> {
  @override
  void initState() {
    super.initState();
    widget.model.fetchFollowers();
  }

  Future<bool> _willPopCallBack() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Seguidores"),
              actions: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.people,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return AllUsersPage(model);
                      }));
                    })
              ],
            ),
            body: SafeArea(
                child: Center(
              child: Column(children: [
                Expanded(child: FollowersListPage()),
              ]),
            )));
      },
    );
  }
}

//-------------------------------------------------------------------------------------------
//-----------FRIENDS-------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------

class FollowingListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FollowingListState();
  }
}

class _FollowingListState extends State<FollowingListPage> {
  @override
  Widget build(BuildContext context) {
    print("Builder FriendList");
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      Widget list = Center(
        child: Text("Sigue a alguien"),
      );
      if (model.followingListGet.length > 0) {
        list = ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return UserCard(model.followingListGet[index], index);
          },
          itemCount: model.followingListGet.length,
        );
      }

      return model.isLoading ? CircularProgressIndicator() : list;
    });
  }
}

//-------------------------------------------------------------------------------------------
//-----------Followers-------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------

class FollowersListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FollowersListState();
  }
}

class _FollowersListState extends State<FollowersListPage> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      Widget list = Center(
        child: Text("Nadie te Sigue"),
      );
      if (model.followersListGet.length > 0) {
        list = ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return UserCard(model.followersListGet[index], index);
          },
          itemCount: model.followersListGet.length,
        );
      }

      return model.isLoading ? CircularProgressIndicator() : list;
    });
  }
}

//-------------------------------------------------------------------------------------------
//-------------USER-------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------

class UserList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _UserListState();
  }
}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      Widget list = Center(
        child: Text("No hay usuarios"),
      );
      if (model.usersGet.length > 0) {
        list = ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return UserCard(model.usersGet[index], index);
          },
          itemCount: model.usersGet.length,
        );
      }

      return list;
    });
  }
}

//-------------------------------------------------------------------------------------------
//-------------USER-------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------

class EmergencyList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EmergencyListState();
  }
}

class _EmergencyListState extends State<EmergencyList> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      Widget list = Center(
        child: Text("No hay usuarios"),
      );
      if (model.followingListGet
              .where((element) => element.emergTag)
              .toList()
              .length >
          0) {
        list = ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return UserCard(
                model.followingListGet
                    .where((element) => element.emergTag)
                    .toList()[index],
                index);
          },
          itemCount: model.followingListGet
              .where((element) => element.emergTag)
              .toList()
              .length,
        );
      }

      return list;
    });
  }
}
