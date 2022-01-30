import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkCheck {
  late StreamSubscription<InternetConnectionStatus> listener;
  var InternetStatus = "Unknown";
  var contentmessage = "Unknown";
  late InternetConnectionStatus net;

  void _showDialog(String title, String content, BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(title),
              content: Text(content),);
        });
  }

  checkConnection(BuildContext context) async {
    listener = InternetConnectionChecker().onStatusChange.listen(
      (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.connected:
            // ignore: avoid_print

            InternetStatus = "Connected to the Internet";
            contentmessage = "Connected to the Internet";
            print('Data connection is available.');
            Navigator.maybePop(context);
            // _showDialog(InternetStatus, contentmessage, context);
            net = status;
            break;
          case InternetConnectionStatus.disconnected:
            // ignore: avoid_print
            print('You are disconnected from the internet.');
            InternetStatus = "You are disconnected to the Internet. ";
            contentmessage = "Please check your internet connection";
            net = status;
            Navigator.maybePop(context);
            _showDialog(InternetStatus, contentmessage, context);

            break;
        }
      },
    );
    return await InternetConnectionChecker().connectionStatus;
  }
}
