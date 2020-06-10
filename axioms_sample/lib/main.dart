import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'package:axioms_sample/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nanoid/nanoid.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:crypto/crypto.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'auth.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Container(
      child: UriLinks(),
    ),
  )
);

class UriLinks extends StatefulWidget {
  UriState createState() => new UriState();
}

class UriState extends State<UriLinks> with SingleTickerProviderStateMixin {
  StreamSubscription _sub;
  String _latestLink = 'Unkown';
  Uri _latestUri;

  initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    _sub = getUriLinksStream().listen((Uri uri) {
      if (!mounted) return;
      setState(() {
        _latestUri = uri;
        _latestLink = uri?.toString() ?? 'Unkown';
      });
    }, onError: (err) {
      if (!mounted) return;
      setState(() {
        _latestUri = null;
        _latestLink = 'Failed to get latest link: $err';
      });
    });

    getUriLinksStream().listen((Uri uri) {
      print('Got Uri: ${uri?.path} ${uri?.queryParametersAll}');
    }, onError: (err) {
      print('Got Error: $err');
    });

    Uri initialUri;
    String initialLink;
    try {
      initialUri = await getInitialUri();
      print('initial uri: ${initialUri?.path}'
          ' ${initialUri?.queryParametersAll}');
      initialLink = initialUri?.toString();
    } on PlatformException {
      initialUri = null;
      initialLink = 'Failed to get initial uri.';
    } on FormatException {
      initialUri = null;
      initialLink = 'Bad parse the initial link as Uri.';
    }

    if (!mounted) return;

    setState(() {
      _latestUri = initialUri;
      _latestLink = initialLink;
    });

  }

  Auth test = new Auth(
    "sahil-deshmukh.us.uat.axioms.io", 
    "code", 
    "com.axioms.io://callback", 
    "dZg5t2xFcEg0J8tYc0jpFGZoDQC7yL8t", 
    "openid+profile"
  );

  authenticate() async {
    final callbackUrlScheme = 'com.axioms.io';
    String finalLink = test.getUrl();
    
    try {
      final result = await FlutterWebAuth.authenticate(url: finalLink, callbackUrlScheme: callbackUrlScheme);
      final Uri resultUri = Uri.parse(result);
      final queryParams = resultUri?.queryParametersAll?.entries?.toList();
      final queryList = {};

      if (queryParams != null) {
        final newList = Map?.fromIterable(queryParams, key: (v) => v.key, value: (v) => v.value[0]);
        queryList.addAll(newList);
      }

      Navigator.push(context, MaterialPageRoute(builder: (context) => RedirectPage(result)));
      print('Code: ${queryList['code']}');
    } on PlatformException catch (err) {
      print('============== Error: $err ==============');
    }

  }

  @override
  void initState() {
    initUniLinks();
    print(test.getUrl());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final queryParams = _latestUri?.queryParametersAll?.entries?.toList();

    final Map<String, String> queryList = {};

    if (queryParams != null) {
      final newList = Map?.fromIterable(queryParams, key: (v) => v.key, value: (v) => v.value[0]);
      queryList.addAll(newList);
    }

    print(queryList);

    return HomePage(queryList, test.getUrl(), authenticate);
  }

  @override
  dispose() {
    if (_sub != null) {
      print("Canceling Sub");
      _sub.cancel();
    }
    super.dispose();
  }

}

class RedirectPage extends StatelessWidget {

  final String results;

  RedirectPage(this.results);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(1, 46, 102, 100),
      body: Container(
        child: Column (
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: 'REDIRECTED!',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      fontSize: 50,
                      fontWeight: FontWeight.bold
                    )
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
  
}

class HomePage extends StatelessWidget {
  final queryList;
  final authLink;
  final Function authenticate;

  HomePage(this.queryList, this.authLink, this.authenticate);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(1, 46, 102, 100),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: 'axioms',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      fontSize: 70,
                      fontWeight: FontWeight.bold
                    )
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: authenticate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.white)
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(7, 3, 7, 3),
                    child: Text(
                      'login',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}