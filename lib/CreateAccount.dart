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
  String _passwordConfirm; 
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
          //_authHint = '';
        });
      }catch(e){
        setState(() {
          _isLoading = false; 
         // _authHint = 'Email or password is invalid';
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

  //it only returns the TextFormField Widget
  //we have to fill the parameters, so only this method needs to get called
  //whenever a new TextFormField gets created
  Widget textFormFieldExtension(TextEditingController _controller,
                                 String _inputLabelText,
                                  bool _obscureText,
                                   String _message,
                                    String _typeOfInput) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: '$_inputLabelText'
      ),
      obscureText: _obscureText,
      validator: (value) => value.isEmpty ? messageNotifier('$_message') : null,
      onSaved: (value) => _typeOfInput == value,
    );
  }

  //calls the method which builds TextFormField with given parameters
  //it helps to read the code more efficient
  List<Widget> submitWidgets() {
    return[
      textFormFieldExtension(_emailController, 'Email', false,'Please enter an email', _email),
      textFormFieldExtension(_passwordController, 'Password', true, 'Please enter a password', _password),
      textFormFieldExtension(_passwordConfirmController, 'Confirm Password', true, 'Please confirm password', _passwordConfirm)
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
            ],
          ),
        ),
      ), 
    );
  }
}