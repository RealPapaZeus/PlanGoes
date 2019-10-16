import 'package:flutter/material.dart';

class UserName extends StatefulWidget {

  UserName({Key key,}) : super(key: key);

  @override
  _UserNameState createState() => new _UserNameState();
}
  
class _UserNameState extends State<UserName>{

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
        title: Text('Initialise new UserName'),
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