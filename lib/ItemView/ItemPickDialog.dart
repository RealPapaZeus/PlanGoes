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
  int _valueToAdd = 0;
  int _valueCurrent = 0;
  int _valueMax = 0; 
  int _valueMin = 0;
  int _valueUserItem = 0;
  
  @override
  void initState(){
    super.initState();
    getItemName();
    getUserName();
    getUsersItemAmount();
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
        _valueMax = document['valueMax'];
        _valueCurrent = document['valueCurrent'];
        _valueMin = document['valueCurrent'];
      });
    });
  }

  void getUsersItemAmount() async{
    final databaseReference = Firestore.instance;
    var documentReference = databaseReference.
                            collection("events").
                            document(widget.documentId).
                            collection("itemList").
                            document(widget.itemDocumentId).
                            collection("usersItemList").
                            document(widget.userId);

    documentReference.get().then((DocumentSnapshot document) {
      setState(() {
        _valueUserItem = document['value'];
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

  // same procedure as in other classes, to insert values into 
  // database under given path 
  void addNewItemToDatabase(String userName, int value) async {

    final databaseReference = Firestore.instance;

    await databaseReference.collection("events").
                            document(widget.documentId).
                            collection("itemList").
                            document(widget.itemDocumentId).
                            collection("usersItemList").
                            document(widget.userId).
                            setData({
                              'user' : '$userName',
                              'value' : value,
                            });
  }

  void updateItemUser(int value) async{
    final databaseReference = Firestore.instance;

    int newItemValue = value + _valueUserItem;
    var documentReference = databaseReference.
                            collection("events").
                            document(widget.documentId).
                            collection("itemList").
                            document(widget.itemDocumentId).
                            collection("usersItemList").
                            document(widget.userId);

    documentReference.get().then((DocumentSnapshot document) async {
      await databaseReference.collection("events").
                            document(widget.documentId).
                            collection("itemList").
                            document(widget.itemDocumentId).
                            collection("usersItemList").
                            document(widget.userId).
                            updateData({
                              "value" : newItemValue
                            });
    });
  }

  void addNewValueToItemList(int value) async {

    final databaseReference = Firestore.instance;

    await databaseReference.collection("events").
                            document(widget.documentId).
                            collection("itemList").
                            document(widget.itemDocumentId).
                            updateData({
                              "valueCurrent" : value 
                            });
  }


  void callDatabaseInserts() {
    if(_valueCurrent != 0 && _valueToAdd != 0){
      addNewItemToDatabase(_userName.toString(), _valueToAdd); 
      updateItemUser(_valueToAdd);
      addNewValueToItemList(_valueCurrent);
    }
  }

  // method to get all variables out of database
  void getVariables(){
    getItemName();
    getUserName();
    getUsersItemAmount();
  }

  // checks if everything is valid and sends after that values to
  //database
  void registerItemByPress() async {
    
    getVariables();

    try{
    
      callDatabaseInserts();                
      
      Navigator.pop(context);

    } catch(e) {
      print(e);
    }
  }

  void incrementCounter() {
    setState(() {
      if(_valueCurrent < _valueMax) {
        _valueCurrent++;
        _valueToAdd++;
      }
    });
  }

  void decrementCounter() {
    setState(() {
      if(_valueCurrent != 0 && _valueCurrent != _valueMin) {
        _valueCurrent--;
        _valueToAdd--;
      }
    });

  }

  StreamBuilder buildUsersItemStream(BuildContext context)  {

    final databaseReference = Firestore.instance;
    
    return new StreamBuilder(
      stream: databaseReference.collection("events").
                                document(widget.documentId).
                                collection("itemList").
                                document(widget.itemDocumentId).
                                collection("usersItemList").
                                snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return const Center(child: Text("There is no item selected"));
        return ListView.builder(
            scrollDirection: Axis.vertical,
            itemExtent: 75,
            padding: EdgeInsets.only(bottom: 5.0),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
              buildItemList(context, snapshot.data.documents[index]),
        );
      },
    );
  }

  Widget buildItemList(BuildContext context, DocumentSnapshot document) {
    return new Container(
      margin: new EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
            Container(
              padding: const EdgeInsets.only(right: 5.0, left: 5.0),
              child: Text(document['user']),
            ),
            Container(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              decoration: new BoxDecoration(
                border: new Border(
                  left: new BorderSide(width: 1.0, color: Colors.black26)
                )
              ),
              child: Text(document['value'].toString(),),
            ), 
          ],
      ),
    );
  }

  Widget getUsersItems() {
    return Container(
      height: 300,
      width: 250,
      decoration: BoxDecoration(
        border: new Border(
          top: new BorderSide(width: 1, color: Colors.black26)
        )
      ),
      child: new Scrollbar(
        child: new Scaffold(
          body: buildUsersItemStream(context),
        )
      )
    );
  }

  Widget createItemCounter() {
    return new Container(
      height: 100,
      width: 250,
      child: Padding (
        padding: const EdgeInsets.only(top: 10.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {decrementCounter();}
            ),
            Text('$_valueCurrent / $_valueMax',
                style: new TextStyle(fontSize: 30.0)),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {incrementCounter();}
            ),
          ],
        )
      ),
    );
  }
  
  Widget displayElements() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        createItemCounter(),
        getUsersItems()
      ],
    );
  }

  showItemCreatorDialog() {
    return AlertDialog(
      title: Center(child: Text(_itemName)),
      content: displayElements(),
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(15)),
      actions: <Widget>[
        FlatButton(
          onPressed:(){
            registerItemByPress()
            ;},
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