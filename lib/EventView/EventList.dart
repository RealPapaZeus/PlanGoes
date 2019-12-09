import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plan_go_software_project/EventView/RegisterEvent.dart';
import 'package:plan_go_software_project/ItemView/AdminView.dart';
import 'package:plan_go_software_project/ItemView/UsersView.dart';

class EventList extends StatefulWidget {
  final String userId;

  EventList({Key key, this.userId}) : super(key: key);

  @override
  _EventListState createState() => new _EventListState();
}

class _EventListState extends State<EventList> {
  String _userName;
  bool _adminRight = true;

  @override
  void initState() {
    super.initState();
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
        return Scrollbar(
            child: ListView.separated(
          padding: EdgeInsets.all(10.0),
          itemCount: snapshot.data.documents.length,
          separatorBuilder: (context, index) => Divider(
            height: 15.0,
            color: Colors.transparent,
          ),
          itemBuilder: (context, index) =>
              buildCanbanList(context, snapshot.data.documents[index]),
        ));
      },
    );
  }

  void callView(DocumentSnapshot document) async {
    final databaseReference = Firestore.instance;
    var documentReference = databaseReference
        .collection("users")
        .document(widget.userId)
        .collection("usersEventList")
        .document(document.documentID.toString());

    documentReference.get().then((DocumentSnapshot document) {
      setState(() {
        _adminRight = document['admin'];
      });
    });

    try {
      if (_adminRight) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AdminView(
                    documentId: document.documentID.toString(),
                    userId: widget.userId)));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UsersView(
                    documentId: document.documentID.toString(),
                    userId: widget.userId)));
      }
    } catch (e) {
      print(e);
    }
  }


  void deleteCanban(DocumentSnapshot document) {
    deleteItems(document);

    Firestore.instance
        .collection('events')
        .document(document.documentID.toString())
        .delete();

    Firestore.instance
        .collection('users')
        .document(widget.userId)
        .collection('usersEventList')
        .document(document.documentID.toString())
        .delete();
  }

  void deleteItems(DocumentSnapshot document) {
    Firestore.instance
        .collection('events')
        .document(document.documentID)
        .collection("itemList")
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        doc.reference.delete();
      }
    });
  }

  Widget buildCanbanList(BuildContext context, DocumentSnapshot document) {
    return new GestureDetector(
      onTap: () {
        callView(document);
      },
      child: new Stack(children: <Widget>[
        new Container(
            width: 400.0,
            height: 130.0,
            margin: const EdgeInsets.only(
                left: 46.0, bottom: 7.5, top: 7.5, right: 7.5),
            decoration: new BoxDecoration(
              color: Color(document['eventColor']),
              shape: BoxShape.rectangle,
              borderRadius: new BorderRadius.circular(8.0),
              boxShadow: <BoxShadow>[
                new BoxShadow(
                  color: Color(document['eventColor']),
                  blurRadius: 10.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 64.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Column(
                    children: <Widget>[
                      new Container(
                          padding: const EdgeInsets.only(right: 8.0, top: 7.5),
                          decoration: BoxDecoration(),
                          child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                    child: Text(
                                  document['eventname'],
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 24.0, color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                )),
                                new IconButton(
                                  icon: new Icon(Icons.delete_forever),
                                  color: Colors.white,
                                  iconSize: 20.0,
                                  onPressed: (){
                                    deleteItems(document);
                                    deleteCanban(document);
                                  },
                                ),
                              ])),
                      new Container(
                          padding: const EdgeInsets.only(
                              top: 4.00, left: 1.0, right: 30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  document['description'],
                                  maxLines: 3,
                                  style: TextStyle(
                                      fontSize: 12.0, color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          )),
                    ],
                  ),
                  Expanded(
                    child: Container(
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(
                          right: 30.00,
                          bottom: 10.0,
                        ),
                        child: new Row(children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                          Expanded(
                              child: Text(
                            document['location'],
                            maxLines: 1,
                            style:
                                TextStyle(fontSize: 11.0, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          )),
                        ])),
                  )
                ],
              ),
            )),
        new Container(
          height: 95.0,
          width: 95.0,
          alignment: Alignment.centerLeft,
          margin:
              const EdgeInsets.only(top: 25, bottom: 8, left: 3.75, right: 8),
          decoration: new BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 10.0,
                  spreadRadius: 1.0,
                )
              ],
              shape: BoxShape.circle,
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: (document['imageUrl'] != 'null')
                      ? new NetworkImage(document['imageUrl'])
                      : new AssetImage(
                          'images/calendar.png',
                        ))),
        ),
      ]),
    );
  }

  Widget createAppBar() {
    return AppBar(
      title: Text('${_userName}s Events'),
      elevation: 5.0,
      backgroundColor: Colors.lightBlue,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.person),
          onPressed: () {},
        )
      ],
      leading: IconButton(
        tooltip: "Create New Event",
        icon: Icon(Icons.playlist_add_check),
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
      backgroundColor: Colors.lightBlue,
      appBar: createAppBar(),
      body: buildStream(context),
    );
  }
}
