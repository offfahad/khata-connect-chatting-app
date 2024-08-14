import 'package:flutter_notifications/database/businessDao.dart';
import 'package:flutter_notifications/models/business.dart';

class BusinessRepository {
  final businessDao = BusinessDao();

  Future<List<Business>> getAllBusinesses({String? query, int? page}) =>
      businessDao.getBusinesses(query: query, page: page);

  Future<Business> getBusiness(int id) => businessDao.getBusiness(id);

  Future<int> insertBusiness(Business business) =>
      businessDao.createBusiness(business);

  Future<int> updateBusiness(Business business) =>
      businessDao.updateBusiness(business);

  Future<int> deleteBusinessById(int id) => businessDao.deleteBusiness(id);
}
