import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plan_go_software_project/EventView/EventList.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

class RegisterEvent extends StatefulWidget {

  final String userId;
  RegisterEvent({
    Key key,
    this.userId
    }) : super (key: key);

  @override
  _RegisterEventState createState() => _RegisterEventState();
}

class _RegisterEventState extends State<RegisterEvent> {

  File _image;
  String _eventName;
  String _location;
  String _description;
  bool _isLoading = false;
  String _documentID;
  Color _tempShadeColor;
  Color _shadeColor = Colors.blue[900];
  int _eventColor = Colors.blue[900].value;
  String _url = '';


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  @override
  void initState(){
    super.initState();
    uploadImage(context);
  }

  // admin creates a new event and this gets stored 
  //in a firebase collection 
  void createEvent(String eventName, String location, String description, int eventColor,String imageUrl, String userID) async {
    final databaseReference = Firestore.instance;
    
    // needs to be initialized that way, because so 
    //we get the documentID seperatly, which is important to add to firebase
    //because otherwise we would have had a n:m relation between collection
    //event and user. 
    //the documentID is used for the usersEventCollection!
    DocumentReference documentReference = databaseReference.
                                          collection("events").
                                          document();

    // set before "await" command, otherwise _documentID
    //would be null 
    _documentID = documentReference.documentID.toString();

    await documentReference.
      setData({
        //'admins' : ["$userID"],
        'eventName': '$eventName',
        'location' : '$location',
        'description': '$description',
        'eventColor': eventColor.toInt(),
        'imageUrl': '$imageUrl'
      });
    
  }
  
  // in this method we create a subcollection whenever a 
  //user creates an event. It is important, because now every user gets his 
  //own eventList
  void insertEventIdToUserCollection(String eventName, String location, String description, int eventColor,String imageUrl, String userID, bool admin, String documentReference) async{
    final databaseReference = Firestore.instance;
    
    await databaseReference.collection("users").
      document("$userID").
      collection("usersEventList").
      document("$documentReference").
      setData({
        'admin' : admin,
        'eventname' : '$eventName',
        'location'  : '$location',
        'description' : '$description',
        'eventColor': eventColor.toInt(),
        'imageUrl': '$imageUrl'
      });
  }


  void registerEventByPress() async {
    final _formState = _formKey.currentState;

    setState(() {
      _isLoading = true;  
    });

    if(_formState.validate()) {
      _formState.save();

      try{
        uploadImage(context);

        createEvent(_eventNameController.text.toString(),
                    _locationController.text.toString(),
                    _descriptionController.text.toString(),
                    _eventColor.toInt(),
                    _url.toString(),
                    widget.userId);
        
        insertEventIdToUserCollection(_eventNameController.text.toString(),
                                      _locationController.text.toString(),
                                      _descriptionController.text.toString(),
                                      _eventColor.toInt(),
                                      _url.toString(),
                                      widget.userId,
                                      true,
                                      _documentID.toString());

        setState(() {
          _isLoading = false;  
        });

        Navigator.pop(context);

      } catch(e) {

        setState(() {
          _isLoading = false;  
        });

        print(e.message);
      }
    }
  }

  //whenever user tries to submit and all input strings 
  //are empty, _isLoading gets set to false
  String messageToDenyLoading(String message) {
    _isLoading = false;
    return '$message';
  }

  Future getImage() async{
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      print('Image Path $_image');
    });
  }

  Future uploadImage(BuildContext context) async{
    StorageUploadTask uploadTask;

    String fileName = p.basename(_image.path.toString());
    print('Name is ' + '$fileName');
    StorageReference firebaseStorageRef = FirebaseStorage.
                                          instance.
                                          ref().
                                          child(fileName.toString());
    
    print('image: '  + '$_image');
    
    uploadTask = firebaseStorageRef.putFile(_image);

    uploadTask.onComplete.then((onValue) async{
      _url = (await firebaseStorageRef.getDownloadURL()).toString();
      print(_url);
    });
    
    print(_url);

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
            child: (_image!=null)? Image.file(_image,fit: BoxFit.fill)
            :Image.network(
              'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=967&q=80',
              fit: BoxFit.fill,
            ),
          ),
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
        onPressed: (){
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
                child: Text(
                  'Event color:', 
                   style: new TextStyle(fontWeight: FontWeight.bold)
                ),
              ),
              Container(
                child: FloatingActionButton(
                  backgroundColor: _shadeColor,
                  onPressed: () {_openColorPicker();},
                ),
              )
            ],
      )      
    );
  }

  Widget eventNameTextField() {
    return TextFormField(
      controller: _eventNameController,
      decoration: InputDecoration(
        labelText: 'Eventname'
      ),
      obscureText: false,
      validator: (value) => value.isEmpty ? messageToDenyLoading('Please enter a name') : null,
      onSaved: (value) => _eventName == value,
    );
  }

  Widget eventLocation() {
    return TextFormField(
      controller: _locationController,
      decoration: InputDecoration(
        labelText: 'Location'
      ),
      obscureText: false,
      validator: (value) => value.isEmpty ? messageToDenyLoading('Please enter a location') : null,
      onSaved: (value) => _location == value,
    );
  }

  Widget eventDescriptionTextField() {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: 4,
      maxLength: 200,
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description'
      ),
      obscureText: false,
      validator: (value) => value.isEmpty ? messageToDenyLoading('Please enter some description') : null,
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
                        children: 
                          pickPicture()
                          + inputWidgets() 
                          + pickColor()
                          + userViewConfirmNewAccount()
                      )
                    )
                  )
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
        child: _isLoading
                  ? Center(child: new CircularProgressIndicator())
                  : RaisedButton(
                      onPressed: registerEventByPress,
                      child: Text('Register Event'),
                  )
        )
    ];
  }

  List<Widget> inputWidgets() {
    return [
      eventNameTextField(),
      eventLocation(),
      eventDescriptionTextField(),
    ];
  }

  List<Widget> pickPicture(){
    return[
      eventImage(),
      addPicturePadding(),
    ];
  }

  List<Widget> pickColor() {
    return[
      pickColorRow()
    ];
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