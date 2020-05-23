import 'dart:async';
// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

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

class UriState extends State with SingleTickerProviderStateMixin {
  StreamSubscription _sub;

  Future<Null> initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      String initialLink = await getInitialLink();
      print("Some link");
    } on PlatformException {
      print("Not Successful");
    }

    _sub = getLinksStream().listen((String link) {
      print("Recieved Link");
    }, onError: (err) {
      print("Error");
    });
  }

  @override
  void initState() {
    initUniLinks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HomePage();
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

class WebBrowser extends StatelessWidget {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'Go Back!',
            style: TextStyle (
              color: Colors.white,
              fontFamily: 'Nunito',
              fontSize: 20,
              fontWeight: FontWeight.bold
            )
          ),          
        ),
      ),
      body: WebView(
        initialUrl: 'https://developer.axioms.io/',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {

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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WebBrowser())
                    );
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.white)
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(7, 3, 7, 3),
                    child: Text(
                      'Login',
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