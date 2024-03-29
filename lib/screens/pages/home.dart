import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:face_id_plus/model/last_absen.dart';
import 'package:face_id_plus/model/map_area.dart';
import 'package:face_id_plus/screens/pages/area.dart';
import 'package:face_id_plus/screens/pages/ios/pulang_ios.dart';
import 'package:face_id_plus/screens/pages/painters/face_detector_painter.dart';
import 'package:face_id_plus/screens/pages/profile.dart';
import 'package:face_id_plus/services/net_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as iosLocation;
import 'dart:ui' as ui;

import 'ios/masuk_ios.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool serviceEnable = false;
  bool statusLokasi = false;
  iosLocation.Location locationIOS = iosLocation.Location();
  late final handler.Permission _permission = handler.Permission.location;
  late handler.PermissionStatus _permissionStatus;
  String? jamMasuk;
  String? jamPulang;
  bool _enMasuk = false;
  bool _enPulang = false;
  bool permanenDitolak = false;
  CustomPaint? customPaint;
  bool _googleMaps = false;
  FaceDetector faceDetector =
      GoogleMlKit.vision.faceDetector(const FaceDetectorOptions(
    enableContours: true,
    enableClassification: true,
  ));
  bool isBusy = false;
  String? _jam;
  String? _menit;
  String? _detik;
  String? _tanggal;
  String? nama, nik;
  String? _jam_kerja;
  String? id_roster;
  String? connStat;
  String? kode_roster;
  int? isLogin = 0;
  double _masuk = 0.0;
  double _pulang = 0.0;
  double _diluarAbp = 0.0;
  String startClock = "20:00";
  bool outside = false;
  late Position currentPosition;
  LatLng? myLocation;
  bool iosMapLocation = false;
  var geoLocator = Geolocator();
  Position? position;
  final _map_controller = Completer();
  late GoogleMapController _googleMapController;
  late BitmapDescriptor customIcon;
  late Set<Marker> markers = {};
  late Marker marker;
  late DateTime now;
  bool lokasiPalsu = false;
  Widget loader = const Center(child: CircularProgressIndicator());
  late Timer timerss;
  static const CameraPosition _kGooglePlex =
      CameraPosition(target: LatLng(-0.5634222, 117.0139606), zoom: 14.2746);
  Future<void> locatePosition() async {
    serviceEnable = await Geolocator.isLocationServiceEnabled();
    if (serviceEnable) {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentPosition = position!;

      myLocation = LatLng(currentPosition.latitude, currentPosition.longitude);
      lokasiPalsu = position!.isMocked;
      if (myLocation != null) {
        if (!iosMapLocation) {
          iosMapLocation = true;
        }
        CameraPosition cameraPosition =
            CameraPosition(target: myLocation!, zoom: 17.5756);
        return await _googleMapController
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      }
    } else {
      outside = false;
      _diluarAbp = 1.0;
    }
  }

  @override
  void initState() {
    TimeOfDay mulai = TimeOfDay(
        hour: int.parse(startClock.split(":")[0]),
        minute: int.parse(startClock.split(":")[1])
        
        );
    print("Jam Sekarang = ${mulai}");
    NetworkCheck().checkConnection(context);
    setCustomMapPin();
    if (Platform.isAndroid) {
      _requestLocation();
    } else if (Platform.isIOS) {
      izinTidakAda();
    }
    if (lokasiPalsu == true) {
      appClose();
    }
    nama = "";
    nik = "";
    _jam = "";
    _menit = "";
    _detik = "";
    jamMasuk = "";
    jamPulang = "";
    kode_roster = "";
    setState(() {
      getPref(context);
      DateFormat fmt = DateFormat("dd MMMM yyyy");
      DateTime old = DateTime.now();
      now = DateTime(old.year, old.month, old.day, mulai.hour, mulai.minute,10);
      print("Jam Sekarang = ${now}");

      _tanggal = fmt.format(now);
      timerss =
          Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
    });
    super.initState();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void setCustomMapPin() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/abp_60x60.png', 60);
    customIcon = await BitmapDescriptor.fromBytes(markerIcon);
  }

  @override
  Widget build(BuildContext context) {
    return _mainContent();
  }

  Widget _mainContent() {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          (nik == "18060207")
              ? IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const AreaAbp()));
                  },
                  icon: const Icon(Icons.map_sharp),
                  color: Colors.white,
                )
              : Container(),
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const Profile()));
            },
            icon: const Icon(Icons.menu),
            color: Colors.white,
          ),
        ],
        backgroundColor: const Color(0xFF21BFBD),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: Column(
        children: <Widget>[
          (Platform.isAndroid) ? _headerContent() : _headerIos(),
          const SizedBox(height: 8),
          Expanded(
            child: IntrinsicHeight(child: _futureBuilder()),
          ),
        ],
      ),
    );
  }

  Widget _futureBuilder() {
    return FutureBuilder<List<MapAreModel>>(
      future: _loadArea(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.none) {
          return Text("${snapshot.connectionState}");
        }
        if (!serviceEnable) {
          outside = false;
          _diluarAbp = 1.0;
          return enableGPS();
          print("1");
        }
        if (snapshot.hasData) {
          if (!serviceEnable) {
            outside = false;
            _diluarAbp = 1.0;
            print("2");

            return enableGPS();
          }
          List<LatLng> pointAbp = [];
          List<MapAreModel> data = snapshot.data;
          List<Polygon> _polygons = [];
          for (var p in data) {
            pointAbp.add(LatLng(p.lat!, p.lng!));
          }
          _polygons.add(Polygon(
              polygonId: const PolygonId("ABP"),
              points: pointAbp,
              strokeWidth: 2,
              strokeColor: Colors.red,
              fillColor: Colors.green.withOpacity(0.25)));

          if (Platform.isAndroid) {
            if (!serviceEnable) {
              print("3");

              outside = false;
              _diluarAbp = 1.0;
              return enableGPS();
            }
            if (_permissionStatus.isGranted) {
              locatePosition();
              print("4");

              return _loadMaps(_polygons, pointAbp);
            } else {
              print("5");

              _requestLocation();
              _googleMaps = false;
              locatePosition();
              return const Center(child: CircularProgressIndicator());
            }
          } else if (Platform.isIOS) {
            if (!serviceEnable) {
              print("6");

              outside = false;
              _diluarAbp = 1.0;
              return enableGPS();
            }
            if (myLocation == null) {
              iosGetLocation();
              if (iosMapLocation) {
                print("8");

                locatePosition();
                return _loadMaps(_polygons, pointAbp);
              } else {
                if (statusLokasi) {
                  locatePosition();
                } else {
                  return izinLokasi();
                }
              }
            } else {
              print("10");

              locatePosition();
              return _loadMaps(_polygons, pointAbp);
            }
          }
          _googleMaps = false;
          return const Center(child: CircularProgressIndicator());
        } else {
          if (!serviceEnable) {
            print("11");
            outside = false;
            _diluarAbp = 1.0;
            return enableGPS();
          }
          _loadArea();
          _googleMaps = false;
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget enableGPS() {
    return ListView(
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
        const Center(child: Text("GPS anda Masih Mati.")),
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: Text(
                "Aplikasi membutuhkan Lokasi anda untuk mengetahui apakah anda berada di dalam area yang di tentukan!"),
          ),
        ),
        Center(
            child: Image.asset(
          "assets/images/abp_maps.png",
          width: 200,
          height: 200,
        )),
        const Center(child: Text("Area Lokasi yang dimaksud")),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: () async {
                bool reqService = await iosLocation.Location().requestService();
                if (reqService) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));
                }
              },
              child: const Text("Aktifkan Lokasi?")),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: () {
                appClose();
              },
              child: const Text("Tidak, Keluar!")),
        ),
      ],
    );
  }

  cekGps() async {
    serviceEnable = await Geolocator.isLocationServiceEnabled();
  }

  Future<void> iosGetLocation() async {
    iosLocation.LocationData _locationData = await locationIOS.getLocation();
    myLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
    if (myLocation != null) {
      iosMapLocation = true;
    } else {
      iosMapLocation = false;
    }

    return;
  }

  Widget _loadMaps(List<Polygon> _shape, List<LatLng> pointAbp) {
    if (myLocation != null) {
      bool _insideAbp = _checkIfValidMarker(myLocation!, pointAbp);
      if (_insideAbp) {
        _diluarAbp = 0.0;
        outside = true;
      } else {
        outside = false;
        _diluarAbp = 1.0;
      }
    }
    return GoogleMap(
      initialCameraPosition: _kGooglePlex,
      mapType: MapType.normal,
      onMapCreated: (GoogleMapController controller) async {
        _map_controller.complete(controller);
        _googleMapController = await controller;
        _googleMaps = true;
        setState(() {
          marker = Marker(
            markerId: const MarkerId('abpenergy'),
            position: const LatLng(-0.5634222, 117.0139606),
            icon: customIcon,
            infoWindow: const InfoWindow(
              title: 'PT Alamjaya Bara Pratama',
            ),
          );
          markers.add(marker);
          _googleMapController
              .showMarkerInfoWindow(const MarkerId("abpenergy"));
        });
      },
      polygons: Set<Polygon>.of(_shape),
      markers: markers,
      myLocationEnabled: true,
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
    );
  }

  Widget _headerContent() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: Stack(children: [
        Container(
          padding: const EdgeInsets.only(bottom: 55),
          color: const Color(0xFF21BFBD),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "$nama",
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontSize: 15.0),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Text(
                      "$nik",
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontSize: 15.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _contents(),
      ]),
    );
  }

  Widget _headerIos() {
    return Stack(children: [
      Container(
        padding: const EdgeInsets.only(bottom: 55),
        color: const Color(0xFF21BFBD),
        child: Column(
          children: <Widget>[
            Row(
              children: const [
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    "Selamat Datang,",
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Text(
                    "$nama",
                    style: const TextStyle(
                        fontFamily: 'Montserrat', color: Colors.white),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 60.0),
                  child: Text(
                    "$nik",
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 15.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      _contents(),
    ]);
  }

  Widget _contents() {
    return Card(
      elevation: 10,
      margin: const EdgeInsets.only(top: 60, left: 20, right: 20),
      color: const Color(0xFFF2E638),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            roster(),
            (Platform.isAndroid) ? _jamWidget() : _jamIos(),
            (outside) ? _btnAbsen() : diluarArea(),
          ],
        ),
      ),
    );
  }

  Widget roster() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                "Jadwal",
                style: TextStyle(color: Colors.black87),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "$kode_roster",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),
                ),
              ),
            ],
          ),
          Text("$_tanggal"),
        ],
      ),
    );
  }

  Widget _jamWidget() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$_jam",
                style: const TextStyle(
                    color: Color(0xFF8C6A03),
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0),
              ),
              const Text(
                ":",
                style: TextStyle(
                    color: Color(0xFF8C6A03),
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0),
              ),
              Text(
                "$_menit",
                style: const TextStyle(
                    color: Color(0xFF8C6A03),
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0),
              ),
              const Text(
                ":",
                style: TextStyle(
                    color: Color(0xFF8C6A03),
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0),
              ),
              Text(
                "$_detik",
                style: const TextStyle(
                    color: Color(0xFF8C6A03),
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0),
              ),
            ],
          ),
        ),
        Center(
          child: Text(
            (_jam_kerja != null) ? "$_jam_kerja" : "",
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _jamIos() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$_jam",
                style: const TextStyle(
                    color: Color(0xFF8C6A03),
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
              const Text(
                ":",
                style: TextStyle(
                    color: Color(0xFF8C6A03),
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
              Text(
                "$_menit",
                style: const TextStyle(
                    color: Color(0xFF8C6A03),
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
              const Text(
                ":",
                style: TextStyle(
                    color: Color(0xFF8C6A03),
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
              Text(
                "$_detik",
                style: const TextStyle(
                    color: Color(0xFF8C6A03),
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
            ],
          ),
        ),
        Center(
          child: Text(
            "$_tanggal",
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    NetworkCheck().listener.cancel();
    timerss.cancel();
    super.dispose();
  }

  Widget _btnAbsen() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        (_enMasuk)
            ? Expanded(
                child: Opacity(
                  opacity: _masuk,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2.5),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      child: const Text(
                        "Masuk",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _enMasuk
                          ? () {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              (Platform.isIOS)
                                                  ? IosMasuk(
                                                      nik: nik!,
                                                      status: "Masuk",
                                                      lat:
                                                          "${myLocation?.latitude}",
                                                      lng:
                                                          "${myLocation?.longitude}",
                                                      id_roster: id_roster!,
                                                    )
                                                  : IosMasuk(
                                                      nik: nik!,
                                                      status: "Masuk",
                                                      lat:
                                                          "${myLocation?.latitude}",
                                                      lng:
                                                          "${myLocation?.longitude}",
                                                      id_roster: id_roster!,
                                                    )))
                                  .then((value) => getPref(context));
                            }
                          : null,
                    ),
                  ),
                ),
              )
            : Expanded(
                child: ElevatedButton(
                onPressed: null,
                child: Text("$jamMasuk"),
              )),
        (_enPulang)
            ? Expanded(
                child: Opacity(
                  opacity: _pulang,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2.5),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                      child: const Text(
                        "Pulang",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _enPulang
                          ? () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => (Platform.isIOS)
                                          ? IosPulang(
                                              nik: nik!,
                                              status: "Pulang",
                                              lat: "${myLocation?.latitude}",
                                              lng: "${myLocation?.longitude}",
                                              id_roster: id_roster!,
                                            )
                                          : IosPulang(
                                              nik: nik!,
                                              status: "Pulang",
                                              lat: "${myLocation?.latitude}",
                                              lng: "${myLocation?.longitude}",
                                              id_roster: id_roster!,
                                            ))).then(
                                  (value) => getPref(context));
                            }
                          : null,
                    ),
                  ),
                ),
              )
            : Expanded(
                child:
                    ElevatedButton(onPressed: null, child: Text("$jamPulang")))
      ],
    );
  }

  Widget diluarArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Opacity(
                opacity: _diluarAbp,
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Center(
                          child: Column(
                        children: const [
                          Text(
                            "Anda Diluar Area",
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            "PT Alamjaya Bara Pratama",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ))),
                )))
      ],
    );
  }

  void _getTime() {
    setState(() {
      _jam = "${now.hour}".padLeft(2, "0");
      _menit = "${now.minute}".padLeft(2, "0");
      _detik = "${now.second}".padLeft(2, "0");
    });
  }

  Future<List<MapAreModel>> _loadArea() async {
    await cekGps();
    outside = false;
    _permissionStatus = await _permission.status;
    var area = await MapAreModel.mapAreaApi("0");
    return area;
  }

  bool _checkIfValidMarker(LatLng tap, List<LatLng> vertices) {
    int intersectCount = 0;
    for (int j = 0; j < vertices.length - 1; j++) {
      if (rayCastIntersect(tap, vertices[j], vertices[j + 1])) {
        intersectCount++;
      }
    }

    return ((intersectCount % 2) == 1); // odd = inside, even = outside;
  }

  bool rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = tap.latitude;
    double pX = tap.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false; // a and b can't both be above or below pt.y, and a or
      // b must be east of pt.x
    }

    double m = (aY - bY) / (aX - bX); // Rise over run
    double bee = (-aX) * m + aY; // y = mx + b
    double x = (pY - bee) / m; // algebra is neat!

    return x > pX;
  }

  getPref(BuildContext context) async {
    var sharedPref = await SharedPreferences.getInstance();
    isLogin = sharedPref.getInt("isLogin")!;
    if (isLogin == 1) {
      nama = sharedPref.getString("nama");
      nik = sharedPref.getString("nik");
      int? showAbsen = sharedPref.getInt("show_absen");
      loadLastAbsen(nik!);
    } else {
      nama = "";
      nik = "";
    }
  }

  _requestLocation() async {
    var status = await _permission.status;
    if (status.isDenied) {
      await handler.Permission.locationAlways.request();
    }
    if (status.isPermanentlyDenied) {
      handler.openAppSettings();
    }
    if (status.isGranted) {
      locatePosition();
    }
    if (status.isRestricted) {
      handler.openAppSettings();
    }
    Map<handler.Permission, handler.PermissionStatus> _statuses = await [
      handler.Permission.location,
      handler.Permission.locationAlways,
      handler.Permission.locationWhenInUse
    ].request();
    return _statuses;
  }

  loadLastAbsen(String _nik) async {
    _diluarAbp = 1.0;
    outside = false;
    var lastAbsen = await LastAbsen.apiAbsenTigaHari(_nik);
    if (lastAbsen != null) {
      _jam_kerja = lastAbsen.jamKerja;
      kode_roster = lastAbsen.kodeRoster;
      id_roster = "${lastAbsen.idRoster}";
      if (lastAbsen.lastAbsen != null) {
        var absenTerakhir = lastAbsen.lastAbsen;
        var jamAbsen = lastAbsen.presensiMasuk;
        if (absenTerakhir == "Masuk") {
          if (lastAbsen.lastNew == "Pulang") {
            outside = false;
            _masuk = 1.0;
            _enMasuk = true;
            _enPulang = false;
            _pulang = 0.0;
            jamPulang = "${jamAbsen?.jam}";
            jamMasuk = "";
          } else {
            jamMasuk = "${jamAbsen?.jam}";
            jamPulang = "";
            outside = false;
            _enMasuk = false;
            _enPulang = true;
            _masuk = 0.0;
            _pulang = 1.0;
          }
        } else if (absenTerakhir == "Pulang") {
          jamMasuk = "";
          jamPulang = "";
          outside = false;
          _enMasuk = true;
          _enPulang = false;
          _masuk = 1.0;
          _pulang = 0.0;
        }
      } else {
        jamMasuk = "";
        jamPulang = "";
        _enMasuk = true;
        outside = false;
        _enPulang = false;
        _masuk = 1.0;
        _pulang = 0.0;
      }
    }
  }

  Widget appClose() {
    return AlertDialog(
      title: const Text('Lokasi'),
      content: const Text('Aplikasi Fake Gps / Lokasi Palsu Terdetek!'),
      actions: <Widget>[
        TextButton(
          onPressed: () => SystemNavigator.pop(),
          child: const Text('Keluar'),
        ),
      ],
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final faces = await faceDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      customPaint = CustomPaint(painter: painter);
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {
        if (faces.length == 1) {
          Future.delayed(const Duration(milliseconds: 1000));
          Navigator.maybePop(context, inputImage.filePath);
        }
      });
    }
  }

  Widget izinLokasi() {
    return ListView(
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
        const Center(child: Text("Izin Lokasi (GPS) Tidak Ada.")),
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: Text(
                "Aplikasi membutuhkan Lokasi anda untuk mengetahui apakah anda berada di dalam area yang di tentukan!"),
          ),
        ),
        Center(
            child: Image.asset(
          "assets/images/abp_maps.png",
          width: 200,
          height: 200,
        )),
        const Center(child: Text("Area Lokasi yang dimaksud")),
        (permanenDitolak)
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () async {
                      var lokasi =
                          await handler.Permission.locationWhenInUse.status;
                      if (lokasi.isPermanentlyDenied) {
                        await handler.openAppSettings();
                      }
                    },
                    child: const Text("Buka Pengaturan")),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () async {
                      var lokasi =
                          await handler.Permission.locationWhenInUse.status;
                      if (!lokasi.isGranted) {
                        await handler.Permission.locationWhenInUse.request();
                      }
                    },
                    child: const Text("Minta Izin?")),
              ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: () {
                appClose();
              },
              child: const Text("Tidak, Keluar!")),
        ),
      ],
    );
  }

  izinTidakAda() async {
    var lokasi = await handler.Permission.locationWhenInUse;
    var status = await lokasi.status;
    if (status == handler.PermissionStatus.granted) {
      statusLokasi = true;
      permanenDitolak = false;
    } else if (status == handler.PermissionStatus.denied) {
      statusLokasi = false;
      permanenDitolak = false;
    } else if (status == handler.PermissionStatus.permanentlyDenied) {
      statusLokasi = false;
      permanenDitolak = true;
    }
  }
}
