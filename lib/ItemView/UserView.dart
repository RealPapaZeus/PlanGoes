import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:plan_go_software_project/ItemView/ItemList.dart';
import 'package:plan_go_software_project/colors.dart';

import 'ItemListUser.dart';

class UserView extends StatefulWidget {
  final String documentId;
  final String userId;

  UserView({
    Key key,
    this.documentId,
    this.userId,
  }) : super(key: key);

  @override
  _UserViewState createState() => new _UserViewState();
}

class _UserViewState extends State<UserView> {
  int _eventColor = 0;
  String _eventName = '';
  String _imageUrl = '';
  String _userName = '';
  double offset = 0.0;

  @override
  void initState() {
    super.initState();
    getEventInfo();
    getUserName();
  }

  void getUserName() async {
    final databaseReference = Firestore.instance;
    var documentReference =
        databaseReference.collection("users").document(widget.userId);

    documentReference.get().then((DocumentSnapshot document) {
      setState(() {
        _userName = document['username'].toString();
      });
    });
    print(_userName);
  }

  // Method how to get one variable out of database, without using
  //StreamBuilder
  void getEventInfo() async {
    final databaseReference = Firestore.instance;
    var documentReference =
        databaseReference.collection("events").document(widget.documentId);

    documentReference.get().then((DocumentSnapshot document) {
      setState(() {
        _eventColor = document['eventColor'];
        _eventName = document['eventName'];
        _imageUrl = document['imageUrl'];
      });
    });
  }

  buildStream() {
    return ItemListUser(
      userId: widget.userId,
      documentId: widget.documentId,
      eventColor: _eventColor.toInt(),
    );
  }

  Widget buildAppBar() {
    return AppBar(
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back, color: cPlanGoWhiteBlue),
        onPressed: () => Navigator.of(context).pop(),
        splashColor: cPlanGoBlue,
        highlightColor: Colors.transparent,
      ),
      title: new Row(
        children: <Widget>[
          CircleAvatar(
            radius: 20,
            foregroundColor: Color(_eventColor),
            backgroundColor: Color(_eventColor),
            child: ClipOval(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 1,
                height: MediaQuery.of(context).size.height / 1,
                child: (_imageUrl != 'null')
                    ? Image.network(
                        _imageUrl,
                        fit: BoxFit.contain,
                        height: 32,
                      )
                    : Image.asset('images/calendar.png',
                        fit: BoxFit.contain, height: 32),
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 1.5),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _eventName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'MontserratRegular'),
            ),
          )
        ],
      ),
      centerTitle: true,
      elevation: 8.0,
      backgroundColor: Color(_eventColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cPlanGoWhiteBlue,
      appBar: buildAppBar(),
      body: buildStream(),
    );
  }
}
