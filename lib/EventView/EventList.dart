import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:plan_go_software_project/EventView/RegisterEvent.dart';
import 'package:plan_go_software_project/ItemView/AdminView.dart';

class EventList extends StatefulWidget {

  EventList({Key key,}) : super(key: key);

  @override
  _EventListState createState() => new _EventListState();
}
  
class _EventListState extends State<EventList>{
  
  FirebaseUser _user;
  String _error;
  String _documentId;

  // setUser and setError is very important to be declared.
  //they set the UserId before StreamBuilder gets called. That way
  //data gets loaded from Firestore. 
  void setUser(FirebaseUser user) {
    setState(() {
      this._user = user;
      this._error = null;
    });
  }

  void setError(e) {
    setState(() {
      this._user = null;
      this._error = e.toString();
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
                                document(_user.uid).
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
  final kanbanCard = new Container(
   height: 124.0,
   margin: new EdgeInsets.only(left: 46.0),
   decoration: new BoxDecoration(
    color: new Color(0xFF333366),
    shape: BoxShape.rectangle,
    borderRadius: new BorderRadius.circular(8.0),
    boxShadow: <BoxShadow>[
      new BoxShadow(  
        color: Colors.black12,
        blurRadius: 10.0,
        offset: new Offset(0.0, 10.0),
      ),],
    ),
 );

  Widget buildCanbanList(BuildContext context, DocumentSnapshot document) {
    return new GestureDetector(
      onTap: (){
      Navigator.push(context, MaterialPageRoute(builder: (context) => AdminView(documentId: document.documentID.toString(),
                                                                                userId: _user.uid.toString()))); 
      },
      child:new Container(
          height: 120.0,
          margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: new Stack(
            children: <Widget>[
              kanbanCard,
              //kanbanThumbnail
            ],
          ),
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
      body: buildStream(context),
    );
  }
}