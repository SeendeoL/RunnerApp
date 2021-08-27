import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:runner/directions_model.dart';
import 'package:runner/main.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:dio/dio.dart';

import 'navigation_drawer_widget.dart';

class AnaSayfa extends StatefulWidget {
  AnaSayfa({Key? key}) : super(key: key);

  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  Duration duration = Duration();
  Timer? timer;

  bool isCountdown = true;
  int currentIndex = 0;
  int activeIndex = 0;
  Marker? _origin;
  Marker? _destination;
  Directions? _info;

  @override
  void initState() {
    super.initState();

    // startTimer();
    reset();
  }

  void reset() {
    setState(() => duration = Duration());
  }

  void addTime() {
    final addSeconds = 1;

    setState(() {
      final seconds = duration.inSeconds + addSeconds;

      duration = Duration(seconds: seconds);
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void stopTimer({bool resets = true}) {
    if (resets) {
      reset();
    }
    setState(() => timer?.cancel());
  }

  // ignore: cancel_subscriptions
  StreamSubscription? _locationSubscription;
  Location _locationTracker = Location();
  Marker? marker;
  Circle? circle;
  GoogleMapController? _controller;

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(39.900076, 32.775363),
    zoom: 16.4746,
  );

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    //bura
    LatLng latlng = LatLng(newLocalData.latitude!, newLocalData.longitude!);
    this.setState(() {
      //Burası nedense çalışmadı markerları eklediğimde
    });
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/images/6.png");

    return byteData.buffer.asUint8List();
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription!.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller!.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  bearing: 192.8334901395799,
                  target:
                      LatLng(newLocalData.latitude!, newLocalData.longitude!),
                  tilt: 0,
                  zoom: 16.5487)));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
    }
    super.dispose();
  }

  void _addMarker(LatLng pos) {
    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Bitiş'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
        _destination = null;
      });
    } else {
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Başlangıç'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,
        );
      });
    }
  }

  final urlImages = [
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHoHngK5WoT-CLE2mqWIWc2LPwB-6UAuXnqkPdhGX0RuThWf3-Ez8vSjJZ8YfWYYmUDrs&usqp=CAU',
    'https://signandpass.org/wp-content/uploads/2020/11/live-sports-news-1-1571384768-3.jpg',
    'https://sporzade.com/wp-content/uploads/2020/03/Yüzme-Antrenörü-Nasıl-Olunur-Kursu-Hakkında-Bilgiler.jpg',
    'https://www.sporeus.com/wp-content/uploads/2020/08/spor-nedir-sporcu-kimdir-1-1024x427.jpg',
    'https://www.sporsoleni.com/images/haberler/2020/05/judo_sporu_nedir_kurallari_ve_hakkinda_bilgi_h186_5f553.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    final screens = [
      Center(
        child: Scaffold(
          //anasayfa
          drawer: NavigationDrawerWidget(),
          appBar: AppBar(
            backgroundColor: Colors.orange,
            title: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.fitWidth,
              height: 70,
            ),
            centerTitle: true,
          ),
          body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Colors.deepOrange,
                  Colors.lightBlue.withOpacity(0.5)
                ])),
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: ListView(
              children: [
                Column(
                  children: [
                    CarouselSlider.builder(
                      options: CarouselOptions(
                        height: 215,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        enlargeCenterPage: true,
                        enlargeStrategy: CenterPageEnlargeStrategy.height,
                        enableInfiniteScroll: true,
                        pageSnapping: true,
                        onPageChanged: (index, reason) =>
                            setState(() => activeIndex = index),
                      ),
                      itemCount: urlImages.length,
                      itemBuilder: (context, index, realIndex) {
                        final urlImage = urlImages[index];
                        return buildImage(urlImage, index);
                      },
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                    buildIndicator(),
                  ],
                ),
                for (int i = 0; i < 10; i++)
                  Card(
                    margin: EdgeInsets.only(top: 15),
                    child: ListTile(
                      leading: Image.asset(
                        'assets/images/news.png',
                        width: 64,
                        height: 64,
                      ),
                      title: Text('Haber Başlığı ${i + 1}'),
                      tileColor: Colors.amberAccent,
                      contentPadding: EdgeInsets.all(2),
                      horizontalTitleGap: 25,
                      hoverColor: Colors.deepOrange,
                      subtitle: Text('28/08/2021'),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      Scaffold(
        //Aktivite Oluştur
        drawer: NavigationDrawerWidget(),
        appBar: AppBar(
          backgroundColor: Colors.brown,
          title: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.fitWidth,
            height: 40,
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Colors.black12,
            Colors.black26,
            Colors.brown.shade300
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: ListView(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 670,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        GoogleMap(
                          mapType: MapType.terrain,
                          initialCameraPosition: initialLocation,
                          //markers: Set.of((marker != null) ? [marker!] : []),  //Burayı sor 6.png için 2 marker arasına nasıl sokulacak ?

                          circles: Set.of((circle != null) ? [circle!] : []),
                          onMapCreated: (GoogleMapController controller) {
                            _controller = controller;
                          },
                          polylines: {
                            if (_info != null)
                              Polyline(
                                polylineId:
                                    const PolylineId('overview_polyline'),
                                color: Colors.red,
                                width: 5,
                                points: _info!.polylinePoints!
                                    .map((e) => LatLng(e.latitude, e.longitude))
                                    .toList(),
                              ),
                          },
                          markers: {
                            if (_origin != null) _origin!,
                            if (_destination != null) _destination!,
                          },
                          onLongPress: _addMarker,
                        ),
                        if (_info != null)
                          Positioned(
                            top: 20.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6.0, horizontal: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.yellowAccent,
                                borderRadius: BorderRadius.circular(20.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 6.0,
                                  )
                                ],
                              ),
                              child: Text(
                                  '${_info!.totalDistance}, ${_info!.totalDuration}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 40.0, top: 10),
                      child: SizedBox(
                        width: 100,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            startTimer();
                          },
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.green,
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.grey.shade800),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: SizedBox(
                        width: 100,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            stopTimer(resets: true);
                          },
                          child: Icon(
                            Icons.stop_rounded,
                            color: Colors.red,
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.grey.shade800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildTimeCard(time: hours, header: 'HOURS'),
                        const SizedBox(width: 8),
                        buildTimeCard(time: minutes, header: 'MINUTES'),
                        const SizedBox(width: 8),
                        buildTimeCard(time: seconds, header: 'SECONDS'),
                      ],
                    ),
                    height: 180,
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.brown.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.brown,
          mini: true,
          autofocus: true,
          child: Icon(
            Icons.location_searching,
            color: Colors.greenAccent,
          ),
          onPressed: () {
            getCurrentLocation();
          },
        ),
      ),
      Scaffold(
        //Geçmiş Aktivitelerim
        drawer: NavigationDrawerWidget(),
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.fitWidth,
            height: 70,
          ),
          centerTitle: true,
        ),

        body: ListView(
          children: [
            for (int i = 0; i < 7; i++)
              Card(
                margin: EdgeInsets.only(top: 15),
                child: ListTile(
                  leading: Image.asset(
                    'assets/images/gecmisaktivite.png',
                    width: 64,
                    height: 64,
                    color: Colors.indigo,
                  ),
                  title: Text('Geçmiş Aktivitem ${i + 1}'),
                  tileColor: Colors.greenAccent,
                  contentPadding: EdgeInsets.all(2),
                  horizontalTitleGap: 25,
                  hoverColor: Colors.black,
                  onTap: () {},
                  subtitle: Text('${i + 1}/08/2021'),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.redAccent,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.green.shade300,
      ),
      Scaffold(
        //Skor Tablosu
        drawer: NavigationDrawerWidget(),
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.fitWidth,
            height: 70,
          ),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            for (int i = 0; i < 7; i++)
              Card(
                margin: EdgeInsets.only(top: 15),
                child: ListTile(
                  leading: Image.asset(
                    'assets/images/scorboard.png',
                    width: 50,
                    height: 50,
                    color: Colors.red,
                    cacheHeight: 45,
                  ),
                  title: Text(
                      'Skor Tahtası ${i + 1}. "nickname of ${i + 1} player !"'),
                  tileColor: Colors.greenAccent,
                  contentPadding: EdgeInsets.all(2),
                  horizontalTitleGap: 25,
                  hoverColor: Colors.black,
                  onTap: () {},
                  subtitle: Text('Skor Sayısı km'),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.redAccent,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.red.shade300,
      ),
    ];
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.greenAccent.shade400,
        currentIndex: currentIndex,
        showUnselectedLabels: false,
        iconSize: 28,
        onTap: (index) => setState(() => currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
            backgroundColor: Colors.orange,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_rounded),
            label: 'Aktivite Olustur',
            backgroundColor: Colors.brown,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'Gecmiş Aktivitelerim',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Skor Tablosu',
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }

  buildTimeCard({required String time, required String header}) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: Colors.orangeAccent.shade200,
                borderRadius: BorderRadius.circular(10)),
            child: Text(
              time,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 29,
              ),
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            header,
            style: TextStyle(color: Colors.white),
          )
        ],
      );
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<String>('urlImages', urlImages));
  }

  Widget buildImage(String urlImage, int index) => ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 7),
          color: Colors.orange,
          child: Image.network(
            urlImage,
            fit: BoxFit.cover,
          ),
        ),
      );

  buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: urlImages.length,
        effect: SlideEffect(
            dotWidth: 15,
            dotHeight: 14,
            activeDotColor: Colors.red,
            dotColor: Colors.black26),
      );
}
