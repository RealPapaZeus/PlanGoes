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

  RegisterEvent({Key key,}) : super (key: key);

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


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
 
  // admin creates a new event and this gets stored 
  //in a firebase collection 
  void createEvent(String eventName, String location, String description, int eventColor, String userID) async {
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
        'eventColor': eventColor.toInt()
      });
    
  }
  
  // in this method we create a subcollection whenever a 
  //user creates an event. It is important, because now every user gets his 
  //own eventList
  void insertEventIdToUserCollection(String eventName, String location, String description, int eventColor, String userID, bool admin, String documentReference) async{
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
        'eventColor': eventColor.toInt()
      });
  }


  void registerEventByPress() async {
    final _formState = _formKey.currentState;
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();

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
                    user.uid.toString());
        
        insertEventIdToUserCollection(_eventNameController.text.toString(),
                                      _locationController.text.toString(),
                                      _descriptionController.text.toString(),
                                      _eventColor.toInt(),
                                      user.uid.toString(),
                                      true,
                                      _documentID.toString());

        setState(() {
          _isLoading = false;  
        });

        Navigator.push(context, MaterialPageRoute(builder: (context) => EventList()));

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
      _image=image;
      print('Image Path $_image');
    });
  }

  Future uploadImage(BuildContext context) async{
    String fileName=p.basename(_image.path);
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask= firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot storageTaskSnapshot= await uploadTask.onComplete;
  }

  void _openDialog(Widget content) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text('Pick Color'),
          content: content,
          actions: [
            FlatButton(
              child: Text('CANCEL'),
              onPressed: Navigator.of(context).pop,
            ),
            FlatButton(
              child: Text('SUBMIT'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _shadeColor = _tempShadeColor;
                  _eventColor = _shadeColor.value;
                });
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
    )
    ;
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

  Widget pickColorRow() {
    return Row(
       mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlineButton(
                onPressed:(){
                _openColorPicker();
                },
              child: const Text('Click here to pick Color for Event'),
               ),
              const SizedBox(width: 16.0),
              CircleAvatar(
                backgroundColor: _shadeColor,
                radius: 35.0,
                child: const Text("Event Color", textAlign: TextAlign.center,),
              ),
            ],
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
      eventImage(),
      addPicturePadding(),
      pickColorRow(),
      eventNameTextField(),
      eventLocation(),
      eventDescriptionTextField(),
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Register Event'),
      ),
      body: new SingleChildScrollView(
        child: new Container(
          padding: const EdgeInsets.all(15.0),
          child: new Column(
            children: <Widget>[
              new Card(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Container(
                      padding: new EdgeInsets.all(15.0),
                      child: new Form(
                        key: _formKey,
                        child: new Column(
                          children: 
                            inputWidgets() + userViewConfirmNewAccount()
                            
                        )
                      )
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ), 
    );
  }
}