import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:plan_go_software_project/EventView/RegisterEvent.dart';
import 'package:plan_go_software_project/ItemView/AdminView.dart';

class EventList extends StatefulWidget {
  final String userId;

  EventList({Key key, this.userId}) : super(key: key);

  @override
  _EventListState createState() => new _EventListState();
}

class _EventListState extends State<EventList> {
  int _eventColor = 0;
  String _error;
  String _documentId;

  @override
  void initState() {
    super.initState();
  }

  // builds a stream in which we connect to subcollection and
  //get our data loaded into the EventList
  StreamBuilder buildStream(BuildContext context) {
    final databaseReference = Firestore.instance;

    return new StreamBuilder(
      stream: databaseReference
          .collection("users")
          .document(widget.userId)
          .collection("usersEventList")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text("No event found");
        return ListView.separated(
          padding: EdgeInsets.all(10.0),
          itemCount: snapshot.data.documents.length,
          separatorBuilder: (context, index) => Divider(
            height: 15.0,
            color: Colors.transparent,
          ),
          itemBuilder: (context, index) =>
              buildCanbanList(context, snapshot.data.documents[index]),
        );
      },
    );
  }

  //this widget actually builds the UI for the EventList.

  Widget buildCanbanList(BuildContext context, DocumentSnapshot document) {
    return new GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AdminView(
                    documentId: document.documentID.toString(),
                    userId: widget.userId)));
      },
      child: new Stack(children: <Widget>[
        new Container(
          width: 400.0,
          height: 124.0,
          margin: const EdgeInsets.only(left: 46.0, bottom: 10),
          decoration: new BoxDecoration(
            color: Color(document['eventColor']),
            shape: BoxShape.rectangle,
            borderRadius: new BorderRadius.circular(8.0),
            boxShadow: <BoxShadow>[
              new BoxShadow(
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Container(
                  padding: const EdgeInsets.only(
                      right: 8.00, left: 62.00, top: 2.00),
                  decoration: BoxDecoration(),
                  child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                            child: Text(
                          document['eventname'],
                          maxLines: 1,
                          style: TextStyle(fontSize: 25.0, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        )),
                        PopupMenuButton(
                          child: Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Text("Edit"),
                            ),
                            PopupMenuItem(
                              child: Text("Delete"),
                            )
                          ],
                        )
                      ])),
              new Container(
                  padding: const EdgeInsets.only(
                      right: 8.00, left: 62.00, bottom: 8),
                  decoration: BoxDecoration(),
                  child: new Row(children: <Widget>[
                    Icon(Icons.my_location, color: Colors.white, size: 10),
                    Expanded(
                        child: Text(
                      document['location'],
                      maxLines: 1,
                      style: TextStyle(fontSize: 10.0, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    )),
                  ])),
              new Container(
                padding: const EdgeInsets.only(
                    right: 8.00, left: 62.00, top: 2.00, bottom: 8.00),
                decoration: BoxDecoration(),
                child: Text(
                  document['description'],
                  maxLines: 3,
                  style: TextStyle(fontSize: 14.0, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        new Container(
          height: 92.0,
          width: 92.0,
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
          decoration: new BoxDecoration(
              boxShadow: [BoxShadow(blurRadius: 7.0, spreadRadius: 1.5)],
              shape: BoxShape.circle,
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: (document['imageUrl'] != null)
                      ? new NetworkImage(document['imageUrl'])
                      : new NetworkImage(
                          'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=967&q=80',
                        ))),
        ),
      ]),
    );
  }

  Widget createAppBar() {
    return AppBar(
      title: Text('Your Events'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.person),
          onPressed: () {},
        )
      ],
      leading: IconButton(
        icon: Icon(Icons.add_circle),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RegisterEvent(userId: widget.userId)));
        },
      ),
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(),
      body: buildStream(context),
    );
  }
}
