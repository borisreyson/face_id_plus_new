import 'dart:ui';

import 'package:face_id_plus/screens/pages/cek_lokasi.dart';
import 'package:face_id_plus/screens/pages/home.dart';
import 'package:face_id_plus/screens/permission/izin_kamera.dart';
import 'package:face_id_plus/splash.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:shared_preferences/shared_preferences.dart';

class Lokasi extends StatefulWidget {
  const Lokasi({Key? key}) : super(key: key);
  @override
  _LokasiState createState() => _LokasiState();
}

class _LokasiState extends State<Lokasi> {
  late bool statusLokasi;
  @override
  void initState() {
    cekLokasi();
    super.initState();
  }

  Future<bool> cekLokasi() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<bool> izinLokasi() async {
    var lokasi = await handler.Permission.locationWhenInUse;
    var status = await lokasi.status;
    if (status == handler.PermissionStatus.granted) {
      statusLokasi = true;
    }else
    if (status == handler.PermissionStatus.denied) {
      statusLokasi = false;
    } else if (status == handler.PermissionStatus.permanentlyDenied) {
      statusLokasi = false;
    }
    return statusLokasi;
  }

  getPermission() async {
    var mintaIzin = await handler.Permission.locationWhenInUse.status;
    if (mintaIzin == handler.PermissionStatus.denied ||
        mintaIzin == handler.PermissionStatus.limited) {
      await handler.Permission.locationWhenInUse.request();
    } else if (mintaIzin == handler.PermissionStatus.permanentlyDenied) {
      await handler.openAppSettings();
    }
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color(0xFF2D4B73),
          Color(0xFF253C59),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "Lokasi PT Alamjaya Bara Pratama",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                ),
                Image.asset(
                  "assets/images/abp_maps.png",
                  width: 250,
                  height: 250,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Kami Membutuhkan Lokasi Anda untuk mengetahui anda berada di area PT Alamajaya Bara Pratama Atau tidak, jadi kami membutukan izin lokasi anda pada saat aplikasi ini di gunakan.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                FutureBuilder(
                    future: izinLokasi(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        print("Status Izin = ${snapshot.data}");
                        if (snapshot.data) {
                          return ElevatedButton.icon(
                              label: const Text("Selanjutnya"),
                              style: ElevatedButton.styleFrom(
                                  primary: Color.fromARGB(255, 3, 131, 35)),
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const IzinKamera()));
                              },
                              icon: const Icon(Icons.chevron_right));
                        } else {
                          return ElevatedButton.icon(
                              label: const Text("Meminta Izin Lokasi"),
                              style: ElevatedButton.styleFrom(
                                  primary: const Color(0xFFBF8D30)),
                              onPressed: () {
                                getPermission();
                              },
                              icon: const Icon(Icons.approval));
                        }
                      }else{
                        print("Status Izin = ${snapshot.data}");

                      }
                      return Container();
                    }),
                const SizedBox(
                  height: 10,
                ),
                FutureBuilder(
                    future: cekLokasi(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return Visibility(
                          visible: (snapshot.data) ? false : true,
                          child: ElevatedButton.icon(
                              label: const Text(
                                "Aktifkan Lokasi",
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.white),
                              onPressed: () {},
                              icon: const Icon(
                                Icons.location_disabled,
                                color: Colors.red,
                              )),
                        );
                      } else {
                        return Container();
                      }
                    })
              ]),
        ),
      ),
    );
  }
}
