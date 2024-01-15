import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mapsapp0/firebase_options.dart';
import 'package:mapsapp0/firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  final List<Marker> markers0 = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harita'),
      ),
      body: FlutterMap(
      
      options:  MapOptions(
      initialCenter: const LatLng(38.335729, 38.441089),
      initialZoom: 15,
      onTap: (tapPosition, point) {
        _handleTap(point);
      },
      
    ),
    children: [
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.example.app',
      ),MarkerLayer(markers: markers0),]
      
      ),
    floatingActionButton: FloatingActionButton(onPressed: () {
       Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  YanPage(markers0: markers0)),
          );
    },
    child: 
      const Text("Bilgi ekleme",style: TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),),
    ),
    bottomNavigationBar: const BottomAppBar(
        color: Colors.blue,
        child:Text("işaretçi eklemek için sol tık atınız",style: TextStyle(
          fontSize: 19
        ),) ),
    );
  
  }
  

  void _handleTap(LatLng tappedPoint) {
    // Create a new marker at the tapped location
    Marker newMarker = Marker(child: const Icon(Icons.location_on),
    point:tappedPoint,
    height: 10,
    width: 10,
    
     );

    // Update the markers list and rebuild the widget
    setState(() {
      markers0.add(newMarker);
    });
  }
}

class YanPage extends StatefulWidget {

  final List<Marker>? markers0;
  const YanPage({super.key,this.markers0});
  @override
  State<YanPage> createState() => _YanPageState();
}

class _YanPageState extends State<YanPage> {
  final FirestoreService firestoreService = FirestoreService();
  List<String> textcontrol=[];
  List<String> latlonglist= [];
  String textcontrol1="";
  String textcontrol2="";
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ekleme yap"),
      ),
      body: ListView.builder(
        itemCount: widget.markers0?.length ?? 0,
        itemBuilder: (context, index) {
          if (widget.markers0 != null && widget.markers0!.isNotEmpty) {
            return Column(children: [
              Text("marker $index"), 
              
              TextField(
                onChanged: (String value){
                  setState(() {
                    textcontrol1 =value;
                    textcontrol2 ="${(widget.markers0!)[index].point.latitude},${(widget.markers0!)[index].point.longitude}";
                  });
                },
                decoration: const InputDecoration(
                  labelText:'hasar durumu' 
                ),
              ),
              ElevatedButton(onPressed: (){
                firestoreService.addlocation(textcontrol2,textcontrol1);
                
              }, child: Text("marker${index.toString()}'i ekle")),
              
            ],);
          }

          // Handle the case where markers is null or empty
          return Container(
            child: const Text('No markers available'),
          );
        },
        
      ),
    bottomNavigationBar: const BottomAppBar(color: Colors.red,
      child: Text("önce veri girin, ilgili kutunun altındaki ekle tuşuna basın sonra diğer kutulara ekleme yapın",style: TextStyle(
      fontSize: 25,
      color: Colors.yellow
    ),),
    
    ),
    floatingActionButton: FloatingActionButton(onPressed: () {
      Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RenkliMarker()),
          );
    },
    child:const  Text("hasar haritası",style: TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),),
    ),
    );
  }
}




class RenkliMarker extends StatefulWidget {
  const RenkliMarker({super.key});

  @override
  State<RenkliMarker> createState() => RenkliMarkerPage();
}

class RenkliMarkerPage extends State<RenkliMarker> {
  List<Marker> markerlist0=[];
  final FirestoreService firestoreService = FirestoreService();
  
  /*@override
  void initState() {
    super.initState();
    updateMarkers(markerlist0); // Call updateMarkers when the page is initially loaded
  }*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('hasar durumunu görebilmek için ekrana 1 defa tıklamanız yeterlidir',style: TextStyle(
          color: Colors.black
        ),),
      ),
      body: FlutterMap(
      
      options:   MapOptions(
      initialCenter: LatLng(38.335729, 38.441089),
      initialZoom: 15,
      onTap: (tapPosition, point) {
        updateMarkers(markerlist0);
      },
            
    ),
    children: [
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.example.app',
      ),MarkerLayer(markers: markerlist0),]
      
      ),
      bottomNavigationBar: const BottomAppBar(
        color: Colors.blue,
        child:Text("Dikkat işareti: Ağır hasarlı | Tik işareti: Hafif hasarlı",style: TextStyle(
          fontSize: 19
        ),) ),
         );
  }
 void updateMarkers(markerlist0) {
    final FirestoreService firestoreService = FirestoreService();
    List<Marker> newMarkerList = [];
    
    firestoreService.getDataStream().listen((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        for (int i = 0; i < snapshot.docs.length; i++) {

          List<String> latlong = snapshot.docs[i]['konum'].split(",");
          double latitude = double.parse(latlong[0]);
          double longitude = double.parse(latlong[1]);
          LatLng location = LatLng(latitude, longitude);
          

          
          if (snapshot.docs[i]['hasarBilgisi'] == 'ağır') {
            Marker newMarker = Marker(
              child: const Icon(Icons.warning_amber),
              point: location,
              height: 10,
              width: 10,
            );
            setState(() {
              newMarkerList.add(newMarker);
            });
            
          } else if (snapshot.docs[i]['hasarBilgisi'] == 'hafif') {
            Marker newMarker = Marker(
              child: const Icon(Icons.check),
              point: location,
              height: 10,
              width: 10,
            );
           setState(() {
              newMarkerList.add(newMarker);
            });
          }
        }
        setState(() {
        markerlist0.clear();
        markerlist0.addAll(newMarkerList);
        });
       
      }
    });
  }
}
