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
      FlatButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LogIn()));
        },
        textColor: Theme.of(context).accentColor,
        child: new Text('Return to Sign In'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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