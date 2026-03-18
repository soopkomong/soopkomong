import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soopkomong/data/models/location_model.dart';

/// [Data Layer] - Remote DataSource Interface
/// Firebase Firestore 등 외부 서버로부터 데이터를 가져오는 규격을 정의합니다.
abstract class RemoteLocationDataSource {
  Future<List<LocationModel>> getRemoteLocations();
  Stream<List<LocationModel>> watchRemoteLocations();
  Future<void> saveLocation(LocationModel location);
}

class RemoteLocationDataSourceImpl implements RemoteLocationDataSource {
  final FirebaseFirestore _firestore;

  RemoteLocationDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<LocationModel>> getRemoteLocations() async {
    final snapshot = await _firestore.collection('locations').get();
    return snapshot.docs
        .map((doc) => LocationModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Stream<List<LocationModel>> watchRemoteLocations() {
    return _firestore.collection('locations').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => LocationModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  @override
  Future<void> saveLocation(LocationModel location) async {
    // Firestore 전용 데이터 맵 생성 (객체 구조에 따라 조정 필요)
    final data = {
      'contentId': location.id.toString(),
      'region': location.region,
      'title': location.name,
      'lat': location.lat,
      'lng': location.lng,
      'petIds': location.petIds,
      'radius': location.radius,
      'imageUrls': location.imageUrls,
      'address': location.address,
      'summary': location.summary,
      'Information': location.information,
      'tel': location.tel,
      'tel1': location.tel1,
      'tel2': location.tel2,
      'navi': {
        'loc': location.naviLoc,
        'lat': location.naviLat,
        'lng': location.naviLng,
      },
      'isVisited': location.isVisited,
    };
    
    await _firestore.collection('locations').doc(location.id.toString()).set(data);
  }
}
