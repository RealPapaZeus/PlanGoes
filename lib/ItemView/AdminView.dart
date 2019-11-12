import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plan_go_software_project/ItemView/ItemAlertDialog.dart';
import 'package:plan_go_software_project/ItemView/ItemList.dart';

class AdminView extends StatefulWidget {

  final String documentId;
  final String userId;

  AdminView({
    Key key,
    this.documentId,
    this.userId
    }) : super(key: key);

  @override
  _AdminViewState createState() => new _AdminViewState();
}
  
class _AdminViewState extends State<AdminView>{

  int _eventColor = 0;

  @override
  void initState(){
    super.initState();
  }

  // Method how to get one variable out of database, without using 
  //StreamBuilder 
  void getEventColor() async{
    final databaseReference = Firestore.instance;
    var documentReference = databaseReference.collection("events").document(widget.documentId);

    documentReference.get().then((DocumentSnapshot document) {
      setState(() {
        _eventColor = document['eventColor'];
      });
    });
  }

  StreamBuilder buildItemStream(BuildContext context)  {

    final databaseReference = Firestore.instance;
    
    return new StreamBuilder(
      stream: databaseReference.collection("events").
                                document(widget.documentId).
                                collection("itemList").
                                snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return const Center(child: Text("Your ItemList is empty"));
        return ListView.builder(
            scrollDirection: Axis.vertical,
            itemExtent: 100,
            padding: EdgeInsets.all(10.0),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
              buildItemList(context, snapshot.data.documents[index]),
        );
      },
    );
  }

  Widget buildItemList(BuildContext context, DocumentSnapshot document) {
    return new Container(
      child: Card(
        elevation: 10.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(right: 12.0, left: 12.0),
                  decoration: new BoxDecoration(
                    border: new Border(
                      right: new BorderSide(width: 1.0, color: Colors.black26)
                    )
                  ),
                  child: Icon(Icons.person),
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: 250),
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                  child: Text(
                    document['name'],
                    overflow: TextOverflow.ellipsis,
                  ),
                ), 
              ],
            ),
            Container(
              padding: const EdgeInsets.only(right: 12.0),
              child: Row(
                children: <Widget>[
                  Text('0'),
                  Text('/'),
                  Text(document['value'].toString())
                ],)
            )          
          ]
        ),
      ),
    );
  }

  Widget createAppBar() {
    getEventColor();
    return new AppBar(
      elevation: 0.1,
      backgroundColor: Color(_eventColor),
      centerTitle: true,
      title: Text("${widget.documentId}"),
    );
  }

  Widget createItem() {
    return new FloatingActionButton(
      elevation: 4.0,
      child: const Icon(Icons.create),
      onPressed: () {
        showDialog(
          context: context,
          child: new ItemAlertView(documentID: widget.documentId)
        );
      },
    );
  }

  Widget bottomNavigation() {
    return new BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 4.0,
      color: Colors.blue,
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.import_export, color: Colors.white,),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(_eventColor),
      appBar: createAppBar(),
      body: buildItemStream(context),
      floatingActionButton: createItem(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: bottomNavigation(),
    );
  }
}