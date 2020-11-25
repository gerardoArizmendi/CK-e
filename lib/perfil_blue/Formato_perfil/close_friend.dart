import 'package:blue/models/main_scope.dart';
import 'package:blue/pages/RouteTools/liveLocation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:blue/models/user.dart';

class FollowingList extends StatefulWidget {
  final User user;
  final int index;
  final BuildContext context;
  FollowingList(this.user, this.index, this.context);

  @override
  State<StatefulWidget> createState() {
    return _FollowingListState(user, index, context);
  }
}

class _FollowingListState extends State<FollowingList> {
  final User user;
  final int index;
  final BuildContext context;
  _FollowingListState(this.user, this.index, this.context);

  bool onAlert = false;
  bool onRoute = false;

  @override
  void initState() {
    getStatus();
    super.initState();
  }

  Future<void> getStatus() {
    Firestore.instance
        .collection('/Perfiles')
        .document(user.id)
        .collection('Data')
        .document('Live')
        .snapshots()
        .listen((event) {
      Map<String, dynamic> liveInfo = event.data;
      print("Live Info: " + liveInfo.toString());
      setState(() {
        onRoute = liveInfo['onRoute']; // ITS coming back null
        onAlert = liveInfo['onAlert'];
      });
    });

    return null;
  }

  Widget userBuild() {
    int _feed = 0;
    // if (onAlert) {
    //   FlutterRingtonePlayer.playAlarm();
    // } else {
    //   FlutterRingtonePlayer.stop();
    // }
    return Stack(children: [
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(140)),
        color: onRoute
            ? Colors.green[800]
            : onAlert ? Colors.red : Colors.blueGrey[200],
        child: GestureDetector(
          child: Padding(
            padding: EdgeInsets.all(9),
            child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  user.imageUrl,
                )),
          ),
          onLongPress: () {
            print("On long Press");
            if (onRoute) {
              print("On long and route");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LivePanel(widget.user.id)));
            }
          },
          onTap: () {
            print(user.id);
            Navigator.pushNamed(context, '/perfil/' + user.id);
          },
        ),
      ),
      Card(
        shape: StadiumBorder(
            side: BorderSide(
          width: 2,
        )),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Text(
            "$_feed",
            textScaleFactor: 1.3,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
      index == 420
          ? Row(children: [
              SizedBox(
                width: 80,
              ),
              Column(children: [
                SizedBox(
                  height: 70,
                ),
                Card(
                  shape: StadiumBorder(
                      side: BorderSide(
                    width: 2,
                  )),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      "+",
                      textScaleFactor: 1.3,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ])
            ])
          : SizedBox()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return userBuild();
  }
}
