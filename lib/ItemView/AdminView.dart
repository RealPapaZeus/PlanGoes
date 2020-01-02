import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:plan_go_software_project/ItemView/ItemCreateDialog.dart';
import 'package:plan_go_software_project/ItemView/ItemList.dart';
import 'package:plan_go_software_project/colors.dart';

class AdminView extends StatefulWidget {

  final String documentId;
  final String userId;

  AdminView({
    Key key,
    this.documentId,
    this.userId,
    }) : super(key: key);

  @override
  _AdminViewState createState() => new _AdminViewState();
}
  
class _AdminViewState extends State<AdminView>{

  int _eventColor = 0;
  String _eventName = '';
  String _imageUrl = '';
  double offset = 0.0;

  @override
  void initState(){
    super.initState();
    getEventInfo();
  }

  // Method how to get one variable out of database, without using 
  //StreamBuilder   
  void getEventInfo() async{
    final databaseReference = Firestore.instance;
    var documentReference = databaseReference.collection("events").
                                              document(widget.documentId);

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
        background: 
          (_imageUrl != 'null')
            ? Image.network(_imageUrl, fit: BoxFit.cover)
            : Image.asset('images/calendar.png', fit: BoxFit.cover)
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
          child: new ItemCreateView(documentID: widget.documentId, eventColor: _eventColor.toInt())
        );
      },
      
    );
  }

  Widget bottomNavigation() {
    return new BottomAppBar(
      elevation: 5.0,
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

  Widget getScrollView() {
    return new NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) {
          return <Widget>[
            createAppBar(innerBoxScrolled)
          ];
        },
        body: buildStream(),
      );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cPlanGoWhiteBlue,
      extendBody: true,
      body: getScrollView(),
      floatingActionButton: createItem(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: bottomNavigation(),
    );
  }
}   