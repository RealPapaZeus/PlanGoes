import 'package:flutter/material.dart';
import 'package:plan_go_software_project/CreateAccount.dart';
import 'package:plan_go_software_project/EventList.dart';

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

  //variables for LogIn Page
  String _email;
  String _password;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('LogIn'),
      ),
      body: new Form(
        key: _formKey,
        child: new Center(
          child: new Column(
            children: <Widget>[
              TextFormField(
                validator: (input) {
                  if(input.isEmpty){
                    return 'Please enter an Email';
                  }
                },
                onSaved: (input) => _email == input,
                decoration: InputDecoration(
                  labelText: 'Email'
                ),
              ),
              TextFormField(
                validator: (input) {
                  if(input.length < 6){
                    return 'Password is too short';
                  }
                },
                onSaved: (input) => _password == input,
                decoration: InputDecoration(
                  labelText: 'Password'
                ),
                obscureText: true,
              ),
              FloatingActionButton(
                onPressed: (){},
                child: Text('Sign in')
              ),
              FlatButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateAccount()));
                },
                textColor: Theme.of(context).accentColor,
                child: new Text('Create Account?'),
              )
            ],
          )
        )
      ), 
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => EventList()));
        },
        child: Icon(Icons.accessible),
      )
    );
  }

  void _signIn(){
    final _formState = _formKey.currentState;

    if(_formState.validate()){
      
    }
  }

  // Widget buildForm(){
  //   return Form(
  //     child: 
  //   )

  // }
}