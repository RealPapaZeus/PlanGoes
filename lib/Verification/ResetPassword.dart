import 'dart:wasm';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plan_go_software_project/Verification/LogIn.dart';

class ResetPassword extends StatefulWidget {
  
  ResetPassword({Key key,}) : super(key: key);

  @override
  _ResetPasswordState createState() => new _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  
  String _email;
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override 
  void dispose(){
    _emailController.dispose();
    super.dispose();
  }

  //method is important because otherwise, calling "sendPasswordResetEmail"
  //throws an error, because of TypeException. It says it should consist of 
  //void. Therefore you have to call "resetPassword" inside "sendPasswordReset"
  Future resetPassword(String email) async {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  void sendPasswordReset() async {
    final _formState = _formKey.currentState;

    setState(() {
      _isLoading = true;  
    });

    if(_formState.validate()) {
      _formState.save();

      try{
        
        await resetPassword(_emailController.text.toString().trim());

        showAlterDialogVerification(context, _emailController.text);

        setState(() {
          _isLoading = false;
        });

      } catch(e) {
          setState(() {
            _isLoading = false; 
          });

          print(e.message);
      }
    }
  }

  Future<void> showAlterDialogVerification(BuildContext context, String _email) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Email Reset'),
          content: RichText(
            text: new TextSpan(
              style: new TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                new TextSpan(text: 'We just sent you a link to '),
                new TextSpan(text: '$_email', style: new TextStyle(fontWeight: FontWeight.bold)),
                new TextSpan(text: ' to reset your password. Please click the link in that email to continue.')
              ]
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(15)),
          actions: <Widget>[
            FlatButton(
              onPressed:(){Navigator.of(context).pop();},
              child: Text('Okay'),
            )
          ],
        );
      }
    );
  }

  String messageNotifier(String message) {
    _isLoading = false;
    return '$message';
  }

  Widget emailTextFormField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email),
        labelText: 'Email'
      ),
      obscureText: false,
      validator: (value) => value.isEmpty ? messageNotifier('Please enter an email') : null,
      onSaved: (value) => _email == value,
    );
  }

  //has to be inside a List because otherwise we can not 
  //call this method inside our build(). The reason is inside our
  //build() it is looking for a List of Widgets. 
  List<Widget> submitWidgets() {
    return [
      emailTextFormField()
    ];
  }

  List<Widget> userResetPassword() {
    return [
      Padding(
        padding: EdgeInsets.all(15.0),
        child: _isLoading
                  ? Center(child: new CircularProgressIndicator())
                  : RaisedButton(
                      onPressed: sendPasswordReset,
                      child: Text('Submit'),
                  )
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Reset Password'),
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
                            submitWidgets() + userResetPassword()
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