import 'package:flutter/material.dart';
import 'package:PlanGoes/Verification/LogIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:PlanGoes/colors.dart';

class CreateAccount extends StatefulWidget {
  CreateAccount({
    Key key,
  }) : super(key: key);

  @override
  _CreateAccountState createState() => new _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
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

  String _montserratLight = 'MontserratLight';
  String _montserratMedium = 'MontserratMedium';
  String _montserratRegular = 'MontserratRegular';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void createUserInCollection(
      String userID, String email, String username) async {
    final databaseReference = Firestore.instance;

    await databaseReference
        .collection("users")
        .document('$userID')
        .setData({'email': '$email', 'username': '$username'});
  }

  void createNewAccount() async {
    final _formState = _formKey.currentState;

    setState(() {
      _isLoading = true;
    });

    if (_formState.validate()) {
      _formState.save();

      try {
        AuthResult user = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text.toString().trim(),
                password: _passwordController.text);

        createUserInCollection(
            user.user.uid, _emailController.text, _usernameController.text);

        user.user.sendEmailVerification();

        showAlterDialogVerification(context, _emailController.text);

        setState(() {
          _isLoading = false;
          _authHint = '';
        });
      } catch (e) {
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
  Future<void> showAlterDialogVerification(
      BuildContext context, String _email) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: cPlanGoWhiteBlue,
            title: Text(
              'Verify Your Email Address',
              style: TextStyle(
                  color: cPlanGoMarineBlue, fontFamily: _montserratMedium),
            ),
            content: RichText(
                text: new TextSpan(
                    style: new TextStyle(
                        fontSize: 14.0,
                        color: cPlanGoMarineBlue,
                        fontFamily: _montserratMedium),
                    children: <TextSpan>[
                  new TextSpan(
                      text:
                          'We like you to verify your email address. We have sent an email to ',
                      style: TextStyle(fontFamily: _montserratMedium)),
                  new TextSpan(
                      text: '$_email'.trim(),
                      style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: _montserratMedium)),
                  new TextSpan(
                      text:
                          ' to verify your address. Please click the link in that email to continue.',
                      style: TextStyle(fontFamily: _montserratMedium)),
                  new TextSpan(
                      text:
                          '\nWait some seconds and please check your spam if you have not received an email.',
                      style: TextStyle(fontFamily: _montserratMedium)),
                  new TextSpan(
                      text: '\nWe are glad to welcome you!',
                      style: TextStyle(fontFamily: _montserratMedium)),
                  new TextSpan(
                      text: '\n\nYour PlanGo team',
                      style: TextStyle(fontFamily: _montserratMedium))
                ])),
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(15)),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LogIn()));
                },
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(40.0),
                ),
                textColor: cPlanGoWhiteBlue,
                child: Text(
                  'Okay, lets go',
                  style: TextStyle(
                      color: cPlanGoMarineBlue, fontFamily: _montserratMedium),
                ),
              )
            ],
          );
        });
  }

  //it gives the user a notification if
  //a mistake appeared. For instance if an email
  //is already in use by another user
  Widget registrationSucessMessage() {
    return new Container(
      width: MediaQuery.of(context).size.width / 1.0,
      height: MediaQuery.of(context).size.height / 10.0,
      child: Text(
        _authHint,
        style:
            TextStyle(color: cPlanGoRedBright, fontFamily: _montserratMedium),
        textAlign: TextAlign.center,
      ),
    );
  }

  //Widgets do only return a TextFormField
  //whenever a new TextFormField gets created
  Widget emailTextFormField() {
    return Container(
        width: MediaQuery.of(context).size.width / 1.0,
        //height: MediaQuery.of(context).size.height / 8.0,
        padding: const EdgeInsets.all(6.0),
        child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          cursorColor: cPlanGoBlue,
          style: TextStyle(
              color: cPlanGoDark, fontFamily: _montserratMedium),
          controller: _emailController,
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: const BorderSide(color: cPlanGoBlue, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              borderSide: const BorderSide(color: cPlanGoBlue, width: 1.0),
            ),
            errorStyle: TextStyle(
                color: cPlanGoRedBright, fontFamily: _montserratMedium),
            prefixIcon: Padding(
              padding: EdgeInsets.all(0.0),
              child: Icon(
                Icons.email,
                color: cPlanGoBlue,
              ),
            ),
            labelText: 'email',
            labelStyle:
                TextStyle(color: cPlanGoBlue, fontFamily: _montserratMedium),
          ),
          obscureText: false,
          validator: (value) =>
              value.isEmpty ? messageNotifier('Please enter an email') : null,
          onSaved: (value) => _email == value,
        ));
  }

  Widget passwordTextFormField() {
    return Container(
        width: MediaQuery.of(context).size.width / 1.0,
        padding: const EdgeInsets.all(6.0),
        child: Theme(
            data: Theme.of(context).copyWith(primaryColor: cPlanGoBlue),
            child: TextFormField(
              keyboardType: TextInputType.visiblePassword,
              cursorColor: cPlanGoBlue,
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: TextStyle(
                  color: cPlanGoDark, fontFamily: _montserratMedium),
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
                labelStyle: TextStyle(
                    color: cPlanGoBlue, fontFamily: _montserratMedium),
                errorStyle: TextStyle(
                    color: cPlanGoRedBright, fontFamily: _montserratMedium),
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
                  icon: Icon(_obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value.isEmpty)
                  return messageNotifier('Please enter a password');
                else {
                  if (value.toString().length <= 7)
                    return messageNotifier('Password has to be 8 digits long');
                  else
                    return null;
                }
              },
              onSaved: (value) => _password == value,
            )));
  }

  Widget userNameField() {
    return Container(
        width: MediaQuery.of(context).size.width / 1.0,
        padding: const EdgeInsets.all(6.0),
        child: TextFormField(
          keyboardType: TextInputType.text,
          cursorColor: cPlanGoBlue,
          maxLength: 20,
          style: TextStyle(
              color: cPlanGoDark, fontFamily: _montserratMedium),
          controller: _usernameController,
          decoration: InputDecoration(
              counterStyle:
                  TextStyle(color: cPlanGoDark, fontFamily: _montserratMedium),
              enabledBorder: UnderlineInputBorder(
                borderSide: const BorderSide(color: cPlanGoBlue, width: 1.5),
              ),
              errorStyle: TextStyle(
                  color: cPlanGoRedBright, fontFamily: _montserratMedium),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                borderSide: const BorderSide(color: cPlanGoBlue, width: 1.0),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(0.0),
                child: Icon(
                  Icons.supervised_user_circle,
                  color: cPlanGoBlue,
                ),
              ),
              labelStyle:
                  TextStyle(color: cPlanGoBlue, fontFamily: _montserratMedium),
              labelText: 'username'),
          obscureText: false,
          validator: (value) => value.isEmpty
              ? messageNotifier('Please enter an username')
              : null,
          onSaved: (value) => _username == value,
        ));
  }

  Widget getRegistrationButton() {
    return SizedBox(
        width: MediaQuery.of(context).size.width / 1.55,
        child: RaisedButton(
          splashColor: cPlanGoMarineBlue,
          color: cPlanGoBlue,
          child: Text(
            'Sign Up',
            style: TextStyle(
                color: cPlanGoWhiteBlue, fontFamily: _montserratMedium),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20.0),
          ),
          elevation: 5.0,
          onPressed: createNewAccount,
        ));
  }

  Widget loadingButton() {
    return CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(cPlanGoMarineBlue),
    );
  }

  //calls the method which builds TextFormField with given parameters
  //it helps to read the code more efficient
  List<Widget> submitWidgets() {
    return [emailTextFormField(), passwordTextFormField(), userNameField()];
  }

  List<Widget> userViewConfirmNewAccount() {
    return [
      Padding(
          padding: const EdgeInsets.all(15.0),
          child: _isLoading ? loadingButton() : getRegistrationButton())
    ];
  }

  Widget getAppBar() {
    return AppBar(
      elevation: 0.0,
      backgroundColor: cPlangGoDarkBlue,
      centerTitle: true,
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.arrow_forward, color: cPlanGoWhiteBlue),
          onPressed: () => Navigator.of(context).pop(),
          splashColor: cPlanGoBlue,
          highlightColor: Colors.transparent,
        ),
      ],
      automaticallyImplyLeading: false,
      title: Text('Registration'.toLowerCase(),
          style: TextStyle(
              color: cPlanGoWhiteBlue, fontFamily: _montserratRegular)),
    );
  }

  Widget getAccountView() {
    return new Padding(
        padding: const EdgeInsets.all(15.0),
        child: Card(
          color: cPlanGoWhiteBlue,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(25.0),
          ),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Container(
                  padding: new EdgeInsets.all(15.0),
                  child: new Form(
                      key: _formKey,
                      child: new Column(
                          children:
                              submitWidgets() + userViewConfirmNewAccount())))
            ],
          ),
        ));
  }

  Widget buildBackground() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3,
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
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(90)),
      ),
    );
  }

  Widget showRegistration() {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        child: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    buildBackground(),
                    Center(
                      widthFactor: MediaQuery.of(context).size.width / 1,
                      heightFactor: MediaQuery.of(context).size.height / 585,
                      child: 
                    Container(
                      padding:
                          const EdgeInsets.fromLTRB(15.0, 50.0, 15.0, 15.0),
                      child: Column(
                        children: <Widget>[new Center(child: getAccountView())],
                      ),
                    ))
                  ],
                )
              ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: cPlanGoBlue,
        appBar: getAppBar(),
        body: showRegistration());
  }
}
