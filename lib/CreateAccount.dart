import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:plan_go_software_project/UserName.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateAccount extends StatefulWidget {

  CreateAccount({Key key,}) : super(key: key);

  @override
  _CreateAccountState createState() => new _CreateAccountState();
}
  
class _CreateAccountState extends State<CreateAccount>{

  //defining new variables to allow user create a new account
  //with password he chooses

  String _email;
  String _password;
  String _authHint = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override 
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void createNewAccount() async{
    final _formState = _formKey.currentState;

    setState(() {
      _isLoading = true;  
    });
    
    if(_formState.validate()){
      _formState.save();

      try{
        AuthResult user = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text.toString().trim(),
                                                                      password: _passwordController.text);
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserName())); 
        setState(() {
          _isLoading = false;
          _authHint = '';
        });
      }catch(e){
        setState(() {
          _isLoading = false; 
         _authHint = 'The email address is already in use by another account';
        });
        print(e.message);
      }
    }
  }
  
  //gets called whenever a user tries to call signIn, but input for email 
  //and password is empty. _isLoading gets set to false, so the 
  //CircularIndicator does not get called 
  String messageNotifier(String message) {
    _isLoading = false;
    return '$message';
  }
  
  //it gives the user a notification if 
  //a mistake appeared. For instance if an email 
  //is already in use by another user
  Widget registrationSucessMessage() {
    return new Container(
      child: Text(
        _authHint,
        style: TextStyle(
          color: Colors.red
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  //Widgets do only return a TextFormField 
  //whenever a new TextFormField gets created
  Widget emailTextFormField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email'
      ),
      obscureText: false,
      validator: (value) => value.isEmpty ? messageNotifier('Please enter an email') : null,
      onSaved: (value) => _email == value,
    );
  }

  Widget passwordTextFormField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
              ? Icons.visibility
              : Icons.visibility_off
          ),
          onPressed: (){
            setState(() {
              _obscurePassword = !_obscurePassword;  
            });
          },
        ),
      ),
      validator: (value) => value.isEmpty ? messageNotifier('Please enter a password') : null,
      onSaved: (value) => _password == value,
    );
  }
  //calls the method which builds TextFormField with given parameters
  //it helps to read the code more efficient
  List<Widget> submitWidgets() {
    return[
      emailTextFormField(),
      passwordTextFormField()
    ];
  }

  List<Widget> userViewConfirmNewAccount() {
    return [
      Padding(
        padding: EdgeInsets.all(15.0),
        child: _isLoading
                  ? Center(child: new CircularProgressIndicator())
                  : RaisedButton(
                      onPressed: createNewAccount,
                      child: Text('Create new account'),
                  )
        )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('CreateAccount'),
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
                            submitWidgets() + userViewConfirmNewAccount()
                        )
                      )
                    )
                  ],
                ),
              ),
              registrationSucessMessage()
            ],
          ),
        ),
      ), 
    );
  }
}