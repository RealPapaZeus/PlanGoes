import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plan_go_software_project/Verification/LogIn.dart';

import '../colors.dart';

class ResetPassword extends StatefulWidget {
  ResetPassword({
    Key key,
  }) : super(key: key);

  @override
  _ResetPasswordState createState() => new _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  String _email;
  bool _isLoading = false;
  String _authHint = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  //method is important because otherwise, calling "sendPasswordResetEmail"
  //throws an error, because of TypeException. It says it should consist of
  //void. Therefore you have to call "resetPassword" inside "sendPasswordReset"
  Future resetPassword(String email) async {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  void sendPasswordReset() async {
    final _formState = _formKey.currentState;

    setState(() {
      _isLoading = true;
    });

    if (_formState.validate()) {
      _formState.save();

      try {
        await resetPassword(_emailController.text.toString().trim());

        showAlterDialogVerification(context, _emailController.text);

        setState(() {
          _isLoading = false;
          _authHint = '';
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _authHint = 'unknown Email';
        });

        print(e.message);
      }
    }
  }

  Future<void> showAlterDialogVerification(
      BuildContext context, String _email) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: cPlanGoWhiteBlue,
            title: Text(
              'Email Reset',
              style: TextStyle(color: cPlanGoMarineBlue),
            ),
            content: RichText(
              text: new TextSpan(
                  style: new TextStyle(
                    fontSize: 14.0,
                    color: cPlanGoMarineBlue,
                  ),
                  children: <TextSpan>[
                    new TextSpan(text: 'We just sent you a link to '),
                    new TextSpan(
                        text: '$_email',
                        style: new TextStyle(fontWeight: FontWeight.bold)),
                    new TextSpan(
                        text:
                            ' to reset your password. Please click the link in that email to continue.')
                  ]),
            ),
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
                child: Text('Okay', style: TextStyle(color: cPlanGoBlue)),
              )
            ],
          );
        });
  }

  Widget answerResetPassword() {
    return new Container(
      child: Text(
        _authHint,
        style: TextStyle(color: cPlanGoRedBright),
        textAlign: TextAlign.center,
      ),
    );
  }

  String messageNotifier(String message) {
    _isLoading = false;
    return '$message';
  }

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
            labelStyle: TextStyle(color: cPlanGoBlue),
          ),
          obscureText: false,
          validator: (value) =>
              value.isEmpty ? messageNotifier('Please enter an email') : null,
          onSaved: (value) => _email == value,
        ));
  }

  //has to be inside a List because otherwise we can not
  //call this method inside our build(). The reason is inside our
  //build() it is looking for a List of Widgets.
  List<Widget> submitWidgets() {
    return [emailTextFormField()];
  }

  Widget getResetButton() {
    return SizedBox(
        width: 250,
        child: RaisedButton(
          splashColor: cPlanGoMarineBlue,
          color: cPlanGoBlue,
          child: Text(
            'Reset',
            style: TextStyle(color: cPlanGoWhiteBlue),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(40.0),
          ),
          elevation: 5.0,
          onPressed: sendPasswordReset,
        ));
  }

  Widget loadingButton() {
    return CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(cPlanGoMarineBlue),
    );
  }

  List<Widget> userResetPassword() {
    return [
      Padding(
          padding: EdgeInsets.all(15.0),
          child: _isLoading ? loadingButton() : getResetButton()),
    ];
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
                          children: submitWidgets() + userResetPassword())))
            ],
          ),
        ));
  }

  Widget showReset() {
    return Stack(children: <Widget>[
      Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 3.3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cPlangGoDarkBlue, cPlanGoMarineBlueDark],
            ),
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(90)),
          ),
        ),
      ),
      Positioned(top: 137, right: 10, left: 10, child: getAccountView())
    ]);
  }

  Widget getAppBar() {
    return AppBar(
      elevation: 0.0,
      backgroundColor: cPlangGoDarkBlue,
      centerTitle: true,
      title: Text('Reset Password'.toLowerCase(),
          style: TextStyle(color: cPlanGoWhiteBlue)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cPlanGoBlue,
      appBar: getAppBar(),
      body: showReset(),
    );
  }
}
