import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:plan_go_software_project/EventView/RegisterEvent.dart';

class EventList extends StatefulWidget {

  EventList({Key key,}) : super(key: key);

  @override
  _EventListState createState() => new _EventListState();
}
  
class _EventListState extends State<EventList>{
  
  FirebaseUser user;
  String error;

  // setUser and setError is very important to be declared.
  //they set the UserId before StreamBuilder gets called. That way
  //data gets loaded from Firestore. 
  void setUser(FirebaseUser user) {
    setState(() {
      this.user = user;
      this.error = null;
    });
  }

  void setError(e) {
    setState(() {
      this.user = null;
      this.error = e.toString();
    });
  }

  @override
  void initState(){
    super.initState();
    FirebaseAuth.instance.currentUser().then(setUser).catchError(setError);
  }

  // builds a stream in which we connect to subcollection and 
  //get our data loaded into the EventList
  StreamBuilder buildStream(BuildContext context)  {
    final databaseReference = Firestore.instance;

    return new StreamBuilder(
      stream: databaseReference.collection("users").
                                document(user.uid).
                                collection("usersEventList").
                                snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return const Text("No event found");
        return ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemExtent: 80.0,
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) =>
            buildCanbanList(context, snapshot.data.documents[index]),
        );
      },
    );
  }

  //this widget actually builds the UI for the EventList. 
  //Changes need still to be applied 
  Widget buildCanbanList(BuildContext context, DocumentSnapshot document) {
    return new SingleChildScrollView(
        child: new Container(
          child: new Card(
            semanticContainer: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)
            ),
            elevation: 5.0,
            margin: EdgeInsets.all(10.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(height: 4.0),
                new Text(document['eventname']),
                new Container(height: 10.0),
                new Text(document['description'])
              ], 
            ),
          )
        )
      
      
    );
  }
  Widget createAppBar() {
    return AppBar(
      title: Text('Your Events'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.person),
          onPressed: (){},
        )
      ],
      leading: IconButton(
        icon: Icon(Icons.add_circle),
        onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterEvent()));},
      ),
      centerTitle: true,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(),
      body: buildStream(context)
    );
  }
}