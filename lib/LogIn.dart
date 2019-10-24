import 'package:flutter/material.dart';
import 'package:plan_go_software_project/CreateAccount.dart';
import 'package:plan_go_software_project/EventList.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogIn extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LogIn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyLogInPage(),
    );
  }
}

class MyLogInPage extends StatefulWidget {
  MyLogInPage({Key key}) : super(key: key);


  @override
  _MyLogInPageState createState() => _MyLogInPageState();
} 

class _MyLogInPageState extends State<MyLogInPage> {

  String _email;
  String _password;
  String _authHint = '';
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override 
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void signIn() async{
    final _formState = _formKey.currentState;

    setState(() {
      _isLoading = true;  
    });
    
    if(_formState.validate()){
      _formState.save();

      try{
        AuthResult user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text.toString().trim(),
                                                                      password: _passwordController.text);
        Navigator.push(context, MaterialPageRoute(builder: (context) => EventList())); 
        setState(() {
          _isLoading = false;
          _authHint = '';
        });
      }catch(e){
        setState(() {
          _isLoading = false; 
          _authHint = 'Email or password is invalid';
        });
        print(e.message);
      }
    }
  }

  //gets called when user tries to call signIn, but input for email 
  //and password is empty. _isLoading gets set to false, so the 
  //Indicator does not get called 
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

  List<Widget> submitWidgets() {
    return[
      textFormFieldExtension(_emailController , 'Email', false, 'Please enter an email', _email),
      textFormFieldExtension(_passwordController , 'Password', true,'Please enter a password', _password)
    ];
  }

  List<Widget> navigateWidgets() {
    return[
      _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : RaisedButton(
            onPressed: signIn,
            child: Text('Sign in')
          ),  
      FlatButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateAccount()));
        },
        textColor: Theme.of(context).accentColor,
        child: new Text('Create account?'),
      ),
    ];
  }

  Widget signInSuccess() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('LogIn'),
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
                            submitWidgets() +
                            navigateWidgets()
                        )
                      )
                    )
                  ],
                ),
              ),
              signInSuccess()
            ],
          ),
        ),
      ), 
    );
  }
}