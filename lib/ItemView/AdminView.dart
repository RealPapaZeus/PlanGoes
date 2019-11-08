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

  @override
  void initState(){
    super.initState();
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
            itemExtent: 300.0,
           // shrinkWrap: true,
            padding: EdgeInsets.all(10.0),
            //itemExtent: 300.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
              buildItemList(context, snapshot.data.documents[index]),
        );
      },
    );
  }

  Widget buildItemList(BuildContext context, DocumentSnapshot document) {
    return new Card(
        elevation: 9.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(74, 84, 99, .9)),
          child: Container(  
            padding: EdgeInsets.only(right: 12.0),
            decoration: new BoxDecoration(
              border: new Border(right: new BorderSide(width: 1.0, color: Colors.white24))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(document['value'].toString()),
                  Text(document['name'])
                ],
              ),
            ),
        ),
    );
  }

  Widget createAppBar() {
    return new AppBar(
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
      appBar: createAppBar(),
      body: buildItemStream(context),
      floatingActionButton: createItem(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: bottomNavigation(),
    );
  }
}