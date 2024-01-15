import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  final CollectionReference konumlar = FirebaseFirestore.instance.collection('konumlar');

  Future<void> addlocation(String latlong,String hasarBilgisi){
    return konumlar.add({
      'konum':latlong,
      'hasarBilgisi':hasarBilgisi
    });
  }
  Stream<QuerySnapshot> getDataStream(){
    final dataStream = konumlar.orderBy('konum',descending: true).snapshots();
    return dataStream;
  }

  
}