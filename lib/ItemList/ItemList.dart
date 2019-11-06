import 'package:flutter/material.dart';

class ItemList extends StatefulWidget {

  final String documentID;

  ItemList({
    Key key,
    this.documentID
    }) : super(key: key);

  @override
  _ItemListState createState() => new _ItemListState();
}
  
class _ItemListState extends State<ItemList>{

  ItemList itemList;

  String _documentId;
  
  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("${widget.documentID}"),
      ),
      body: new Center(
        child: new FlatButton(
          onPressed: (){
            Navigator.pop(context);
          },
          textColor: Theme.of(context).accentColor,
          child: new Text('Back to EventList'),
        )
      ),
    );
  }
}