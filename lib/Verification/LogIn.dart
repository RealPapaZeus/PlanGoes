import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:PlanGoes/Verification/CreateAccount.dart';
import 'package:PlanGoes/EventView/EventList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:PlanGoes/Verification/ResetPassword.dart';
import 'package:PlanGoes/colors.dart';

class LogIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: cPlanGoBlue,
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
  String _datetime = '';
  String _description = '';
  int _eventColor;
  String _eventName;
  String _imageUrl = '';
  String _location = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _montserratMedium = 'MontserratMedium';
  String _montserratRegular = 'MontserratRegular';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    this.initDynamicLinks();
  }

  String _eventID;

  // Method checks if the App was opened by a Dynamic Link
  void initDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      print('DL =! null');
      final queryParams = deepLink.queryParameters;
      if (queryParams.length > 0) {
        String eventId = queryParams['eventID'];
        print('The user must be inserted in the event: $eventId');
        setState(() {
          _eventID = eventId;
        });
        getEventInfo(_eventID);
        print('InitDL Print: $_eventName');
      }
      Navigator.pushNamed(context, deepLink.path);
    } else {
      print('DL = null');
    }

    // This will handle incoming links if the application is already opened
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamikLink) async {
      final Uri deepLink = dynamikLink?.link;

      if (deepLink != null) {
        print('DL != null');
        final queryParams = deepLink.queryParameters;
        if (queryParams.length > 0) {
          String eventId = queryParams['eventID'];
          print('The user must be inserted in the event: $eventId');
          setState(() {
            _eventID = eventId;
          });
          getEventInfo(_eventID);
          print('InitDL Print: $_eventName');
        }
        Navigator.pushNamed(context, deepLink.path);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  // insert Reference of Event into UsersEventList
  void insertEvent(String eventID, String userId) async {
    final databaseReference = Firestore.instance;

    await databaseReference
        .collection("users")
        .document("$userId")
        .collection("usersEventList")
        .document("$eventID")
        .setData({
      'admin': false,
      'eventname': '$_eventName',
      'location': '$_location',
      'datetime': '$_datetime',
      'description': '$_description',
      'eventColor': _eventColor.toInt(),
      'imageUrl': '$_imageUrl'
    });

  }

  // get EventInfo of the Event the user was invited
  void getEventInfo(String eventID) async {
    final databaseReference = Firestore.instance;
    var documentReference =
        databaseReference.collection("events").document('$eventID');
    print('Print in getEventInfo $eventID');
    documentReference.get().then((DocumentSnapshot document) {
      setState(() {
        _datetime = document['datetime'];
        _description = document['description'];
        _eventColor = document['eventColor'];
        _eventName = document['eventName'];
        _imageUrl = document['imageUrl'];
        _location = document['location'];
      });
    });
    print('method was called');
  }

  // same procedure as in other classes, to insert values into
  //database under given path
  void addUserToUserslistInDatabase(String eventId,String userId) async {
    final databaseReference = Firestore.instance;

    await databaseReference
        .collection("events")
        .document('$eventId')
        .collection("usersList")
        .add({'name': '$userId'});
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
          if (_eventID != null) {
            insertEvent(_eventID, user.user.uid);
            addUserToUserslistInDatabase(_eventID ,user.user.uid);
          }
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
    return new Container(
      width: MediaQuery.of(context).size.width / 1.0,
      height: MediaQuery.of(context).size.height / 10.0,
      padding: const EdgeInsets.all(6.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        cursorColor: cPlanGoBlue,
        style:
            TextStyle(color: cPlanGoDark, fontFamily: _montserratMedium),
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
                TextStyle(color: cPlanGoBlue, fontFamily: _montserratMedium)),
        obscureText: false,
        validator: (value) =>
            value.isEmpty ? messageNotifier('Please enter an email') : null,
        onSaved: (value) => _email == value,
      ),
    );
  }

  Widget passwordTextFormField() {
    return new Container(
      width: MediaQuery.of(context).size.width / 1.0,
      height: MediaQuery.of(context).size.height / 10.0,
      padding: const EdgeInsets.all(6.0),
      child: TextFormField(
        keyboardType: TextInputType.visiblePassword,
        cursorColor: cPlanGoBlue,
        controller: _passwordController,
        obscureText: _obscurePassword,
        style:
            TextStyle(color: cPlanGoDark, fontFamily: _montserratMedium),
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
          labelStyle:
              TextStyle(color: cPlanGoBlue, fontFamily: _montserratMedium),
          errorStyle:
              TextStyle(color: cPlanGoRedBright, fontFamily: _montserratMedium),
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
      ),
    );
  }

  List<Widget> submitWidgets() {
    return [emailTextFormField(), passwordTextFormField()];
  }

  Widget showLabel() {
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
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(90))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Spacer(),
          Align(
              alignment: Alignment.center,
              child: Container(
                  width: MediaQuery.of(context).size.width / 2.5,
                  height: MediaQuery.of(context).size.height / 5.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new AssetImage(
                              'images/PlanGo_Transparent.png'))))),
          Container(
            width: MediaQuery.of(context).size.width / 1.0,
            height: MediaQuery.of(context).size.height / 10.0,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30, right: 30),
                child: Text(
                  'LOGIN'.toLowerCase(),
                  style: TextStyle(
                      color: cPlanGoWhiteBlue,
                      fontSize: 18,
                      fontFamily: _montserratRegular),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.55,
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
            style: TextStyle(
                color: cPlanGoWhiteBlue, fontFamily: _montserratMedium),
          )),
    );
  }

  Widget loadingButton() {
    return CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(cPlanGoBlue));
  }

  List<Widget> navigateWidgets() {
    return [
      Padding(
          padding: const EdgeInsets.all(15.0),
          child: _isLoading ? loadingButton() : getButton()),
    ];
  }

  Widget positionCreateAndReset() {
    return Container(
        width: MediaQuery.of(context).size.width / 1.0,
        height: MediaQuery.of(context).size.height / 15.0,
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
              child: new Text(
                'Register',
                style: TextStyle(fontFamily: _montserratMedium),
              ),
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
              child: new Text('Forgot Password?',
                  style: TextStyle(fontFamily: _montserratMedium)),
            ),
          ],
        ));
  }

  Widget signInSuccess() {
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

  Widget getCard() {
    return Container(
        width: MediaQuery.of(context).size.width / 1.0,
        height: MediaQuery.of(context).size.height / 2.33,
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
