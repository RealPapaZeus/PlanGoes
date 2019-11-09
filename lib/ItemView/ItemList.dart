import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ItemList extends StatefulWidget {

  final String documentId;
  final String userId;

  ItemList({
    Key key,
    this.documentId,
    this.userId
    }) : super(key: key);

  @override
  _ItemListState createState() => new _ItemListState();
}
  
class _ItemListState extends State<ItemList>{

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
        //if(snapshot.error) return const Center(child: Text("Your ItemList is empty"));
        return Container(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(10.0),
            //itemExtent: 300.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
              buildItemList(context, snapshot.data.documents[index]),
          ),
        );
      },
    );
  }

  Widget buildItemList(BuildContext context, DocumentSnapshot document) {
    return new GestureDetector(
      onTap: () {},
      child: Card(
        elevation: 9.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(74, 84, 99, .9)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                  border: new Border(
                      right: new BorderSide(width: 1.0, color: Colors.white24))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(document['value'].toString()),
                ],
              ),
            ),
            title: Text(document['name']),
            trailing: Icon(
              Icons.keyboard_arrow_right, color: Colors.white, size: 30.0
              )
            ),
          ),
        ),
      );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildItemStream(context),
    );
  }
}