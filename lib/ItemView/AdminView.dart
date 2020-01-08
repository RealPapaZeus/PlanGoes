import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:plan_go_software_project/ItemView/ItemCreateDialog.dart';
import 'package:plan_go_software_project/ItemView/ItemList.dart';
import 'package:plan_go_software_project/colors.dart';
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
  double offset = 0.0;
  // Uri _dynamicLinkUrl;
  var _link;

  @override
  void initState() {
    super.initState();
    getEventInfo();
    getLink();
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
        uriPrefix: 'https://plango.page.link',
        link: Uri.parse(
            'https://plango.page.link/invite?eventID=$_eventID'),
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

  Widget createAppBar(bool value) {
    return new SliverAppBar(
      snap: true,
      pinned: true,
      floating: true,
      forceElevated: value,
      expandedHeight: 200.0,
      backgroundColor: Color(_eventColor),
      flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Text(
            _eventName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: 'MontserratRegular'),
          ),
          background: (_imageUrl != 'null')
              ? Image.network(_imageUrl, fit: BoxFit.cover)
              : Image.asset('images/calender_black_white.png',
                  fit: BoxFit.cover)),
    );
  }

  Widget createItem() {
    return new FloatingActionButton(
      elevation: 5.0,
      child: Icon(Icons.add, color: cPlanGoWhiteBlue),
      backgroundColor: cPlangGoDarkBlue,
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
      color: cPlangGoDarkBlue,
      notchMargin: 4.0,
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.share, color: cPlanGoWhiteBlue),
              onPressed: () async {
                showDialog(
                    context: context,
                    child: new AlertDialog(
                        title: new Text(
                          "Sharing is caring",
                        ),
                        content: new SelectableText(
                          _link.toString(),
                          style: TextStyle(color: cPlanGoBlue, decoration: TextDecoration.underline),
                        )));
              })
        ],
      ),
    );
  }

  Widget getScrollView() {
    return new NestedScrollView(
      headerSliverBuilder: (context, innerBoxScrolled) {
        return <Widget>[createAppBar(innerBoxScrolled)];
      },
      body: buildStream(),
    );
  }

  Widget buildAppBar() {
    return AppBar(
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
                        fit: BoxFit.contain,
                        // height: 32,
                      )
                    : Image.asset('images/calendar.png',
                        fit: BoxFit.contain, height: 32),
              ),
            ),
          ),
          Container(
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
      elevation: 5.0,
      backgroundColor: Color(_eventColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: Color(_eventColor),
      extendBody: true,
      body: buildStream(),
      floatingActionButton: createItem(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: bottomNavigation(),
    );
  }
}
