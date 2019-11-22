import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plan_go_software_project/ItemView/ItemPickDialog.dart';

class ItemList extends StatefulWidget {

  final String userId;
  final String documentId;
  final int eventColor;

  ItemList({
    Key key,
    this.userId,
    this.documentId,
    this.eventColor
    }) : super(key: key);

  @override
  _ItemListState createState() => new _ItemListState();
}
  ///
  /// This class is used to build the stream, which loads data 
  /// into a scaffold, represented as the items. It is neccessary 
  /// to use a class, because ItemList is needed in the admins view
  /// and also in the user view. That way we can just call ItemList
  /// to return Items
  /// 
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
        if(!snapshot.hasData) return const Center(child: Text("Your ItemList is empty"));
        return ListView.builder(
            scrollDirection: Axis.vertical,
            itemExtent: 100,
            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 50.0),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
              buildItemList(context, snapshot.data.documents[index]),
        );
      },
    );
  }

  Widget buildItemList(BuildContext context, DocumentSnapshot document) {
    return new GestureDetector(
      onTap: (){
        showDialog(
          context: context,
          child: new ItemPickDialog(userId: widget.userId,
                                    documentId: widget.documentId,
                                    itemDocumentId: document.documentID.toString())
        );
      },
      child: Container(
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
    ),
   );
  }

  @override
  Widget build(BuildContext context) {
    return buildItemStream(context);
  }
}