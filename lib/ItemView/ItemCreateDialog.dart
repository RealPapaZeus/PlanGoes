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
          cursorColor: Color(widget.eventColor),
                  style: TextStyle(color: Color(widget.eventColor)),

      maxLength: 100,
      controller: _itemController,
      decoration: InputDecoration(
        counterStyle: TextStyle(color: Color(widget.eventColor)),
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(widget.eventColor), width: 1.5),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(widget.eventColor), width: 2.0),
          ),
        prefixIcon: Padding(
            padding: EdgeInsets.all(0.0),
            child: Icon(
              Icons.event,
              color: Color(widget.eventColor),
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
        
        child: Text('/$_value',
            style: new TextStyle(fontSize: 25.0, color: Color(widget.eventColor))));
  }

  Widget inputField() {
    return Row(
      children: <Widget>[
        createNewItem(),
        getValueNumber()
        ],
    );
  }

  Widget decrementCounterWidget() {
    return ClipOval(
      child: Container(
        color: Color(widget.eventColor),
        child: IconButton(
            splashColor: cPlanGoWhiteBlue,
            icon: Icon(
              Icons.remove,
              color: cPlanGoWhiteBlue,
            ),
            onPressed: () {
              decrementCounter();
            }),
      ),
    );
  }

  Widget incrementCounterWidget() {
    return ClipOval(
      child: Container(
        color: Color(widget.eventColor),
        child: IconButton(
            splashColor: cPlanGoWhiteBlue,
            icon: Icon(
              Icons.add,
              color: cPlanGoWhiteBlue,
            ),
            onPressed: () {
              incrementCounter();
            }),
      ),
    );
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
      title: Center(child: Text('New Item', style: TextStyle(color: cPlanGoDark),)),
      content: itemGeneratorContent(),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(25.0),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            registerItemByPress();
          },
          child: Text('Create', style: TextStyle(color: Color(widget.eventColor)),),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return showItemCreatorDialog();
  }
}
