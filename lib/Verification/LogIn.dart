import 'package:flutter/material.dart';
import 'package:plan_go_software_project/Verification/CreateAccount.dart';
import 'package:plan_go_software_project/EventView/EventList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plan_go_software_project/Verification/ResetPassword.dart';
import 'package:plan_go_software_project/colors.dart';

class LogIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  bool _obscurePassword = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void signIn() async {
    final _formState = _formKey.currentState;

    setState(() {
      _isLoading = true;
    });

    if (_formState.validate()) {
      _formState.save();

      //.trim() leaves no space at the end of the email
      //so a bad formatting exception wont be thrown
      try {
        AuthResult user = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _emailController.text.toString().trim(),
                password: _passwordController.text);

        if (user.user.isEmailVerified) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EventList(userId: user.user.uid)));
          setState(() {
            _isLoading = false;
            _authHint = '';
          });
        } else {
          setState(() {
            _isLoading = false;
            _authHint = 'Please verify your email';
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _authHint = 'Email or password is invalid';
        });
        print(e.message);
      }
    }
  }

  //gets called when user tries to call signIn
  String messageNotifier(String message) {
    _isLoading = false;
    return '$message';
  }

  //it only returns the TextFormField Widget
  Widget emailTextFormField() {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0, right: 6.0),
      child: TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: cPlanGoBlue, width: 1.0),
          ),
          prefixIcon: Icon(
            Icons.email),
          labelText: 'Email',
          labelStyle: TextStyle(
            color: cPlanGoBlue
          )),
        obscureText: false,
        validator: (value) =>
            value.isEmpty ? messageNotifier('Please enter an email') : null,
        onSaved: (value) => _email == value,
      ),
    );
  }

  Widget passwordTextFormField() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: cPlanGoBlue, width: 1.0),
          ),
          labelText: 'Password',
          labelStyle: TextStyle(
            color: cPlanGoBlue
          ),
          prefixIcon: Icon(Icons.lock),
          suffixIcon: IconButton(
            tooltip: 'Show Password',
            color: cPlanGoBlue,
            splashColor: Colors.transparent,
            icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        validator: (value) =>
            value.isEmpty ? messageNotifier('Please enter a password') : null,
        onSaved: (value) => _password == value,
      ),
    );
  }

  List<Widget> submitWidgets() {
    return [emailTextFormField(), passwordTextFormField()];
  }

  Widget getButton() {
    return SizedBox(
      width: 250,
      child: RaisedButton(
          splashColor: cPlanGoMarineBlue,
          color: cPlanGoBlue,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(40.0),
          ),
          elevation: 5.0,
          onPressed: signIn,
          child: Text(
            'Sign in',
            style: TextStyle(color: cPlanGoWhiteBlue),
          )),
    );
  }

  List<Widget> navigateWidgets() {
    return [
      Padding(
          padding: EdgeInsets.all(15.0),
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                      backgroundColor: cPlanGoMarineBlue),
                )
              : getButton()),
    ];
  }

  Widget positionCreateAndReset() {
    return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ResetPassword()));
              },
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(40.0),
              ),
              textColor: Theme.of(context).accentColor,
              child: new Text('Reset Password'),
            ),
            FlatButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateAccount()));
              },
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(40.0),
              ),
              textColor: Theme.of(context).accentColor,
              child: new Text('Create Account?'),
            ),
          ],
        ));
  }

  Widget signInSuccess() {
    return new Container(
      child: Text(
        _authHint,
        style: TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget createAppBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: cPlanGoMarineBlue,
      title: Text(
        'PlanGo',
        style: TextStyle(color: cPlanGoWhiteBlue),
      ),
    );
  }

  Widget getCard() {
    return new Center(
      child: new Card(
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(5.0),
        ),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Container(
                padding: new EdgeInsets.all(15.0),
                child: new Form(
                    key: _formKey,
                    child: new Column(
                        children: submitWidgets() + navigateWidgets())))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cPlanGoBlue,
      appBar: createAppBar(),
      body: new SingleChildScrollView(
        child: new Container(
          padding: const EdgeInsets.all(15.0),
          child: new Column(
            children: <Widget>[
              getCard(),
              positionCreateAndReset(),
              signInSuccess()
            ],
          ),
        ),
      ),
    );
  }
}
