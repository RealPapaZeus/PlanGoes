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
import 'package:plan_go_software_project/colors.dart';

class RegisterEvent extends StatefulWidget {
  final String userId;
  RegisterEvent({Key key, this.userId}) : super(key: key);

  @override
  _RegisterEventState createState() => _RegisterEventState();
}

class _RegisterEventState extends State<RegisterEvent> {
  File _image;
  String _eventName, _location, _description;

  String _documentID;
  Color _tempShadeColor = cPlanGoBlue;
  Color _shadeColor = cPlanGoBlue;
  int _eventColor = cPlanGoBlue.value;
  String _userName = '';

  DateTime _dateTime = DateTime.now();
  DateTime _dateTimeEnd = DateTime.now();
  String _year = DateTime.now().year.toString();
  String _yearEnd = DateTime.now().year.toString();
  String _day = DateTime.now().day.toString();
  String _dayEnd = DateTime.now().day.toString();
  String _month = DateTime.now().month.toString();
  String _monthEnd = DateTime.now().month.toString();
  String _hour = DateTime.now().hour.toString();
  String _hourEnd = DateTime.now().hour.toString();
  String _minute = DateTime.now().minute.toString();
  String _minuteEnd = DateTime.now().minute.toString();

  bool _isLoading = false;

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
      'datetimeEnd': '$datetimeEnd',
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
      'datetimeEnd': '$datetimeEnd',
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
      'valueCurrent': 0,
      'username': []
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

    setState(() {
      _isLoading = true;
    });

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
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print(e.message);
      }
    }
  }

  void callDateTimePickerStart() {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime(2030, 12, 12, 23, 59),
      onChanged: (dateTime) {
        print('change startTime $dateTime &' +
            dateTime.timeZoneOffset.inHours.toString());
      },
      onConfirm: (dateTime) {
        print('confirm startTime $dateTime');
        setState(() {
          _dateTime = dateTime;
          _year = dateTime.year.toString();
          _day = dateTime.day.toString();
          _month = dateTime.month.toString();
          _hour = dateTime.hour.toString();
          _minute = dateTime.minute.toString();

          if (_hour.length < 2) {
            _hour = '0$_hour'.toString();
          }

          if (_minute.length < 2) {
            _minute = '0$_minute'.toString();
          }
        });
      },
      currentTime: DateTime.now(),
      locale: LocaleType.en,
    );
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
          title: Text(
            'Pick Color',
            style: TextStyle(color: cPlanGoDark),
          ),
          content: content,
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(15)),
          actions: [
            FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(40.0),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(color: cPlanGoDark),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(40.0),
              ),
              child: Text('Submit', style: TextStyle(color: cPlanGoDark)),
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
      child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(blurRadius: 10.0, spreadRadius: 0.1)]),
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
          )),
    );
  }

  Widget addPicturePadding() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: IconButton(
        tooltip: 'select picture',
        hoverColor: cPlanGoWhiteBlue,
        splashColor: cPlanGoWhiteBlue,
        color: cPlangGoDarkBlue,
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

  ///
  /// DO NOT DELETE THIS COMMENT! IT IS IMPORTANT FOR FUTURE UPDATES
  ///
  // Widget eventDateTime() {
  //   return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
  //     FlatButton(
  //         onPressed: () {
  //           DatePicker.showDateTimePicker(
  //             context,
  //             showTitleActions: true,
  //             minTime: DateTime.now(),
  //             maxTime: DateTime(2030, 12, 12, 23, 59),
  //             onChanged: (dateTime) {
  //               print('change startTime $dateTime &' +
  //                   dateTime.timeZoneOffset.inHours.toString());
  //             },
  //             onConfirm: (dateTime) {
  //               print('confirm startTime $dateTime');
  //               setState(() {
  //                 _dateTime = dateTime;
  //                 _year = dateTime.year.toString();
  //                 _day = dateTime.day.toString();
  //                 _month = dateTime.month.toString();
  //                 _hour = dateTime.hour.toString();
  //                 _minute = dateTime.minute.toString();
  //                 if (_minute.length < 2) {
  //                   _minute = '0$_minute'.toString();
  //                   _minute = dateTime.minute.toString();
  //                 } else {
  //                   _minute = dateTime.minute.toString();
  //                 }
  //               });
  //             },
  //             currentTime: DateTime.now(),
  //             locale: LocaleType.en,
  //           );
  //         },
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             Text('Date: $_day.$_month.$_year',
  //                 style: TextStyle(color: _shadeColor)),
  //             Text(
  //               'Time: $_hour:$_minute',
  //               style: TextStyle(color: _shadeColor),
  //             )
  //           ],
  //         )),
  //     FlatButton(
  //         onPressed: () {
  //           DatePicker.showDateTimePicker(
  //             context,
  //             showTitleActions: true,
  //             minTime: DateTime.now(),
  //             maxTime: DateTime(2030, 12, 12, 23, 59),
  //             onChanged: (dateTimeEnd) {
  //               print('change endTime $dateTimeEnd');
  //             },
  //             onConfirm: (dateTimeEnd) {
  //               print('confirm endTime $dateTimeEnd');
  //               setState(() {
  //                 _dateTimeEnd = dateTimeEnd;
  //                 _yearEnd = dateTimeEnd.year.toString();
  //                 _dayEnd = dateTimeEnd.day.toString();
  //                 _monthEnd = dateTimeEnd.month.toString();
  //                 _hourEnd = dateTimeEnd.hour.toString();
  //                 _minuteEnd = dateTimeEnd.minute.toString();
  //                 if (_minuteEnd.length < 2) {
  //                   _minuteEnd = '0$_minuteEnd';
  //                   _minuteEnd = dateTimeEnd.minute.toString();
  //                 } else {
  //                   _minuteEnd = dateTimeEnd.minute.toString();
  //                 }
  //               });
  //             },
  //             currentTime: DateTime.now(),
  //             locale: LocaleType.en,
  //           );
  //         },
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             Text('Date: $_dayEnd.$_monthEnd.$_yearEnd',
  //                 style: TextStyle(color: _shadeColor)),
  //             Text(
  //               'Time: $_hourEnd:$_minuteEnd',
  //               style: TextStyle(color: _shadeColor),
  //             )
  //           ],
  //         ))
  //   ]);
  // }

  Widget eventNameTextField() {
    return TextFormField(
      keyboardType: TextInputType.text,
      cursorColor: cPlanGoBlue,
      style: TextStyle(color: cPlanGoMarineBlue),
      maxLength: 50,
      controller: _eventNameController,
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: cPlanGoBlue, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          borderSide: const BorderSide(color: cPlanGoBlue, width: 1.0),
        ),
        errorStyle: TextStyle(color: cPlanGoRedBright),
        labelStyle: TextStyle(color: cPlanGoBlue),
        labelText: 'Eventname'.toLowerCase(),
      ),
      obscureText: false,
      validator: (value) =>
          value.isEmpty ? messageToDenyLoading('Please enter a name') : null,
      onSaved: (value) => _eventName == value,
    );
  }

  Widget eventLocation() {
    return TextFormField(
      keyboardType: TextInputType.text,
      cursorColor: cPlanGoBlue,
      style: TextStyle(color: cPlanGoMarineBlue),
      maxLength: 50,
      controller: _locationController,
      decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: cPlanGoBlue, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            borderSide: const BorderSide(color: cPlanGoBlue, width: 1.0),
          ),
          errorStyle: TextStyle(color: cPlanGoRedBright),
          labelStyle: TextStyle(color: cPlanGoBlue),
          labelText: 'Location'.toLowerCase()),
      obscureText: false,
      validator: (value) => value.isEmpty
          ? messageToDenyLoading('Please enter a location')
          : null,
      onSaved: (value) => _location == value,
    );
  }

  Widget eventDescriptionTextField() {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      cursorColor: cPlanGoBlue,
      style: TextStyle(color: cPlanGoMarineBlue),
      maxLines: 4,
      maxLength: 200,
      controller: _descriptionController,
      decoration: InputDecoration(
          counterStyle: TextStyle(color: cPlanGoDark),
          enabledBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: cPlanGoBlue, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            borderSide: const BorderSide(color: cPlanGoBlue, width: 1.0),
          ),
          errorStyle: TextStyle(color: cPlanGoRedBright),
          labelStyle: TextStyle(color: cPlanGoBlue),
          labelText: 'Description'.toLowerCase()),
      obscureText: false,
      validator: (value) => value.isEmpty
          ? messageToDenyLoading('Please enter some description')
          : null,
      onSaved: (value) => _description == value,
    );
  }

  Widget getDateTimeHeader() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Text(
            'Start Date'.toLowerCase(),
            textAlign: TextAlign.start,
            style: TextStyle(color: cPlanGoBlue, fontSize: 16.0),
          )
        ]));
  }

  Widget eventDateTimeStart() {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: InkWell(
            onTap: callDateTimePickerStart,
            child: Container(
                decoration: BoxDecoration(
                  //border: Border.all(color: cPlanGoBlue, width: 1.0),
                  color: cPlanGoBlue,
                  borderRadius: new BorderRadius.circular(10.0),
                ),
                height: MediaQuery.of(context).size.height / 13,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                            padding: const EdgeInsets.all(6.0),
                            child: Text('date',
                                style: TextStyle(color: cPlanGoWhiteBlue))),
                        Container(
                            padding: const EdgeInsets.all(6.0),
                            child: Text('time',
                                style: TextStyle(color: cPlanGoWhiteBlue))),
                      ],
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                              padding: const EdgeInsets.all(6.0),
                              child: Text('$_day/$_month/$_year',
                                  style: TextStyle(color: cPlanGoWhiteBlue))),
                          Container(
                              padding: const EdgeInsets.all(6.0),
                              child: Text('$_hour:$_minute',
                                  style: TextStyle(color: cPlanGoWhiteBlue))),
                        ])
                  ],
                ))));
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
                  style: new TextStyle(
                      fontWeight: FontWeight.bold, color: cPlanGoDark)),
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

  Widget getRegistrationEventView() {
    return new Padding(
        padding: const EdgeInsets.all(15.0),
        child: Card(
          color: cPlanGoWhiteBlue,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(25.0),
          ),
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
        ));
  }

  Widget showRegistration() {
    return Stack(children: <Widget>[
      Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 3.3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cPlangGoDarkBlue, cPlanGoMarineBlueDark],
            ),
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(90)),
          ),
        ),
      ),
      Scrollbar(child: SingleChildScrollView(child: getRegistrationEventView()))
    ]);
  }

  Widget getEventRegistration() {
    return SizedBox(
        width: 250,
        child: RaisedButton(
          splashColor: cPlanGoMarineBlue,
          color: cPlanGoBlue,
          child: Text(
            'Register',
            style: TextStyle(color: cPlanGoWhiteBlue),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(40.0),
          ),
          elevation: 5.0,
          onPressed: registerEventByPress,
        ));
  }

  Widget loadingButton() {
    return CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(cPlanGoMarineBlue),
    );
  }

  List<Widget> userViewConfirmNewAccount() {
    return [
      Padding(
          padding: EdgeInsets.all(15.0),
          child: _isLoading ? loadingButton() : getEventRegistration())
    ];
  }

  List<Widget> inputWidgets() {
    return [
      eventNameTextField(),
      eventLocation(),
      getDateTimeHeader(),
      eventDateTimeStart(),
      Divider(color: cPlanGoBlue, thickness: 1.5),
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

  Widget getAppBar() {
    return AppBar(
      backgroundColor: cPlangGoDarkBlue,
      elevation: 0.1,
      centerTitle: true,
      title: Text('Register Event'.toLowerCase()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cPlangGoDarkBlue,
      appBar: getAppBar(),
      body: showRegistration(),
    );
  }
}
