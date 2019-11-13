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
  String _eventName = '';

  @override
  void initState(){
    super.initState();
    getEventInfo();
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
      });
    });
  }

  Widget createAppBar() {
    return new AppBar(
      elevation: 0.1,
      backgroundColor: Color(_eventColor),
      centerTitle: true,
      title: Text(_eventName),
    );
  }

  Widget createItem() {
    return new FloatingActionButton(
      elevation: 4.0,
      child: Icon(Icons.add, color: Colors.black),
      backgroundColor: Color(0xffdcd8e9),
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
      color: const Color(0xffdcd8e9),
      notchMargin: 4.0,
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.import_export, color: Colors.white,),
            onPressed: () {},
          )],
      ),
    );
  }

  buildStream() {
    return ItemList(documentId: widget.documentId,
                    userId: widget.userId,
                    eventColor: _eventColor.toInt(),
                    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: createAppBar(),
      body: buildStream(),
      floatingActionButton: createItem(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: bottomNavigation(),
    );
  }
}   