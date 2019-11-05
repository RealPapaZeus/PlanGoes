import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:plan_go_software_project/EventView/RegisterEvent.dart';
import 'package:plan_go_software_project/ItemList.dart';

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
<<<<<<< HEAD
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
          ),
      ],
    ),
 );

  Widget buildCanbanList(BuildContext context, DocumentSnapshot document) {
    return new GestureDetector(
      onTap: (){
           Navigator.push(context, MaterialPageRoute(builder: (context) => ItemList())); 
        },
      child:new Container(
          height: 120.0,
          margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: new Stack(
            children: <Widget>[
              kanbanCard,
              //kanbanThumbnail
            ]
            ,
          ),
          
      )
       
=======
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
                new RaisedButton(
                    padding: const EdgeInsets.all(8.0),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ItemList())); 
                    },
                    child: new Text("Add"),
                  ),
                new Container(
                  padding: const EdgeInsets.only(right: 8.00, left: 8.00,top: 8.00, bottom: 4.00),
                  decoration: BoxDecoration(),
                  child: Text(
                    document['eventname'],
                    maxLines: 1,
                    style: TextStyle(fontSize: 16.0), 
                    overflow: TextOverflow.ellipsis,),
                ),
                new Container(
                  padding: const EdgeInsets.only(right: 8.00, left: 8.00,top: 4.00, bottom: 8.00),
                  decoration: BoxDecoration(),
                  child: Text(
                    document['description'],
                    maxLines: 2,
                    style: TextStyle(fontSize: 12.0),
                    overflow: TextOverflow.ellipsis, ),
                ),
              ], 
            ),
          )
        )
      
        
      
      
      
      
>>>>>>> c84d64d935afafe5ae2589049b8786d1b7b5547c
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