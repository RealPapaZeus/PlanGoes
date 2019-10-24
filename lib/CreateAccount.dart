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
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  @override 
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //gets called whenever a user tries to call signIn, but input for email 
  //and password is empty. _isLoading gets set to false, so the 
  //CircularIndicator does not get called 
  String messageNotifier(String message) {
    _isLoading = false;
    return '$message';
  }

  Widget textFormFieldExtension(TextEditingController _controller, String _inputLabelText, String _message, String _typeOfInput) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: '$_inputLabelText'
      ),
      validator: (value) => value.isEmpty ? messageNotifier('$_message') : null,
      onSaved: (value) => _typeOfInput == value,
    );
  }

  List<Widget> submitWidgets() {
    return[
      textFormFieldExtension(_emailController, 'Email', 'Please enter an email', _email),
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
        controller: _passwordConfirmController,
        decoration: InputDecoration(
          labelText: 'Confirm password'
        ),
        obscureText: true,
        validator: (value) => value.isEmpty ? 'Please enter a password' : null,
        onSaved: (value) => _password == value,
      ),
    ];
  }

  List<Widget> userViewConfirmNewAccount() {
    return [
      Padding(
        padding: EdgeInsets.all(15.0),
        child: _isLoading
                  ? Center(child: new CircularProgressIndicator())
                  : RaisedButton(
                      onPressed: (){},
                      child: Text('Create new Account'),
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
            ],
          ),
        ),
      ), 
    );
  }
}