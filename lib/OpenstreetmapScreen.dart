import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class OpenstreetmapScreen extends StatefulWidget {
  const OpenstreetmapScreen({super.key});


  @override
  State<OpenstreetmapScreen> createState() => _OpenstreetmapScreenState();
}

class _OpenstreetmapScreenState extends State<OpenstreetmapScreen> {
  final MapController _mapController = MapController();

  final Location  _location = Location();
  final TextEditingController _locationController = TextEditingController();
  bool isLoading = true;

  LatLng ? _currentLocation ;
  LatLng ? _destination ;
  List<LatLng> _route = [];

  @override
  void initState(){
    super.initState();
    _initializeLocation();
  }
  Future<void> _initializeLocation() async {
    if(! await  _checkRequtestPermissions()) return;
    _location.onLocationChanged.listen(
      (LocationData locationData){
      if(locationData.latitude != null && locationData.longitude != null ){
        setState(() {

          _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
          isLoading= false;
        });
      }
    });

  }

  Future<bool> _checkRequtestPermissions() async {
    bool serviceEnablled = await _location.serviceEnabled();
    if(!serviceEnablled){
      serviceEnablled = await _location.requestService();
      if(!serviceEnablled){
        return false;
      }
    }
    PermissionStatus permissionGranted = await _location.hasPermission();
    if(permissionGranted == PermissionStatus.denied){
      permissionGranted = await _location.requestPermission();
      if(permissionGranted != PermissionStatus.granted){
        return false;
      }
    }
    return true;

  }

  Future <void> _userCurrentLocation() async {
    if(_currentLocation != null){
       _mapController.move(_currentLocation!, 15);
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Current location is not available")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Open Street Map"),
        backgroundColor: Colors.blue,
      ),
      body: Stack(

        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(0, 0),
              initialZoom: 2,
              minZoom: 0,
              maxZoom: 100,
            ),
            children:
              [
                  TileLayer(
                    urlTemplate:  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                CurrentLocationLayer(
                  style: const LocationMarkerStyle(
                    marker: DefaultLocationMarker(
                      child: Icon(Icons.location_pin, color: Colors.white,),

                    ),
                    markerSize: Size(35,35),
                    markerDirection: MarkerDirection.heading,
                  ),

                ),
              ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){

          _userCurrentLocation();
      },
      child: Icon(Icons.my_location,
      size: 30,
      color: Colors.white,
      ),
        elevation: 3,
        backgroundColor: Colors.blue,

      ),
    );
  }
}
