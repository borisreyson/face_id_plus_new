import 'dart:io';
import 'dart:math';

import 'package:face_id_plus/screens/pages/cek_lokasi.dart';
import 'package:face_id_plus/screens/pages/home.dart';
import 'package:face_id_plus/screens/permission/lokasi.dart';
import 'package:face_id_plus/splash.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:shared_preferences/shared_preferences.dart';

class SliderIntro extends StatefulWidget {
  const SliderIntro({Key? key}) : super(key: key);

  @override
  _SliderIntroState createState() => _SliderIntroState();
}

class _SliderIntroState extends State<SliderIntro> {
  late Map<handler.Permission, handler.PermissionStatus> _statuses;
  List<Slide> slides = [];
  Function? gotoTab;
  bool doneVisible = false;
  Color textColor = const Color.fromRGBO(13, 13, 13, 1.0);
  int isLogin = 0;
  bool? intro = false;
  bool visbleIntro = false;
  bool enableGPS = false;
  final EdgeInsets margin =
      const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 70.0);
  @override
  void initState() {
    if (!visbleIntro) {
      checkIntro(context);
    }
    addSlide();
    super.initState();
  }

  addSlide() {
    slides.add(Slide(
        title: "Selamat Datang",
        styleTitle: const TextStyle(
            color: Colors.white,
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'RobotoMono'),
        description: "Aplikasi Ini Dibuat Untuk Absensi Karyawan",
        styleDescription: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontStyle: FontStyle.italic,
            fontFamily: 'Raleway'),
        marginDescription: margin,
        backgroundColor: const Color.fromRGBO(41, 52, 67, 1.0),
        directionColorBegin: Alignment.topLeft,
        directionColorEnd: Alignment.bottomRight,
        onCenterItemPress: () {},
        pathImage: "assets/images/abp_60x60.png"));
    slides.add(Slide(
      title: "Syarat Dan Ketentuan ",
      styleTitle: TextStyle(
          color: textColor,
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'RobotoMono'),
      description:
          "Aplikasi ini menggunakan pendeteksi wajah untuk mengetahui manusia atau tidak, "
          "hasil dari pengambilan gambar akan di simpan di server, tidak di bagikan ke siapapun"
          "Aplikasi ini juga membutuhkan lokasi terkini anda untuk mengetahui anda berada di lokasi yang di tentukan untuk menggunakan aplikasi ini ",
      styleDescription: TextStyle(
          color: textColor,
          fontSize: 20.0,
          fontStyle: FontStyle.italic,
          fontFamily: 'Raleway'),
      marginDescription: margin,
      centerWidget: Text("Penggunaan Koneksi Jaringan",
          style: TextStyle(color: textColor)),
      backgroundColor: const Color.fromRGBO(186, 183, 172, 1.0),
      directionColorBegin: Alignment.topLeft,
      directionColorEnd: Alignment.bottomRight,
      onCenterItemPress: () {},
    ));
    slides.add(Slide(
      title: "Syarat dan Ketentuan",
      styleTitle: const TextStyle(
          color: Color.fromRGBO(96, 55, 30, 1.0),
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'RobotoMono'),
      description:
          "Aplikasi ini mempunyai server sendiri, data - data dan privasi anda akan tetap terjaga aman " +
              "Foto dan lokasi anda tidak akan tersebar luas karna foto anda telah di enkripsi di dalam server",
      styleDescription: const TextStyle(
          color: Color.fromRGBO(96, 55, 30, 1.0),
          fontSize: 20.0,
          fontStyle: FontStyle.italic,
          fontFamily: 'Raleway'),
      marginDescription: margin,
      centerWidget: const Text("Penggunaan Kamera Dan Penyimpanan",
          style: TextStyle(color: Color.fromRGBO(96, 55, 30, 1.0))),
      backgroundColor: const Color.fromRGBO(252, 190, 64, 1.0),
      directionColorBegin: Alignment.topLeft,
      directionColorEnd: Alignment.bottomRight,
      onCenterItemPress: () {},
    ));
    slides.add(Slide(
      title: "Syarat dan Ketentuan",
      styleTitle: const TextStyle(
          color: Color.fromRGBO(242, 242, 240, 1.0),
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'RobotoMono'),
      description:
          "Lokasi anda tidak akan tersebar karena aplikasi ini tidak terhubung dengan pengguna lain, "
          "Lokasi hanya di gunakan pada saat aplikasi ini digunakan, dan lokasi anda hanya untuk mengetahui dimana ada melakukan pengambilan foto",
      styleDescription: const TextStyle(
          color: Color.fromRGBO(242, 242, 240, 1.0),
          fontSize: 20.0,
          fontStyle: FontStyle.italic,
          fontFamily: 'Raleway'),
      marginDescription: margin,
      centerWidget: const Text("Akses penuh jaringan dan ponsel",
          style: TextStyle(color: Color.fromRGBO(242, 242, 240, 1.0))),
      directionColorBegin: Alignment.topLeft,
      directionColorEnd: Alignment.bottomRight,
      backgroundColor: const Color.fromRGBO(101, 87, 53, 1.0),
      onCenterItemPress: () {},
    ));
    slides.add(Slide(
        title: "Syarat dan Ketentuan",
        styleTitle: const TextStyle(
            color: Color.fromRGBO(166, 52, 27, 1.0),
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'RobotoMono'),
        description:
            "Aplikasi ini hanya dapat di gunakan di area terbatas seperti gambar diatas",
        styleDescription: const TextStyle(
            color: Color.fromRGBO(166, 52, 27, 1.0),
            fontSize: 20.0,
            fontStyle: FontStyle.italic,
            fontFamily: 'Raleway'),
        marginDescription: margin,
        directionColorBegin: Alignment.topLeft,
        directionColorEnd: Alignment.bottomRight,
        backgroundColor: const Color.fromRGBO(234, 173, 57, 1.0),
        onCenterItemPress: () {},
        pathImage: "assets/images/abp_maps.png"));
    slides.add(Slide(
        title: "Permintaan Izin",
        styleTitle: const TextStyle(
            color: Color.fromRGBO(242, 242, 240, 1.0),
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'RobotoMono'),
        styleDescription: const TextStyle(
            color: Color.fromRGBO(242, 242, 240, 1.0),
            fontSize: 20.0,
            fontStyle: FontStyle.italic,
            fontFamily: 'Raleway'),
        marginDescription: margin,
        centerWidget: const Text(
          "Izin Penyimpanan, Izin Lokasi, Izin Ponsel, Izin Kamera , Izin Mikropon",
          style: TextStyle(color: Color.fromRGBO(242, 242, 240, 1.0)),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color.fromRGBO(191, 85, 23, 1.0),
        directionColorBegin: Alignment.topLeft,
        directionColorEnd: Alignment.bottomRight,
        onCenterItemPress: () {},
        widgetDescription: costomWidget()));
  }

  Widget costomWidget() {
    return Column(
      children: const <Widget>[
        Text(
          "Mohon Untuk Mengizinkan Penggunaan Internet ",
          style: TextStyle(
              color: Color.fromRGBO(242, 242, 240, 1.0),
              fontSize: 20.0,
              fontStyle: FontStyle.italic,
              fontFamily: 'Raleway'),
          textAlign: TextAlign.center,
        ),
        Text(
          "Penyimpanan Internal dan Penyimpanan External supaya aplikasi ini berjalan dengan baik",
          style: TextStyle(
              color: Color.fromRGBO(242, 242, 240, 1.0),
              fontSize: 20.0,
              fontStyle: FontStyle.italic,
              fontFamily: 'Raleway'),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  ButtonStyle myButtonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all<OutlinedBorder>(const StadiumBorder()),
      backgroundColor:
          MaterialStateProperty.all<Color>(const Color(0x33F3B4BA)),
      overlayColor: MaterialStateProperty.all<Color>(const Color(0x33FFA8B0)),
    );
  }

  ButtonStyle nextButtonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all<OutlinedBorder>(const StadiumBorder()),
      backgroundColor: MaterialStateProperty.all<Color>(
          const Color.fromRGBO(242, 242, 242, 1.0)),
      overlayColor: MaterialStateProperty.all<Color>(
          const Color.fromRGBO(199, 200, 196, 1.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visbleIntro,
      child: IntroSlider(
        slides: slides,
        doneButtonStyle: nextButtonStyle(),
        onDonePress: () {
          if(Platform.isAndroid){
          _requestLocation(context);
          }else if(Platform.isIOS){
          Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Lokasi()));
          }
        },
        showDoneBtn: true,
        showSkipBtn: false,
        renderNextBtn: nextButton(),
        nextButtonStyle: nextButtonStyle(),
        renderPrevBtn: prevButton(),
        prevButtonStyle: nextButtonStyle(),
        renderDoneBtn: doneButton(),
      ),
    );
  }

  Widget nextButton() {
    return const Icon(Icons.navigate_next,
        color: Color.fromRGBO(115, 2, 2, 1.0));
  }

  Widget prevButton() {
    return const Icon(Icons.navigate_before,
        color: Color.fromRGBO(115, 2, 2, 1.0));
  }

  Widget doneButton() {
    return const InkWell(
        child: Text("Setujui",
            style: TextStyle(color: Color.fromRGBO(96, 55, 30, 1.0))));
  }

  _requestLocation(BuildContext context) async {
    int z = 0;

    if (Platform.isAndroid) {
      _statuses = await [
        handler.Permission.location,
        handler.Permission.locationAlways,
        handler.Permission.locationWhenInUse,
        handler.Permission.storage,
        handler.Permission.camera,
        handler.Permission.microphone,
        handler.Permission.phone
      ].request();
    } else if (Platform.isIOS) {
      _statuses = await [
        handler.Permission.location,
        handler.Permission.locationWhenInUse,
        handler.Permission.camera,
      ].request();
    }

    _statuses.forEach((key, value) {
      if (value == handler.PermissionStatus.granted) {
        z++;
      } else {
        if (value.isPermanentlyDenied) {
          handler.openAppSettings();
        } else if (value.isDenied || value.isRestricted) {
          key.request();
        }
      }
    });
    if (z == _statuses.length) {
      print("OK");
      saveIntro(context);
    } else {
      print("OK1");
      doneVisible = false;
      _statuses.clear();
      _statuses.forEach((key, value) {
        if (value == handler.PermissionStatus.granted) {
          z++;
        } else {
          if (value.isPermanentlyDenied) {
            handler.openAppSettings();
          } else if (value.isDenied || value.isRestricted) {
            key.request();
          }
        }
      });
    }
  }

  checkIntro(BuildContext context) async {
    SharedPreferences? _pref = await SharedPreferences.getInstance();
    intro = _pref.getBool("introSlider");
    if (intro != null) {
      if (intro!) {
        getPref(context);
      } else {
        setState(() {
          visbleIntro = true;
        });
      }
    } else {
      setState(() {
        visbleIntro = true;
      });
    }
  }

  saveIntro(BuildContext context) async {
    var pref = await SharedPreferences.getInstance();
    pref.setBool("introSlider", true);
    checkIntro(context);
  }

  getPref(BuildContext context) async {
    enableGPS = await Geolocator.isLocationServiceEnabled();
    
    var sharedPref = await SharedPreferences.getInstance();
    isLogin = sharedPref.getInt("isLogin") ?? 0;
    // print("LoginStatus $isLogin");
    if (isLogin == 1) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => 
              (enableGPS)? const HomePage() : const LokasiCek() ));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Splash()));
    }
  }
}
