import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plan_go_software_project/colors.dart';

class ItemCreateView extends StatefulWidget {
  final String documentID;
  final int eventColor;

  ItemCreateView({Key key, this.documentID, this.eventColor}) : super(key: key);

  @override
  _ItemCreateViewState createState() => new _ItemCreateViewState();
}

class _ItemCreateViewState extends State<ItemCreateView> {
  String _item;
  int _value = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _itemController = TextEditingController();

   String _montserratLight = 'MontserratLight';
  String _montserratMedium = 'MontserratMedium';
  String _montserratRegular = 'MontserratRegular';


  @override
  void initState() {
    super.initState();
  }

  // same procedure as in other classes, to insert values into
  //database under given path
  void addNewItemToDatabase(String itemName, int value) async {
    final databaseReference = Firestore.instance;

    await databaseReference
        .collection("events")
        .document(widget.documentID)
        .collection("itemList")
        .document()
        .setData({
      'name': '$itemName',
      'valueMax': value.toInt(),
      'valueCurrent': 0,
      'username': []
    });
  }

  // checks if everything is valid and sends after that values to
  //database
  void registerItemByPress() async {
    final _formState = _formKey.currentState;

    if (_formState.validate() && _value > 0) {
      _formState.save();

      try {
        addNewItemToDatabase(_itemController.text.toString(), _value.toInt());

        Navigator.pop(context);
      } catch (e) {
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
    if (_value != 0) {
      setState(() {
        _value--;
      });
    }
  }

  Widget createNewItem() {
    return Flexible(
        child: TextFormField(
      keyboardType: TextInputType.text,
      cursorColor: cPlanGoMarineBlue,
      style: TextStyle(color: cPlanGoDark, fontFamily: _montserratMedium),
      maxLength: 50,
      controller: _itemController,
      decoration: InputDecoration(
        counterStyle: TextStyle(color: cPlanGoDark, fontFamily: _montserratMedium),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: cPlanGoMarineBlue, width: MediaQuery.of(context).size.width/350),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: cPlanGoMarineBlue, width: MediaQuery.of(context).size.width/200),
        ),
        errorStyle: TextStyle(color: cPlanGoRedBright, fontFamily: _montserratMedium),
        prefixIcon: Padding(
          padding: EdgeInsets.all(0.0),
          child: Icon(
            Icons.event,
            color: cPlanGoMarineBlue,
          ),
        ),
      ),
      validator: (value) => value.isEmpty ? 'Please create an item' : null,
      onSaved: (value) => _item == value,
    ));
  }

  Widget getValueNumber() {
    return Container(
        padding: const EdgeInsets.only(left: 10.0, bottom: 20.0),
        child: Text(' $_value',
            style: new TextStyle(fontSize: 25.0, color: cPlanGoMarineBlue, fontFamily: _montserratRegular)));
  }

  Widget inputField() {
    return Row(
      children: <Widget>[createNewItem(), getValueNumber()],
    );
  }

  Widget decrementCounterWidget() {
    return FloatingActionButton(
                backgroundColor: cPlanGoMarineBlue,
                splashColor: cPlanGoBlue,
                  child: Icon(Icons.remove),
                  onPressed: () {
                    decrementCounter();
                  });
  }

  Widget incrementCounterWidget() {
    return FloatingActionButton(
                backgroundColor: cPlanGoMarineBlue,
                splashColor: cPlanGoBlue,
                  child: Icon(Icons.add),
                  onPressed: () {
                    incrementCounter();
                  });
  }

  Widget createItemCounter() {
    return new Padding(
        padding: EdgeInsets.only(top: 25.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            decrementCounterWidget(),
            incrementCounterWidget()
          ],
        ));
  }

  SingleChildScrollView itemGeneratorContent() {
    return new SingleChildScrollView(
      child: new Container(
        padding: const EdgeInsets.all(2.5),
        child: new Column(
          children: <Widget>[
            new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Container(
                    child: new Form(
                        key: _formKey,
                        child: new Column(
                          children: <Widget>[inputField(), createItemCounter()],
                        )))
              ],
            ),
          ],
        ),
      ),
    );
  }

  showItemCreatorDialog() {
    return AlertDialog(
      backgroundColor: cPlanGoWhiteBlue,
      title: Center(
          child: Text(
        'New Item',
        style: TextStyle(color: cPlanGoDark, fontFamily: _montserratMedium),
      )),
      content: itemGeneratorContent(),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(35.0),
      ),
      actions: <Widget>[
        FlatButton(
          splashColor: Color(widget.eventColor),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(40.0),
          ),
          onPressed: () {
            registerItemByPress();
          },
          child: Text(
            'Create',
            style: TextStyle(color: cPlanGoMarineBlue, fontFamily: _montserratMedium),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return showItemCreatorDialog();
  }
}
