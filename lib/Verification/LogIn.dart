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
        keyboardType: TextInputType.emailAddress,
        cursorColor: cPlanGoBlue,
        style: TextStyle(color: cPlanGoMarineBlue),
        controller: _emailController,
        decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: const BorderSide(color: cPlanGoBlue, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              borderSide: const BorderSide(color: cPlanGoBlue, width: 1.0),
            ),
            errorStyle: TextStyle(color: cPlanGoRedBright),
            prefixIcon: Padding(
              padding: EdgeInsets.all(0.0),
              child: Icon(
                Icons.email,
                color: cPlanGoBlue,
              ),
            ),
            labelText: 'email',
            labelStyle: TextStyle(color: cPlanGoBlue)),
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
        keyboardType: TextInputType.visiblePassword,
        cursorColor: cPlanGoBlue,
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: TextStyle(color: cPlanGoMarineBlue),
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: cPlanGoBlue, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            borderSide: const BorderSide(color: cPlanGoBlue, width: 1.0),
          ),
          fillColor: cPlanGoBlue,
          labelText: 'password',
          labelStyle: TextStyle(color: cPlanGoBlue),
          errorStyle: TextStyle(color: cPlanGoRedBright),
          prefixIcon: Padding(
            padding: EdgeInsets.all(0.0),
            child: Icon(
              Icons.lock,
              color: cPlanGoBlue,
            ),
          ),
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

  Widget showLabel() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3.1,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: cPlanGoMarineBlueDark,
              blurRadius: 8, // has the effect of softening the shadow
              spreadRadius: 0.3,
            )
          ],
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [cPlangGoDarkBlue, cPlanGoMarineBlueDark],
          ),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(90))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Spacer(),
          Align(
              alignment: Alignment.center,
              child: Container(
                  height: 150.0,
                  width: 150.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new AssetImage(
                              'images/PlanGo_Transparent.png'))))),
          Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30, right: 30),
              child: Text(
                'Login'.toLowerCase(),
                style: TextStyle(color: cPlanGoWhiteBlue, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
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
            'Plan and Go',
            style: TextStyle(color: cPlanGoWhiteBlue),
          )),
    );
  }

  Widget loadingButton() {
    return CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(cPlanGoMarineBlue),
    );
  }

  List<Widget> navigateWidgets() {
    return [
      Padding(
          padding: const EdgeInsets.all(15.0),
          child: _isLoading ? loadingButton() : getButton()),
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
                    MaterialPageRoute(builder: (context) => CreateAccount()));
              },
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(40.0),
              ),
              textColor: cPlanGoWhiteBlue,
              child: new Text('Register'),
            ),
            FlatButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ResetPassword()));
              },
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(40.0),
              ),
              textColor: cPlanGoWhiteBlue,
              child: new Text('Forgot Password?'),
            ),
          ],
        ));
  }

  Widget signInSuccess() {
    return new Container(
      child: Text(
        _authHint,
        style: TextStyle(color: cPlanGoRedBright),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget getCard() {
    return Padding(
        padding: const EdgeInsets.only(
          top: 40.0,
        ),
        child: new Card(
          color: cPlanGoWhiteBlue,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(25.0),
          ),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
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
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: cPlanGoBlue,
        body: new SingleChildScrollView(
          child: new Container(
            alignment: Alignment.center,
            child: new Center(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  showLabel(),
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        new Center(child: getCard()),
                        positionCreateAndReset(),
                        signInSuccess()
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
