import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:PlanGoes/ItemView/ItemCreateDialog.dart';
import 'package:PlanGoes/ItemView/ItemList.dart';
import 'package:PlanGoes/colors.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class AdminView extends StatefulWidget {
  final String documentId;
  final String userId;

  AdminView({
    Key key,
    this.documentId,
    this.userId,
  }) : super(key: key);

  @override
  _AdminViewState createState() => new _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  int _eventColor = 0;
  String _eventName = '';
  String _imageUrl = '';
  String _userName = '';
  double offset = 0.0;

  var _link;

  String _montserratMedium = 'MontserratMedium';

  @override
  void initState() {
    super.initState();
    getEventInfo();
    getLink();
    getUserName();
  }

  void getUserName() async {
    final databaseReference = Firestore.instance;
    var documentReference =
        databaseReference.collection("users").document(widget.userId);

    documentReference.get().then((DocumentSnapshot document) {
      setState(() {
        _userName = document['username'].toString();
      });
    });
    print(_userName);
  }

  // Method how to get one variable out of database, without using
  //StreamBuilder
  void getEventInfo() async {
    final databaseReference = Firestore.instance;
    var documentReference =
        databaseReference.collection("events").document(widget.documentId);

    documentReference.get().then((DocumentSnapshot document) {
      setState(() {
        _eventColor = document['eventColor'];
        _eventName = document['eventName'];
        _imageUrl = document['imageUrl'];
      });
    });
  }

  // Method creates Dynamic Link in Firebase
  Future<Uri> _createDynamikLink(String _eventID) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://plangoes.page.link',
        link: Uri.parse('https://plangoes.page.link/invite?eventID=$_eventID'),
        androidParameters: AndroidParameters(
            packageName: 'com.example.plan_go_software_project',
            minimumVersion: 0),
        iosParameters: IosParameters(
            bundleId: 'com.example.planGoSoftwareProject',
            minimumVersion: '0'));
    final link = await parameters.buildUrl();
    final ShortDynamicLink shortenedLink =
        await DynamicLinkParameters.shortenUrl(
      link,
      DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
    );
    return shortenedLink.shortUrl;
    // final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    // final Uri url = shortDynamicLink.shortUrl;
  }

  buildStream() {
    return ItemList(
      userId: widget.userId,
      documentId: widget.documentId,
      eventColor: _eventColor.toInt(),
    );
  }

  Widget createItem() {
    return new FloatingActionButton(
      elevation: 5.0,
      child: Icon(Icons.add, color: cPlanGoWhiteBlue),
      backgroundColor: Color(_eventColor),
      splashColor: cPlanGoMarineBlueDark,
      onPressed: () {
        showDialog(
            context: context,
            child: new ItemCreateView(
                documentID: widget.documentId,
                eventColor: _eventColor.toInt()));
      },
    );
  }

  void getLink() async {
    var link = await _createDynamikLink(widget.documentId);

    setState(() {
      _link = link.toString();
    });

    print(_link.toString());
  }

  Widget bottomNavigation() {
    return new BottomAppBar(
      elevation: 5.0,
      shape: CircularNotchedRectangle(),
      color: Color(_eventColor),
      notchMargin: 5.0,
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            splashColor: cPlanGoMarineBlueDark,
            highlightColor: Colors.transparent,
              icon: Icon(Icons.share, color: cPlanGoWhiteBlue),
              onPressed: () async {
                showDialog(
                    context: context,
                    child: new AlertDialog(
                        title: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              padding:
                                  const EdgeInsets.only(top: 8.0, right: 8.0),
                              child: Text(
                                'Sharing is caring',
                                overflow: TextOverflow.ellipsis,
                                style:
                                    TextStyle(fontFamily: 'MontserratRegular'),
                              ),
                            ),
                            CircleAvatar(
                              radius: 30,
                              foregroundColor: Color(_eventColor),
                              backgroundColor: Color(_eventColor),
                              child: ClipOval(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 1,
                                  height:
                                      MediaQuery.of(context).size.height / 1,
                                  child: (_imageUrl != 'null')
                                      ? Image.network(
                                          _imageUrl,
                                          fit: BoxFit.cover,
                                          height: 40,
                                        )
                                      : Image.asset('images/calendar.png',
                                          fit: BoxFit.contain, height: 40),
                                ),
                              ),
                            ),
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(15)),
                        content: new Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            RichText(
                                text: new TextSpan(
                                    style: new TextStyle(
                                        fontSize: 14.0,
                                        color: cPlanGoDark,
                                        fontFamily: _montserratMedium),
                                    children: <TextSpan>[
                                  new TextSpan(
                                      text: 'Hello $_userName, ',
                                      style: TextStyle(
                                          fontFamily: _montserratMedium)),
                                  new TextSpan(
                                      text:
                                          'if you like to share this event, please copy this link. \n',
                                      style: TextStyle(
                                          fontFamily: _montserratMedium)),
                                ])),
                            new SelectableText(
                              _link.toString(),
                              style: TextStyle(
                                  color: cPlanGoBlue,
                                  decoration: TextDecoration.underline,
                                  fontFamily: _montserratMedium),
                            )
                          ],
                        )));
              })
        ],
      ),
    );
  }

  Widget buildAppBar() {
    return AppBar(
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back, color: cPlanGoWhiteBlue),
        onPressed: () => Navigator.of(context).pop(),
        splashColor: cPlanGoBlue,
        highlightColor: Colors.transparent,
      ),
      title: new Row(
        children: <Widget>[
          CircleAvatar(
            radius: 20,
            foregroundColor: Color(_eventColor),
            backgroundColor: Color(_eventColor),
            child: ClipOval(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 1,
                height: MediaQuery.of(context).size.height / 1,
                child: (_imageUrl != 'null')
                    ? Image.network(
                        _imageUrl,
                        fit: BoxFit.cover,
                        height: 32,
                      )
                    : Image.asset('images/calendar.png',
                        fit: BoxFit.contain, height: 32),
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 1.5),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _eventName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'MontserratRegular'),
            ),
          )
        ],
      ),
      centerTitle: true,
      elevation: 8.0,
      backgroundColor: Color(_eventColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: cPlanGoWhiteBlue,
      extendBody: true,
      body: buildStream(),
      floatingActionButton: createItem(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: bottomNavigation(),
    );
  }
}
