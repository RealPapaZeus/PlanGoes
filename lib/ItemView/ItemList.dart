import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plan_go_software_project/ItemView/ItemPickDialog.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ItemList extends StatefulWidget {

  final String userId;
  final String documentId;
  final int eventColor;
  final String userName;

  ItemList({
    Key key,
    this.userId,
    this.documentId,
    this.eventColor,
    this.userName
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

  void deleteUsersItemList(DocumentSnapshot document) {
    Firestore.instance
        .collection('events')
        .document(widget.documentId)
        .collection("itemList")
        .document(document.documentID.toString())
        .collection("usersItemList")
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        doc.reference.delete();
      }
    });
  }

  void deleteItem(DocumentSnapshot document) {
    Firestore.instance.
      collection('events').
      document(widget.documentId).
      collection('itemList').
      document(document.documentID.toString()).
      delete();
  }

  Widget getCircleAvatar(String textInput) {
    return CircleAvatar(
      child: Text(textInput),
      backgroundColor: Color(widget.eventColor),
    );
  }

  Widget getUsernameChar(DocumentSnapshot document) {
    int value = document['username'].length;
    var _username = document['username'];

    if(document['username'].length < 1) {
      return getCircleAvatar(value.toString());
    } else if(document['username'].length == 1) {
      return getCircleAvatar(_username[0][0].toString());
    } else if(document['username'].length > 1) {
      return getCircleAvatar('+' + value.toString());
    }
    return null;
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
        return Scrollbar(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemExtent: 100,
            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 50.0),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              return buildItemList(context, snapshot.data.documents[index]);
            }
          ),
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
            child: Slidable(
              actionPane: SlidableStrechActionPane(),
              //actionExtentRatio: 0.25,
              closeOnScroll: true,
              actions: <Widget>[
                IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () async {
                    await Future.delayed(Duration(milliseconds: 300), () {
                      deleteItem(document);
                      deleteUsersItemList(document);
                    });
                  },
                )
              ],
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
                      child: getUsernameChar(document)
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
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text('${document['valueCurrent'].toString()}/${document['valueMax'].toString()}'),
                  )          
                )]
            ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return buildItemStream(context);
  }
}