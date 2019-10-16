import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {

  CreateAccount({Key key,}) : super(key: key);

  @override
  _CreateAccountState createState() => new _CreateAccountState();
}
  
class _CreateAccountState extends State<CreateAccount>{

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('CreateAccount'),
      ),
      body: new Center(
        child: new FlatButton(
          onPressed: (){},
          textColor: Theme.of(context).accentColor,
          child: new Text('Apply'),
        )
      ),
    );
  }
}