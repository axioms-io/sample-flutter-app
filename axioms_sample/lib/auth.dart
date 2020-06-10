import 'dart:async';
import 'dart:convert' as convert;
import 'package:nanoid/nanoid.dart';
import 'package:http/http.dart';
class Auth {
  String axioms_domain;
  String response_type;
  String redirect_uri;
  String post_logout_uri;
  String client_id;
  String login_scope;            
  String login_type;  
  String post_login_navigate;
  String nonce;
  String state;
  String challenge;
  String challenge_verifier;
  String url;
  String authPath = '/oauth2/authorize';

  Auth(String axioms_domain, String response_type, String redirect_uri, String client_id, String login_scope) {
    this.axioms_domain = axioms_domain;
    this.response_type = response_type;
    this.redirect_uri = redirect_uri;
    this.client_id = client_id;
    this.login_scope = login_scope;
    this.nonce = nanoid();
    this.state = nanoid();
    buildUrl();
  }

  String getState() {
    return this.state;
  }

  void buildUrl() {
    var queryParams = {
      "response_type": this.response_type,
      "client_id": this.client_id,
      "redirect_uri": this.redirect_uri,
      "scope": this.login_scope,
      "state": this.state,
      "nonce": this.nonce
    };
    // Uri link = new Uri.https(this.axioms_domain, this.authPath, queryParams);
    // this.url = link.toString();
    String link = "https://" + this.axioms_domain + authPath;
    for (int i = 0; i < queryParams.keys.length; i++) {
      String key = queryParams.keys.toList()[i];
      String current;
      if (i == 0) {
        current = "?" + key + "=" + queryParams[key];
      } else {
        current = "&" + key + "=" + queryParams[key];
      }
      link += current;
    }
    this.url = link;
  }

  String getUrl() {
    return this.url;
  }
}
