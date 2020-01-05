import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLink extends StatefulWidget {
  DynamicLink({
    Key key,
  }) : super(key: key);

  @override
  _DynamicLinkState createState() => new _DynamicLinkState();
}

class _DynamicLinkState extends State<DynamicLink> {
  Uri dynamicLinkUrl;

  Future<void> _createDynamikLink(bool short) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://plangosoftwareproject.page.link/',
        link: Uri.parse('https://plangosoftwareproject.page.link/invite'),
        androidParameters:
            AndroidParameters(packageName: 'plan.go', minimumVersion: 0));
    final Uri url = await parameters.buildUrl();
    setState(() {
      dynamicLinkUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return null;
  }
}
