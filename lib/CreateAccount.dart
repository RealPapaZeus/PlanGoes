import 'package:flutter/material.dart';
import 'package:plan_go_software_project/UserName.dart';

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

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState(){
    super.initState();
  }

  List<Widget> submitWidgets() {
    return[
      TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'Email'
        ),
        validator: (value) => value.isEmpty ? 'Please enter an email' : null,
        onSaved: (value) => _email == value,
      ),
      TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Password'
        ),
        obscureText: true,
        validator: (value) => value.isEmpty ? 'Please enter a password' : null,
        onSaved: (value) => _password == value,
      ),
      TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Confirm password'
        ),
        obscureText: true,
        validator: (value) => value.isEmpty ? 'Please enter a password' : null,
        onSaved: (value) => _password == value,
      ),
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
                            submitWidgets() 
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