import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ItemAlertView extends StatefulWidget {

  final String documentID;

  ItemAlertView({
    Key key,
    this.documentID
    }) : super(key: key);

  @override
  _ItemAlertViewState createState() => new _ItemAlertViewState();
}
  
class _ItemAlertViewState extends State<ItemAlertView>{

  String _item;
  int _value = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _itemController = TextEditingController();
  
  @override
  void initState(){
    super.initState();
  }

  // same procedure as in other classes, to insert values into 
  //database under given path 
  void addNewItemToDatabase(String itemName, int value) async {
    final databaseReference = Firestore.instance;

    await databaseReference.collection("events").
                            document(widget.documentID).
                            collection("itemList").
                            document().
                            setData({
                              'name' : '$itemName',
                              'valueMax' : value.toInt(),
                              'valueCurrent' : 0
                            });
  }


  // checks if everything is valid and sends after that values to
  //database
  void registerItemByPress() async {
    final _formState = _formKey.currentState;
    
    if(_formState.validate()) {
      _formState.save();

      try{
        
        addNewItemToDatabase(_itemController.text.toString(),
                            _value.toInt());
        
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

  Widget createNewItem() {
    return TextFormField(
      maxLength: 100,
      controller: _itemController,
      decoration: InputDecoration(
        labelText: 'Item'
      ),
      validator: (value) => value.isEmpty ? 'Please create an item' : null,
      onSaved: (value) => _item == value,
    );
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
                          createNewItem(),
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
      title: Center(child: Text('New Item')),
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