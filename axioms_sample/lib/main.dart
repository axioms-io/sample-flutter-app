import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:nanoid/nanoid.dart';
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

  fetchAuth() async {
    HttpClient client = new HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    String url = 'https://sahil-deshmukh.us.uat.axioms.io/user/login';
    HttpClientRequest request = await client.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();
    // String reply = await response.transform(convert.utf8.decoder).join();
    print(response.statusCode);
    // var response = await http.get(url);
    // if (response.statusCode == 200) {
    //   var jsonResponse = convert.jsonDecode(response.body);
    //   print(jsonResponse);
    // } else {
    //   print('Request Failed with status: ${response.statusCode}');
    // }
  }

  final Completer<WebViewController> _controller = Completer<WebViewController>();
  static String host = 'https://sahil-deshmukh.us.uat.axioms.io/oauth2/authorize?';
  static String response_type = 'code';
  static String client_id = 'dZg5t2xFcEg0J8tYc0jpFGZoDQC7yL8t';
  static String redirect_uri = 'com.axioms.io://callback';
  static String scope = 'openid+profile';
  static String state = nanoid();
  static String nonce = nanoid();

  String finalLink = '${host}response_type=${response_type}&client_id=${client_id}&redirect_uri=${redirect_uri}&scope=${scope}&state=${state}&nonce=${nonce}';

  @override
  void initState() {
    initUniLinks();
    // fetchAuth();
    print(finalLink);
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

    return HomePage(queryList, finalLink);
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
  final authLink;

  WebBrowser(this.authLink);

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
        initialUrl: authLink,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final queryList;
  final authLink;

  HomePage(this.queryList, this.authLink);

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
                      MaterialPageRoute(builder: (context) => WebBrowser(authLink))
                    );
                  },
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