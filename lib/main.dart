import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:face_id_plus/intro.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import "package:flutter/services.dart";
import 'dart:io' show Platform;
import 'package:camera/camera.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

List<CameraDescription> cameras = [];
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  firebaseInit();
  cameras = await availableCameras();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

firebaseInit() async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
      appId: '1:448618578101:ios:2bc5c1fe2ec336f8ac3efc',
      messagingSenderId: '448618578101',
      projectId: 'react-native-firebase-testing',
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: _mainPage());
  }

  _mainPage() {
    if (Platform.isAndroid) {
          return const SliderIntro();
    } else if (Platform.isIOS) {
      return AnimatedSplashScreen(
          splash: Image.asset('assets/images/ic_abp.png'),
          duration: 1500,
          splashTransition: SplashTransition.scaleTransition,
          nextScreen: const SliderIntro());
    }
    
  }
}
