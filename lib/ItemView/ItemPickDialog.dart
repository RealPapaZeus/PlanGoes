import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ItemPickDialog extends StatefulWidget {

  final String userId;
  final String documentId;
  final String itemDocumentId;

  ItemPickDialog({
    Key key,
    this.userId,
    this.documentId,
    this.itemDocumentId
    }) : super(key: key);

  @override
  _ItemPickDialogState createState() => new _ItemPickDialogState();
}
  
class _ItemPickDialogState extends State<ItemPickDialog>{

  String _itemName = '';
  String _userName = '';
  int _value = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  @override
  void initState(){
    super.initState();
    getItemName();
    getUserName();
  }

  void getItemName() async{
    final databaseReference = Firestore.instance;
    var documentReference = databaseReference.
                            collection("events").
                            document(widget.documentId).
                            collection("itemList").
                            document(widget.itemDocumentId);

    documentReference.get().then((DocumentSnapshot document) {
      setState(() {
        _itemName = document['name'];
      });
    });
  }

  // Get username to display in itemList and get sure, 
  // who is getting which item
  void getUserName() async {

    final databaseReference = Firestore.instance;
    var documentReference = databaseReference.
                            collection("users").
                            document(widget.userId);

    documentReference.get().then((DocumentSnapshot document) {
      setState(() {
        _userName = document['username'].toString();
      });
    });
    print(_userName);
  }

  // method to get all variables out of database
  void getVariables(){
    getItemName();
    getUserName();
  }

  // same procedure as in other classes, to insert values into 
  // database under given path 
  void addNewItemToDatabase(String userName, int value) async {

    final databaseReference = Firestore.instance;

    await databaseReference.collection("events").
                            document(widget.documentId).
                            collection("itemList").
                            document(widget.itemDocumentId).
                            collection("usersItemList").
                            document().
                            setData({
                              'user' : '$userName',
                              'value' : value.toInt()
                            });
  }

  void callDatabaseInserts() {
    if(_value != 0){ addNewItemToDatabase(_userName.toString(), _value); }
  }


  // checks if everything is valid and sends after that values to
  //database
  void registerItemByPress() async {
    final _formState = _formKey.currentState;
    
    if(_formState.validate()) {
      _formState.save();
      getVariables();

      try{
      
       callDatabaseInserts();                
        
        Navigator.pop(context);

      } catch(e) {
        print(e);
      }

    }
  }

  void incrementCounter() {
    setState(() {
      _value++;  
    });
  }

  void decrementCounter() {
    if(_value != 0) {
      setState(() {
        _value--;
      });
    }
  }

  Widget createItemCounter() {
    return new Padding (
      padding: EdgeInsets.only(top: 15.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {decrementCounter();}
          ),
          Text('$_value',
              style: new TextStyle(fontSize: 30.0)),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {incrementCounter();}
          ),
        ],
      )
    );
  }

  SingleChildScrollView itemGeneratorContent() {
    return new SingleChildScrollView(
      child: new Container(
        padding: const EdgeInsets.all(5.0),
        child: new Column(
          children: <Widget>[
              new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Container(
                    padding: new EdgeInsets.all(15.0),
                    child: new Form(
                      key: _formKey,
                      child: new Column(
                        children: <Widget>[
                          createItemCounter()
                        ],
                      )
                    )
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }

  showItemCreatorDialog() {
    return AlertDialog(
      title: Center(child: Text(_itemName)),
      content: itemGeneratorContent(),
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(15)),
      actions: <Widget>[
        FlatButton(
          onPressed:(){registerItemByPress();},
          child: Text('Create'),
        )
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return showItemCreatorDialog();
  }
}