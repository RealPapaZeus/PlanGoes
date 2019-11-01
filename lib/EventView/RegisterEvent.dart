import 'package:flutter/material.dart';

class RegisterEvent extends StatefulWidget {

  RegisterEvent({Key key,}) : super (key: key);

  @override
  _RegisterEventState createState() => _RegisterEventState();
}

class _RegisterEventState extends State<RegisterEvent> {

  String _eventName;
  String _description;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Widget eventNameTextField() {
    return TextFormField(
      controller: _eventNameController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Eventname'
      ),
      obscureText: false,
      validator: (value) => value.isEmpty ? 'Please enter a name' : null,
      onSaved: (value) => _eventName == value,
    );
  }

  Widget eventDescriptionTextField() {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: 4,
      maxLength: 150,
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description'
      ),
      obscureText: false,
      validator: (value) => value.isEmpty ? 'Please enter some description' : null,
      onSaved: (value) => _description == value,
    );
  }

  List<Widget> inputWidgets() {
    return [
      eventNameTextField(),
      eventDescriptionTextField(),
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                            inputWidgets()
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