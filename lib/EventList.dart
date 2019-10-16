import 'package:flutter/material.dart';

class EventList extends StatefulWidget {

  EventList({Key key,}) : super(key: key);

  @override
  _EventListState createState() => new _EventListState();
}
  
class _EventListState extends State<EventList>{

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
        title: Text('Events'),
      ),
      body: new Center(
        child: new ListTile(
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text('Größter Kai Fan'),
              ),
              new Container(
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(10.0)
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text('900')
              )
            ],
          )
        ),
      )
    );
  }
}