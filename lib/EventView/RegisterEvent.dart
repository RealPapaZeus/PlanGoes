import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class RegisterEvent extends StatefulWidget {
  final String userId;
  RegisterEvent({Key key, this.userId}) : super(key: key);

  @override
  _RegisterEventState createState() => _RegisterEventState();
}

class _RegisterEventState extends State<RegisterEvent> {
  File _image;
  String _eventName;
  String _location;
  String _description;
  String _documentID;
  Color _tempShadeColor;
  Color _shadeColor = Colors.blue[900];
  int _eventColor = Colors.blue[900].value;
  String _userName = '';
  DateTime _dateTime, _dateTimeEnd = DateTime.now();
  String _year, _yearEnd = DateTime.now().year.toString();
  String _day, _dayEnd = DateTime.now().day.toString();
  String _month, _monthEnd = DateTime.now().month.toString();
  String _hour, _hourEnd = DateTime.now().hour.toString();
  String _minute, _minuteEnd = DateTime.now().minute.toString();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserName();
  }

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

  // admin creates a new event and this gets stored
  //in a firebase collection
  void createEvent(
      String eventName,
      String location,
      String datetime,
      String datetimeEnd,
      String description,
      int eventColor,
      String imageUrl,
      String userID) async {
    final databaseReference = Firestore.instance;

    // needs to be initialized that way, because so
    //we get the documentID seperatly, which is important to add to firebase
    //because otherwise we would have had a n:m relation between collection
    //event and user.
    //the documentID is used for the usersEventCollection!
    DocumentReference documentReference =
        databaseReference.collection("events").document();

    // set before "await" command, otherwise _documentID
    //would be null
    _documentID = documentReference.documentID.toString();

    await documentReference.setData({
      'eventName': '$eventName',
      'location': '$location',
      'datetime': '$datetime',
      'datetimeEnd' : '$datetimeEnd',
      'description': '$description',
      'eventColor': eventColor.toInt(),
      'imageUrl': '$imageUrl'
    });
  }

  // in this method we create a subcollection whenever a
  //user creates an event. It is important, because now every user gets his
  //own eventList
  void insertEventIdToUserCollection(
      String eventName,
      String location,
      String datetime,
      String datetimeEnd,
      String description,
      int eventColor,
      String imageUrl,
      String userID,
      bool admin,
      String documentReference) async {
    final databaseReference = Firestore.instance;

    await databaseReference
        .collection("users")
        .document("$userID")
        .collection("usersEventList")
        .document("$documentReference")
        .setData({
      'admin': admin,
      'eventname': '$eventName',
      'location': '$location',
      'datetime': '$datetime',
      'datetimeEnd' : '$datetimeEnd',
      'description': '$description',
      'eventColor': eventColor.toInt(),
      'imageUrl': '$imageUrl'
    });
  }

  // important to create one item, because otherwise
  // it could call an exception when you swap between different
  // event views and not one item is inside the eventlist
  //
  // Error still exists but there is no possible way to fix it yet!
  void createFirstItemInEvent() async {
    final databaseReference = Firestore.instance;

    await databaseReference
        .collection("events")
        .document(_documentID)
        .collection("itemList")
        .add({
      'name': 'Good Looking $_userName',
      'valueMax': 1,
      'valueCurrent': 0
    });
  }

  // calls all methods which are useful to pass data into
  // database
  void getIntoCollection(String url) {
    getUserName();

    createEvent(
        _eventNameController.text.toString(),
        _locationController.text.toString(),
        _dateTime.toIso8601String(),
        _dateTimeEnd.toIso8601String(),
        _descriptionController.text.toString(),
        _eventColor.toInt(),
        url.toString(),
        widget.userId);

    insertEventIdToUserCollection(
        _eventNameController.text.toString(),
        _locationController.text.toString(),
        _dateTime.toIso8601String(),
        _dateTimeEnd.toIso8601String(),
        _descriptionController.text.toString(),
        _eventColor.toInt(),
        url.toString(),
        widget.userId,
        true,
        _documentID.toString());

    createFirstItemInEvent();
  }

  void registerEventByPress() async {
    final _formState = _formKey.currentState;
    String url;
    // StorageUploadTask needs to be build inside registerEventByPress
    // because otherwise we dont get url String and can not pass it
    // into the database
    if (_image != null) {
      StorageUploadTask uploadTask;

      String fileName = p.basename(_image.path.toString());
      print('Name is ' + '$fileName');
      StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(fileName.toString());

      uploadTask = firebaseStorageRef.putFile(_image);

      final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
      url = (await downloadUrl.ref.getDownloadURL());
    } else {
      url = null;
    }

    if (_formState.validate()) {
      _formState.save();

      try {
        // Calls method for better readability
        getIntoCollection(url);

        Navigator.pop(context);
      } catch (e) {
        print(e.message);
      }
    }
  }

  //whenever user tries to submit and all input strings
  //are empty, _isLoading gets set to false
  String messageToDenyLoading(String message) {
    return '$message';
  }

  // Methods gets image
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      print('Image Path $_image');
    });
  }

  void _openDialog(Widget content) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(12.0),
          title: Text('Pick Color'),
          content: content,
          actions: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: Navigator.of(context).pop,
            ),
            FlatButton(
              child: Text('Submit'),
              onPressed: () {
                setState(() {
                  _shadeColor = _tempShadeColor;
                  _eventColor = _shadeColor.value;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openColorPicker() async {
    _openDialog(
      MaterialColorPicker(
        selectedColor: _shadeColor,
        onColorChange: (color) => setState(() => _tempShadeColor = color),
        onBack: () => print("Back button pressed"),
      ),
    );
  }

  Widget eventImage() {
    return Align(
      alignment: Alignment.center,
      child: CircleAvatar(
        radius: 75,
        child: ClipOval(
          child: SizedBox(
              width: 180,
              height: 180,
              child: (_image != null)
                  ? Image.file(_image, fit: BoxFit.fill)
                  : Image.asset(
                      'images/calendar.png',
                      fit: BoxFit.fill,
                    )),
        ),
      ),
    );
  }

  Widget addPicturePadding() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: IconButton(
        icon: Icon(
          FontAwesomeIcons.camera,
          size: 20,
        ),
        onPressed: () {
          getImage();
        },
      ),
    );
  }

  // calls methods which allow user to pick from list of colors
  Widget pickColorRow() {
    return Padding(
        padding: EdgeInsets.only(top: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text('Event color:',
                  style: new TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              child: FloatingActionButton(
                backgroundColor: _shadeColor,
                onPressed: () {
                  _openColorPicker();
                },
              ),
            )
          ],
        ));
  }

  Widget eventNameTextField() {
    return TextFormField(
      controller: _eventNameController,
      decoration: InputDecoration(labelText: 'Eventname'),
      obscureText: false,
      validator: (value) =>
          value.isEmpty ? messageToDenyLoading('Please enter a name') : null,
      onSaved: (value) => _eventName == value,
    );
  }

  Widget eventLocation() {
    return TextFormField(
      controller: _locationController,
      decoration: InputDecoration(labelText: 'Location'),
      obscureText: false,
      validator: (value) => value.isEmpty
          ? messageToDenyLoading('Please enter a location')
          : null,
      onSaved: (value) => _location == value,
    );
  }

  Widget eventDateTime() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          FlatButton(
              onPressed: () {
                DatePicker.showDateTimePicker(
                  context,
                  showTitleActions: true,
                  minTime: DateTime.now(),
                  maxTime: DateTime(2030, 12, 12, 23, 59),
                  onChanged: (dateTime) {
                    print('change $dateTime');
                  },
                  onConfirm: (dateTime) {
                    print('confirm $dateTime');
                    setState(() {
                      _dateTime = dateTime;
                      _year = dateTime.year.toString();
                      _day = dateTime.day.toString();
                      _month = dateTime.month.toString();
                      _hour = dateTime.hour.toString();
                      _minute = dateTime.minute.toString();
                      if (_minute.length < 2) {
                        _minute = '0$_minute';
                      }
                    });
                  },
                  currentTime: DateTime.now(),
                  locale: LocaleType.en,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Date: $_day.$_month.$_year',
                      style: TextStyle(color: _shadeColor)),
                  Text(
                    'Time: $_hour:$_minute',
                    style: TextStyle(color: _shadeColor),
                  )
                ],
              ))
        ,FlatButton(
              onPressed: () {
                DatePicker.showDateTimePicker(
                  context,
                  showTitleActions: true,
                  minTime: _dateTime,
                  maxTime: DateTime(2030, 12, 12, 23, 59),
                  onChanged: (dateTimeEnd) {
                    print('change $dateTimeEnd');
                  },
                  onConfirm: (dateTimeEnd) {
                    print('confirm $dateTimeEnd');
                    setState(() {
                      _dateTimeEnd = dateTimeEnd;
                      _yearEnd = dateTimeEnd.year.toString();
                      _dayEnd = dateTimeEnd.day.toString();
                      _monthEnd = dateTimeEnd.month.toString();
                      _hourEnd = dateTimeEnd.hour.toString();
                      _minuteEnd = dateTimeEnd.minute.toString();
                      if (_minuteEnd.length < 2) {
                        _minuteEnd = '0$_minuteEnd';
                      }
                    });
                  },
                  currentTime: DateTime.now(),
                  locale: LocaleType.en,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Date: $_dayEnd.$_monthEnd.$_yearEnd',
                      style: TextStyle(color: _shadeColor)),
                  Text(
                    'Time: $_hourEnd:$_minuteEnd',
                    style: TextStyle(color: _shadeColor),
                  )
                ],
              ))]);
  }

  Widget eventDescriptionTextField() {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: 4,
      maxLength: 200,
      controller: _descriptionController,
      decoration: InputDecoration(labelText: 'Description'),
      obscureText: false,
      validator: (value) => value.isEmpty
          ? messageToDenyLoading('Please enter some description')
          : null,
      onSaved: (value) => _description == value,
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: new Container(
        padding: const EdgeInsets.all(15.0),
        child: new Column(
          children: <Widget>[
            new Card(
              elevation: 4.0,
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Container(
                      padding: new EdgeInsets.all(15.0),
                      child: new Form(
                          key: _formKey,
                          child: new Column(
                              children: pickPicture() +
                                  inputWidgets() +
                                  pickColor() +
                                  userViewConfirmNewAccount())))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> userViewConfirmNewAccount() {
    return [
      Padding(
          padding: EdgeInsets.all(15.0),
          child: RaisedButton(
            onPressed: registerEventByPress,
            child: Text('Register Event'),
          ))
    ];
  }

  List<Widget> inputWidgets() {
    return [
      eventNameTextField(),
      eventLocation(),
      eventDateTime(),
      eventDescriptionTextField(),
    ];
  }

  List<Widget> pickPicture() {
    return [
      eventImage(),
      addPicturePadding(),
    ];
  }

  List<Widget> pickColor() {
    return [pickColorRow()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(_eventColor),
      appBar: AppBar(
        backgroundColor: Color(_eventColor),
        elevation: 0.1,
        centerTitle: true,
        title: Text('Register Event'),
      ),
      body: buildBody(),
    );
  }
}
