import 'package:flutter/material.dart';

class LogIn extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyLogInPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyLogInPage extends StatefulWidget {
  MyLogInPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyLogInPageState createState() => _MyLogInPageState();
}

class _MyLogInPageState extends State<MyLogInPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('LogIn'),
      ),
      body: new Center(
        child: new FlatButton(
          onPressed: (){},
          textColor: Theme.of(context).accentColor,
          child: new Text('Create Account?'),
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      )
    );
  }
}