import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plan_go_software_project/colors.dart';

class ItemPickDialog extends StatefulWidget {
  final String userId;
  final String documentId;
  final String itemDocumentId;

  ItemPickDialog({Key key, this.userId, this.documentId, this.itemDocumentId})
      : super(key: key);

  @override
  _ItemPickDialogState createState() => new _ItemPickDialogState();
}

class _ItemPickDialogState extends State<ItemPickDialog> {
  String _itemName = '';
  String _userName = '';
  String _documentId = '';

  int _value = 0;
  int _valueCurrent = 0;
  int _valueMax = 0;
  int _valueMin = 0;
  int _valueUserItem = 0;
  int _valueUserItemOld = 0;

  String _montserratLight = 'MontserratLight';
  String _montserratMedium = 'MontserratMedium';
  String _montserratRegular = 'MontserratRegular';

  @override
  void initState() {
    super.initState();
    getItemInformation();
    getUserName();
    getUsersItemAmount();
    getDocumentId();
  }

  void deleteItem() {
    final databaseReference = Firestore.instance;
    databaseReference
        .collection('events')
        .document(widget.documentId)
        .collection('itemList')
        .document(widget.itemDocumentId)
        .collection('usersItemList')
        .document(widget.userId)
        .delete();
  }

  void deleteUserFromArray(String userName) async {
    final databaseReference = Firestore.instance;

    await databaseReference
        .collection("events")
        .document(widget.documentId)
        .collection("itemList")
        .document(widget.itemDocumentId)
        .updateData({
      "username": FieldValue.arrayRemove([userName.toString()])
    });
  }

  void getItemInformation() async {
    final databaseReference = Firestore.instance;
    var documentReference = databaseReference
        .collection("events")
        .document(widget.documentId)
        .collection("itemList")
        .document(widget.itemDocumentId);

    documentReference.get().then((DocumentSnapshot document) {
      setState(() {
        _itemName = document['name'];
        _valueMax = document['valueMax'];
        _valueCurrent = document['valueCurrent'];
        _valueMin = document['valueCurrent'];
      });
    });
  }

  void getDocumentId() async {
    final databaseReference = Firestore.instance;

    final snapshot = await databaseReference
        .collection("events")
        .document(widget.documentId)
        .collection("itemList")
        .document(widget.itemDocumentId)
        .collection("usersItemList")
        .document(widget.userId)
        .get();

    if (!snapshot.exists) {
      print("snapshot does not exists");
    } else {
      _documentId = widget.userId;
      print("snapshot exists");
    }
  }

  void getUsersItemAmount() async {
    final databaseReference = Firestore.instance;
    var documentReference = databaseReference
        .collection("events")
        .document(widget.documentId)
        .collection("itemList")
        .document(widget.itemDocumentId)
        .collection("usersItemList")
        .document(widget.userId);

    documentReference.get().then((DocumentSnapshot document) {
      setState(() {
        _valueUserItem = document['value'];
        _valueUserItemOld = document['value'];
      });
      print("valueUserItem: " + _valueUserItem.toString());
      print("valueUserItemOld: " + _valueUserItemOld.toString());
    });
  }

  // Get username to display in itemList and get sure,
  // who is getting which item
  void getUserName() async {
    final databaseReference = Firestore.instance;
    var documentReference =
        databaseReference.collection("users").document(widget.userId);

    documentReference.get().then((DocumentSnapshot document) {
      setState(() {
        _userName = document['username'].toString();
      });
    });
    print(_userName);
  }

  void addNewItemToDatabase(String userName, int value) async {
    final databaseReference = Firestore.instance;

    await databaseReference
        .collection("events")
        .document(widget.documentId)
        .collection("itemList")
        .document(widget.itemDocumentId)
        .collection("usersItemList")
        .document(widget.userId)
        .setData({
      'user': '$userName',
      'value': value,
    });
  }

  void updateItemUser(int value) async {
    final databaseReference = Firestore.instance;

    var documentReference = databaseReference
        .collection("events")
        .document(widget.documentId)
        .collection("itemList")
        .document(widget.itemDocumentId)
        .collection("usersItemList")
        .document(widget.userId);

    documentReference.get().then((DocumentSnapshot document) async {
      await documentReference.updateData({"value": value});
    });
  }

  void addNewValueToItemList(int value) async {
    final databaseReference = Firestore.instance;

    await databaseReference
        .collection("events")
        .document(widget.documentId)
        .collection("itemList")
        .document(widget.itemDocumentId)
        .updateData({"valueCurrent": value});
  }

  void addUsernameToItem(String userName) async {
    final databaseReference = Firestore.instance;

    await databaseReference
        .collection("events")
        .document(widget.documentId)
        .collection("itemList")
        .document(widget.itemDocumentId)
        .updateData({
      "username": FieldValue.arrayUnion([userName.toString()])
    });
  }

  void callDatabaseInserts() {
    if (_documentId == widget.userId) {
      if (_valueUserItem != 0) {
        updateItemUser(_valueUserItem);
        addNewValueToItemList(_valueCurrent);
      } else if (_valueUserItem == 0) {
        deleteItem();
        deleteUserFromArray(_userName.toString());
        addNewValueToItemList(_valueCurrent);
      }
    } else {
      if (_valueCurrent != 0 && _value != 0) {
        addNewItemToDatabase(_userName.toString(), _value);
        addNewValueToItemList(_valueCurrent);
        updateItemUser(_value);
        addUsernameToItem(_userName);
      }
    }
  }

  void incrementCounter() {
    setState(() {
      if (_valueCurrent < _valueMax) {
        _valueCurrent++;
        _value++;
        _valueUserItem++;
      }
    });
  }

  void decrementCounter() {
    setState(() {
      if (_documentId == widget.userId) {
        if (_valueUserItem != 0) {
          _valueUserItem--;
          _valueCurrent--;
          _value--;
        }
      } else {
        if (_valueCurrent != 0 && _valueCurrent != _valueMin) {
          _valueCurrent--;
          _value--;
        }
      }
    });
  }

  // checks if everything is valid and sends after that values to
  //database
  void registerItemByPress() async {
    try {
      callDatabaseInserts();

      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  StreamBuilder buildUsersItemStream(BuildContext context) {
    final databaseReference = Firestore.instance;

    return new StreamBuilder(
      stream: databaseReference
          .collection("events")
          .document(widget.documentId)
          .collection("itemList")
          .document(widget.itemDocumentId)
          .collection("usersItemList")
          .orderBy("value", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: Text("Loading..", style: TextStyle(fontFamily: _montserratMedium),));
        return ListView.builder(
          scrollDirection: Axis.vertical,
          itemExtent: 50,
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
            child: Text(
              document['user'],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: _montserratMedium, color: cPlanGoDark),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 5.0, right: 5.0),
            decoration: new BoxDecoration(
                border: new Border(
                    left: new BorderSide(width: 1, color: cPlanGoDark))),
            child: Text(
              document['value'].toString(),
              style: TextStyle(fontFamily: _montserratMedium),
            ),
          ),
        ],
      ),
    );
  }

  Widget getUsersItems() {
    return Container(
        height: MediaQuery.of(context).size.height / 3.5,
        width: MediaQuery.of(context).size.width / 1.5,
        decoration: BoxDecoration(
            border:
                new Border(top: new BorderSide(width: 1, color: cPlanGoDark))),
        child: new Scrollbar(
            child: new Scaffold(
          backgroundColor: cPlanGoWhiteBlue,
          body: buildUsersItemStream(context),
        )));
  }

  // Widget itemValueUser() {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: <Widget>[
  //         Container(child: Text('Your value:')),
  //         Container(
  //           child: Text('$_value', style: new TextStyle()),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget itemValue() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(child: Text('Total value:', style: TextStyle(fontFamily: _montserratMedium),)),
          Container(
            child: Text('$_valueCurrent / $_valueMax', style: new TextStyle(fontFamily: _montserratMedium)),
          )
        ],
      ),
    );
  }

  Widget decrementCounterButton() {
    return FloatingActionButton(
        backgroundColor: cPlanGoMarineBlue,
        splashColor: cPlanGoBlue,
        child: Icon(Icons.remove, color: cPlanGoWhiteBlue),
        onPressed: () {
          decrementCounter();
        });
  }

  Widget incrementCounterButton() {
    return FloatingActionButton(
        backgroundColor: cPlanGoMarineBlue,
        splashColor: cPlanGoBlue,
        child: Icon(Icons.add, color: cPlanGoWhiteBlue,),
        onPressed: () {
          incrementCounter();
        });
  }

  Widget createItemCounter() {
    return new Container(
      height: MediaQuery.of(context).size.height/10,
      width: MediaQuery.of(context).size.height/2.5,
      child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              decrementCounterButton(),
              incrementCounterButton()
            ],
          )),
    );
  }

  Widget displayElements() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        getUsersItems(),
        //itemValueUser(),
        itemValue(),
        createItemCounter(),
      ],
    );
  }

  showItemCreatorDialog() {
    return AlertDialog(
      backgroundColor: cPlanGoWhiteBlue,
      title: Center(
          child: Text(
        _itemName,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: cPlanGoDark, fontFamily: _montserratMedium),
      )),
      content: displayElements(),
      shape:
          RoundedRectangleBorder(borderRadius: new BorderRadius.circular(25.0)),
      actions: <Widget>[
        FlatButton(
            splashColor: cPlanGoBlueGrey,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(40.0),
            ),
            onPressed: () {
              registerItemByPress();
            },
            child: Text(
              'Save',
              style: TextStyle(color: cPlanGoMarineBlue, fontFamily: _montserratMedium),
            ))
      ],
    );
  } 

  @override
  Widget build(BuildContext context) {
    return showItemCreatorDialog();
  }
}
