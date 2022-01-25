import 'dart:io';

import 'package:face_id_plus/screens/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

class LokasiCek extends StatefulWidget {
  const LokasiCek({Key? key}) : super(key: key);

  @override
  _LokasiCekState createState() => _LokasiCekState();
}

class _LokasiCekState extends State<LokasiCek> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "GPS",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Text("GPS anda Masih Mati."),
            const Text(
                "Aplikasi membutuhkan Lokasi anda untuk mengetahui apakah anda berada di dalam area yang di tentukan!"),
            Image.asset("assets/images/abp_maps.png"),
            const Center(child: Text("Area Lokasi yang dimaksud")),
            ElevatedButton(
                onPressed: () async {
                  bool reqService = await Location().requestService();
                  if (reqService) {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => const HomePage()));
                  }
                },
                child: Text("Aktifkan Lokasi?")),
            ElevatedButton(
                onPressed: () {
                  if (Platform.isIOS) {
                    exit(0);
                  } else {
                    SystemNavigator.pop();
                  }
                },
                child: Text("Tidak, Keluar!")),
          ],
        ),
      ),
    );
  }
}
