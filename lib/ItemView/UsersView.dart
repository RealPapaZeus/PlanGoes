import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:plan_go_software_project/ItemView/ItemList.dart';

class UsersView extends StatefulWidget {

  final String documentId;
  final String userId;

  UsersView({
    Key key,
    this.documentId,
    this.userId
    }) : super(key: key);

  @override
  _UsersViewState createState() => new _UsersViewState();
}
  
class _UsersViewState extends State<UsersView>{

  int _eventColor = 0;
  String _eventName = '';
  String _imageUrl = '';
  double offset = 0.0;

  @override
  void initState(){
    super.initState();
    getEventInfo();
  }

   @override
  void dispose() {
    super.dispose();
  }

  // Method how to get one variable out of database, without using 
  //StreamBuilder   
  void getEventInfo() async{
    final databaseReference = Firestore.instance;
    var documentReference = databaseReference.collection("events").document(widget.documentId);

    documentReference.get().then((DocumentSnapshot document) {
      setState(() {
        _eventColor = document['eventColor'];
        _eventName = document['eventName'];
        _imageUrl = document['imageUrl'];
      });
    });
  }

  buildStream() {
    return ItemList(userId: widget.userId,
                    documentId: widget.documentId,
                    eventColor: _eventColor.toInt(),
    );
  }

  Widget createAppBar(bool value) {
    return new SliverAppBar(
      snap: true,
      pinned: true,
      floating: true,
      forceElevated: value,
      expandedHeight: 200.0,
      backgroundColor: Color(_eventColor),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(_eventName),
        background: Image.network(
          (_imageUrl != 'null')
            ? _imageUrl
            : 'https://images.unsplash.com/photo-1511871893393-82e9c16b81e3?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1950&q=80',
          fit: BoxFit.cover
        )
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: new NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) {
          return <Widget>[
            createAppBar(innerBoxScrolled)
          ];
        },
        body: buildStream(),
      ),
    );
  }
}   