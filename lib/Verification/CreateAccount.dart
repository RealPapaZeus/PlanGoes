import 'package:flutter/material.dart';
import 'package:plan_go_software_project/Verification/LogIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAccount extends StatefulWidget {

  CreateAccount({Key key,}) : super(key: key);

  @override
  _CreateAccountState createState() => new _CreateAccountState();
}
  
class _CreateAccountState extends State<CreateAccount>{

  String _email;
  String _password;
  String _username;
  String _authHint = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override 
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void createUserInCollection(String userID, String email, String username) async {
    final databaseReference = Firestore.instance;

    await databaseReference.collection("users")
        .document('$userID')
        .setData({
          'email': '$email',
          'username': '$username'
        });
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
        
        createUserInCollection(user.user.uid, _emailController.text, _usernameController.text);
       
        user.user.sendEmailVerification();
        
        showAlterDialogVerification(context, _emailController.text);

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
  
  //gives user a hint to verify email before he can continue 
  //login process
  Future<void> showAlterDialogVerification(BuildContext context, String _email) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verify Your Email Address'),
          content: RichText(
            text: new TextSpan(
              style: new TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                new TextSpan(text: 'We like you to verify your email address. We have sent an email to '),
                new TextSpan(text: '$_email', style: new TextStyle(fontWeight: FontWeight.bold)),
                new TextSpan(text: ' to verify your address. Please click the link in that email to continue.')
              ]
            )
          ),
          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(15)),
          actions: <Widget>[
            FlatButton(
              onPressed:(){
                 Navigator.push(context, MaterialPageRoute(builder: (context) => LogIn()));
              },
              child: Text('Okay, got it'),
            )
          ],
        );
      }
    );
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
        prefixIcon: Icon(Icons.email),
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
        prefixIcon: Icon(Icons.lock),
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
      
      validator: (value){ 
        if (value.isEmpty)
          return messageNotifier('Please enter a password');
        else {
          if (value.toString().length <= 8)
            return messageNotifier('Password has to be 8 digits long');
          else
            return null;
        } 
      },
      onSaved: (value) => _password == value,
    );
  }
  Widget userNameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person),
        labelText: 'Username'
      ),
      obscureText: false,
      validator: (value) => value.isEmpty ? messageNotifier('Please enter an username') : null,
      onSaved: (value) => _username == value,
    );
  }

  //calls the method which builds TextFormField with given parameters
  //it helps to read the code more efficient
  List<Widget> submitWidgets() {
    return[
      emailTextFormField(),
      passwordTextFormField(),
      userNameField()
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
        title: Text('Create Account'),
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