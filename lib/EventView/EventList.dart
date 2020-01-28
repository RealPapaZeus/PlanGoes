import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:PlanGoes/EventView/RegisterEvent.dart';
import 'package:PlanGoes/ItemView/AdminView.dart';
import 'package:PlanGoes/ItemView/UserView.dart';
import 'package:PlanGoes/colors.dart';

class EventList extends StatefulWidget {
  final String userId;

  EventList({Key key, this.userId}) : super(key: key);

  @override
  _EventListState createState() => new _EventListState();
}

class _EventListState extends State<EventList> {
  String _userName;

  String _montserratMedium = 'MontserratMedium';
  String _montserratRegular = 'MontserratRegular';

  // username should only be called once when debugging into
  // event view
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
          .orderBy("datetime")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Text(
            "Loading..",
            style: TextStyle(color: cPlanGoWhiteBlue),
          );
        return ScrollConfiguration(
            behavior: ScrollBehavior(),
            child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color: cPlanGoBlue,
                child: ListView.separated(
                  padding: EdgeInsets.all(10.0),
                  itemCount: snapshot.data.documents.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 15.0,
                    color: Colors.transparent,
                  ),
                  itemBuilder: (context, index) =>
                      buildCanbanList(context, snapshot.data.documents[index]),
                )));
      },
    );
  }

  // it gets checked whether user is admin or not
  // The reason is to give logged user the important
  // view for navigating through the app
  // users are for instance not allowed to append items to
  // the itemlist
  void callView(DocumentSnapshot document) {
    try {
      if (document['admin'] == true) {
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
                builder: (context) => UserView(
                    documentId: document.documentID.toString(),
                    userId: widget.userId)));
      }
    } catch (e) {
      print(e);
    }
  }

  // Whenever a user or admin deletes his canban
  // it is important to check his status in order to
  // delete all dependencies
  void deleteCanban(DocumentSnapshot document) {
    try {
      if (document['admin'] == true) {
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

        deleteUsersEvent(document);

        deleteUsersItemLists(document);
        deleteItems(document);
      } else {
        Firestore.instance
            .collection('users')
            .document(widget.userId)
            .collection('usersEventList')
            .document(document.documentID.toString())
            .delete();

        deleteUsersItemLists(document);
        deleteValuesFromItemList(document);
      }
    } catch (e) {
      print(e);
    }
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

  void deleteUsersEvent(DocumentSnapshot document) {
    Firestore.instance
        .collection('events')
        .document(document.documentID)
        .collection('usersList')
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        String name = doc['name'];
        Firestore.instance
            .collection('users')
            .document('$name')
            .collection('usersEventList')
            .getDocuments()
            .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.documents) {
            if (doc.documentID == document.documentID) {
              doc.reference.delete();
            }
          }
        });
        for (DocumentSnapshot doc in snapshot.documents) {
          doc.reference.delete();
        }
      }
    });
  }

  void deleteUsersItemLists(DocumentSnapshot document) {
    Firestore.instance
        .collection('events')
        .document(document.documentID)
        .collection("itemList")
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        Firestore.instance
            .collection('events')
            .document(document.documentID)
            .collection("itemList")
            .document(doc.documentID)
            .collection('usersItemList')
            .getDocuments()
            .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.documents) {
            doc.reference.delete();
          }
        });
      }
    });
  }

  void deleteValuesFromItemList(DocumentSnapshot document) {
    Firestore.instance
        .collection('events')
        .document(document.documentID)
        .collection("itemList")
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        int currentValue = doc['valueCurrent'];
        Firestore.instance
            .collection('events')
            .document(document.documentID)
            .collection("itemList")
            .document(doc.documentID)
            .collection("usersItemList")
            .getDocuments()
            .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.documents) {
            if (doc.documentID == widget.userId) {
              int itemvalue = doc['value'];
              int newValue = currentValue - itemvalue;
              Firestore.instance
                  .collection('events')
                  .document(document.documentID)
                  .collection("itemList")
                  .document(doc.documentID)
                  .updateData({'valueCurrent': newValue});
              doc.reference.delete();
            }
          }
        });
      }
    });
  }

  Widget eventName(DocumentSnapshot document) {
    return new Container(
        width: MediaQuery.of(context).size.width / 1.0,
        height: MediaQuery.of(context).size.height / 14.0,
        padding: const EdgeInsets.only(right: 5.0, left: 30.0),
        child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                  child: Text(
                document['eventname'],
                maxLines: 1,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: cPlanGoWhiteBlue,
                    fontFamily: _montserratRegular),
                overflow: TextOverflow.ellipsis,
              )),
              new IconButton(
                padding: const EdgeInsets.all(0.0),
                icon: new Icon(Icons.delete),
                color: cPlanGoWhiteBlue,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                iconSize: 20.0,
                onPressed: () async {
                  await Future.delayed(Duration(milliseconds: 300), () {
                    deleteCanban(document);
                  });
                },
              ),
            ]));
  }

  Widget descriptionAndLocation(DocumentSnapshot document) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new Container(
          width: MediaQuery.of(context).size.width / 1.0,
          height: MediaQuery.of(context).size.height / 45.0,
          padding: const EdgeInsets.only(left: 1.0, right: 15.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(right: 5.0, left: 30.0),
                child: Icon(
                  Icons.location_on,
                  color: cPlanGoWhiteBlue,
                  size: 12.5,
                ),
              ),
              Expanded(
                child: Text(
                  document['location'],
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 13.0,
                      color: cPlanGoWhiteBlue,
                      fontFamily: _montserratRegular),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(right: 22.0, left: 15.0),
            child: new Divider(
              color: cPlanGoWhiteBlue,
              thickness: 1.5,
            )),
        new Container(
            width: MediaQuery.of(context).size.width / 1.0,
            height: MediaQuery.of(context).size.height / 12.5,
            padding: const EdgeInsets.only(left: 1.0, right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    document['description'],
                    maxLines: 3,
                    style: TextStyle(
                        fontSize: 14.0,
                        color: cPlanGoWhiteBlue,
                        fontFamily: _montserratMedium),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            )),
      ],
    );
  }

  Widget loadImage(DocumentSnapshot document) {
    return new Container(
      height: MediaQuery.of(context).size.height / 10.0,
      width: MediaQuery.of(context).size.width / 5.0,
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(top: 20.0, left: 2.0),
      decoration: new BoxDecoration(
          color: Color(document['eventColor']),
          boxShadow: [
            BoxShadow(
              blurRadius: 5.0,
              spreadRadius: 1.0,
            )
          ],
          shape: BoxShape.circle,
          image: new DecorationImage(
              fit: BoxFit.cover,
              image: (document['imageUrl'] != 'null')
                  ? new NetworkImage(document['imageUrl'])
                  : new AssetImage(
                      'images/calendar.png',
                    ))),
    );
  }

  Widget buildCanbanList(BuildContext context, DocumentSnapshot document) {
    return new InkWell(
      borderRadius: new BorderRadius.circular(20.0),
      splashColor: cPlanGoBlue,
      onTap: () {
        callView(document);
      },
      child: new Stack(children: <Widget>[
        new Container(
            width: MediaQuery.of(context).size.width / 1.0,
            height: MediaQuery.of(context).size.height / 4.0,
            margin: const EdgeInsets.only(
                left: 40.0, bottom: 7.5, top: 20, right: 7.5),
            decoration: new BoxDecoration(
              color: Color(document['eventColor']),
              borderRadius: new BorderRadius.circular(20.0),
              boxShadow: <BoxShadow>[
                new BoxShadow(
                  color: Color(document['eventColor']),
                  blurRadius: 5.0,
                  spreadRadius: 0.2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Column(
                    children: <Widget>[
                      eventName(document),
                      descriptionAndLocation(document),
                    ],
                  ),
                  Expanded(
                    child: Container(
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(
                            right: 30.00, bottom: 10.0, top: 5.0),
                        child: new Row(children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: Icon(
                              Icons.date_range,
                              color: cPlanGoWhiteBlue,
                              size: 12.5,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              document['datetime']
                                  .substring(0, 10)
                                  .replaceAll('-', '/'),
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 13.0,
                                  color: cPlanGoWhiteBlue,
                                  fontFamily: _montserratRegular),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding:
                                const EdgeInsets.only(left: 50.0, right: 5.0),
                            child: Icon(
                              Icons.access_time,
                              color: cPlanGoWhiteBlue,
                              size: 12.5,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              document['datetime'].substring(11, 16),
                              style: TextStyle(
                                  fontSize: 13.0,
                                  color: cPlanGoWhiteBlue,
                                  fontFamily: _montserratRegular),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ])),
                  )
                ],
              ),
            )),
        loadImage(document)
      ]),
    );
  }

  Widget createAppBar() {
    return AppBar(
      title: Text("$_userName's List".toUpperCase(),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: cPlanGoWhiteBlue,
              fontFamily: _montserratMedium,
              fontSize: 16.0)),
      elevation: 8.0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[cPlangGoDarkBlue, cPlanGoBlue]),
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(25)),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(25),
        ),
      ),
      leading: new IconButton(
        color: cPlanGoWhiteBlue,
        tooltip: "Create Event",
        icon: new Icon(Icons.calendar_view_day, color: cPlanGoWhiteBlue),
        splashColor: cPlanGoWhiteBlue,
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
      backgroundColor: cPlangGoDarkBlue,
      appBar: createAppBar(),
      body: buildStream(context),
    );
  }
}
