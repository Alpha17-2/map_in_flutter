import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewAddressPage extends StatefulWidget {
  @override
  State<NewAddressPage> createState() => _NewAddressPageState();
}

class _NewAddressPageState extends State<NewAddressPage> {
  late GoogleMapController _controller;
  LatLng? markerPos;
  LatLng? initPos;
  Set<Marker> markers = {};
  TextEditingController? searchPlaceController;
  bool loadingMap = false;
  bool init = true;
  bool loadingAddressDetails = false;
  String addressTitle = '';
  String locality = '';
  String city = '';
  String state = '';
  String pincode = '';

  StreamController<LatLng> streamController = StreamController();

  void fetchAddressDetail(LatLng location) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    addressTitle = placemarks[0].name!;
    locality = placemarks[0].locality!;
    city = placemarks[0].subLocality!;
    pincode = placemarks[0].postalCode!;
    state = placemarks[0].administrativeArea!;
  }

  getCurrentLoc() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    initPos = LatLng(position.latitude, position.longitude);
    streamController.add(initPos as LatLng);
    setState(() {
      loadingMap = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadingMap = true;
    getCurrentLoc();
    searchPlaceController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  renderMap() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: (loadingMap)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              buildingsEnabled: true,
              indoorViewEnabled: false,
              onMapCreated: (controller) {
                _controller = controller;
                setState(() {
                  fetchAddressDetail(initPos!);
                });
              },
              onCameraMove: (CameraPosition pos) {
                streamController.add(pos.target);
              },
              initialCameraPosition: CameraPosition(
                target: initPos!,
                zoom: 14.4746,
              ),
              mapType: MapType.normal,
            ),
    );
  }

  backButton() {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      color: Colors.black87,
      icon: const Icon(Icons.arrow_back),
    );
  }

  searchBox() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black87, width: 0.1),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(10),
      child: Center(
        child: TextFormField(
          controller: searchPlaceController,
          onChanged: (value) async {
            // ignore
          },
          decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              border: InputBorder.none,
              hintText: "Search Places...",
              labelStyle: TextStyle(color: Colors.black87)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: searchBox(),
          ),
          body: SizedBox(
            child: Stack(
              alignment: Alignment.center,
              children: [
                renderMap(),
                Positioned(
                    top: MediaQuery.of(context).size.height * 0.4,
                    child: Image.asset(
                      'assets/pin.png',
                      height: 30,
                      fit: BoxFit.cover,
                    )),
                Positioned(
                    bottom: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.red[200],
                                size: MediaQuery.of(context).size.width * 0.08,
                              ),
                              const Padding(padding: EdgeInsets.all(2)),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    addressTitle,
                                    style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        color: Colors.black87),
                                  ),
                                  const Padding(padding: EdgeInsets.all(2)),
                                  Text(
                                    city,
                                    style: const TextStyle(
                                      fontSize: 6,
                                      color: Colors.black54,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          const Padding(padding: EdgeInsets.all(10)),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(10.0))),
                                    backgroundColor: Colors.white,
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => const Text('ignore'));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.red[400],
                                    borderRadius: BorderRadius.circular(5)),
                                height:
                                    MediaQuery.of(context).size.height * 0.07,
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Center(
                                    child: StreamBuilder<LatLng>(
                                  stream: streamController.stream,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Column(
                                        children: [
                                          Text('${snapshot.data!.latitude}'),
                                          Text('${snapshot.data!.longitude}'),
                                        ],
                                      );
                                    } else {
                                      return const CircularProgressIndicator();
                                    }
                                  },
                                )

                                    // Text(
                                    //   'Confirm Address',
                                    //   style: TextStyle(
                                    //     color: Colors.white,
                                    //     fontSize: 15,
                                    //   ),
                                    // ),
                                    ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ))
              ],
            ),
          )),
    );
  }
}
