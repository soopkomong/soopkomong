import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/data/models/location_model.dart';

/// [Data Layer] - Remote DataSource Interface
abstract class RemoteLocationDataSource {
  FirebaseFirestore get firestore; // Firestore 인스턴스 노출
  Future<List<LocationModel>> getRemoteLocations({AppLocale locale = AppLocale.ko});
  Stream<List<LocationModel>> watchRemoteLocations({AppLocale locale = AppLocale.ko});
  Future<void> saveLocation(LocationModel location, {AppLocale locale = AppLocale.ko});
}

class RemoteLocationDataSourceImpl implements RemoteLocationDataSource {
  final FirebaseFirestore _firestore;

  RemoteLocationDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  String _getCollectionName(AppLocale locale) {
    return locale == AppLocale.en ? 'locations_en' : 'locations';
  }

  @override
  FirebaseFirestore get firestore => _firestore;

  @override
  Future<List<LocationModel>> getRemoteLocations({AppLocale locale = AppLocale.ko}) async {
    final snapshot = await _firestore.collection(_getCollectionName(locale)).get();
    return snapshot.docs
        .map((doc) => LocationModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Stream<List<LocationModel>> watchRemoteLocations({AppLocale locale = AppLocale.ko}) {
    return _firestore.collection(_getCollectionName(locale)).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => LocationModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  @override
  Future<void> saveLocation(LocationModel location, {AppLocale locale = AppLocale.ko}) async {
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

    await _firestore.collection(_getCollectionName(locale)).doc(location.id.toString()).set(data);
  }
}
