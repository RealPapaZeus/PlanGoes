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

    if(_formState.validate()){
      _formState.save();

      try{
        AuthResult user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
        Navigator.push(context, MaterialPageRoute(builder: (context) => EventList())); 
        print(_email);
      }catch(e){
        print(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Events'),
      ),
      body: new Form(
        key: _formKey,
        child: new Column(
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email'
              ),
              validator: (value) => value.isEmpty ? 'Please enter Email' : null,
              onSaved: (value) => _email == value,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Enter Password'
              ),
              obscureText: true,
              validator: (value) => value.isEmpty ? 'Please enter Password' : null,
              onSaved: (value) => _password == value,
            ),
            RaisedButton(
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
              child: new Text('Create Account?'),
            ), 
          ],
        )
      ), 
    );
  }
}