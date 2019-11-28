import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:plan_go_software_project/ItemView/ItemAlertDialog.dart';
import 'package:plan_go_software_project/ItemView/ItemList.dart';
import 'package:plan_go_software_project/ItemView/ItemPickDialog.dart';

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
  String _eventName = '';
  String _imageUrl = '';
  double offset = 0.0;

  ScrollController _scrollController;

  @override
  void initState(){
    super.initState();
    getEventInfo();
    _scrollController = ScrollController() 
      ..addListener(() {
        setState(() {
          offset = _scrollController.offset;
        });
      });
  }

   @override
  void dispose() {
    _scrollController.dispose();
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

  Widget createItem() {
    return new FloatingActionButton(
      elevation: 4.0,
      child: Icon(Icons.add, color: Colors.white),
      backgroundColor: Color(_eventColor),
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
      color: Color(_eventColor),
      notchMargin: 4.0,
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.import_export, color: Colors.white),
            onPressed: () {},
          )],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: new NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxScrolled) {
          return <Widget>[
            createAppBar(innerBoxScrolled)
          ];
        },
        body: buildStream(),
      ),
      floatingActionButton: createItem(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: bottomNavigation(),
    );
  }
}   